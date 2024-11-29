import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_trip/application_khadamati/screens/purchase_process.dart';
import 'package:my_trip/application_khadamati/splashscreen/splashscreen_wait.dart';
import 'package:my_trip/style/appbar.dart';
import 'package:my_trip/style/color_splashscreen.dart';

class HomePageStore extends StatefulWidget {
  final String storeId;
  const HomePageStore({super.key, required this.storeId});

  @override
  State<HomePageStore> createState() => _HomePageStoreState();
}

class _HomePageStoreState extends State<HomePageStore> {
  bool _isUploading = false;
  late Stream<List<DocumentSnapshot>> storeStream;
  late Stream<List<DocumentSnapshot>> allProductsStream;
  String currentStoreName = '';
  String currentStoreId = '';

  List<Map<String, dynamic>> selectedProducts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isUploading = true;
    });

    await Future.wait([
      _fetchStores(),
      _fetchProducts(),
    ]);

    setState(() {
      _isUploading = false;
    });
  }

  Future<void> _fetchProducts() async {
    allProductsStream = FirebaseFirestore.instance
        .collection('app_khdamati')
        .doc('Z764b2rk5LqsKvrPyNVm')
        .collection('stores')
        .doc(widget.storeId)
        .collection('product')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Future<void> _fetchStores() async {
    storeStream = FirebaseFirestore.instance
        .collection('app_khdamati')
        .doc('Z764b2rk5LqsKvrPyNVm')
        .collection('stores')
        .where('store_id', isEqualTo: widget.storeId)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Future<bool> _isFavorite(String productId) async {
    final favDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('favorites')
        .doc(widget.storeId)
        .collection('products')
        .doc(productId)
        .get();
    return favDoc.exists;
  }

  Future<void> _addToFavorites(
      String productId, Map<String, dynamic> productData) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('favorites')
        .doc(widget.storeId)
        .collection('products')
        .doc(productId)
        .set(productData);
  }

  Future<void> _removeFromFavorites(String productId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('favorites')
        .doc(widget.storeId)
        .collection('products')
        .doc(productId)
        .delete();
  }

  void _addProduct(
      String productName, double productPrice, String productImage) {
    setState(() {
      int index = selectedProducts
          .indexWhere((product) => product['name'] == productName);
      if (index == -1) {
        selectedProducts.add({
          'name': productName,
          'price': productPrice,
          'quantity': 1,
          'image': productImage,
        });
      } else {
        selectedProducts[index]['quantity']++;
      }
    });
  }

  void _removeProduct(String productName) {
    setState(() {
      int index = selectedProducts
          .indexWhere((product) => product['name'] == productName);
      if (index != -1 && selectedProducts[index]['quantity'] > 0) {
        selectedProducts[index]['quantity']--;
        if (selectedProducts[index]['quantity'] == 0) {
          selectedProducts.removeAt(index);
        }
      }
    });
  }

  Widget _buildHeadStores(BuildContext context) {
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: storeStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SplashScreenWaitKhdamati());
        } else if (snapshot.hasError) {
          return Center(child: Text("error_loading_popular_stores".tr()));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("no_popular_stores_available".tr()));
        } else {
          List<DocumentSnapshot> stores = snapshot.data!;

          return ListView.builder(
            shrinkWrap: true,
            itemCount: stores.length,
            itemBuilder: (context, index) {
              DocumentSnapshot store = stores[index];

              String storeImage = store['image'] ?? '';
              String storeName = store['name'] ?? '';
              String storeId = store['store_id'] ?? '';
              currentStoreName = storeName;
              currentStoreId = storeId;
              return SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        color: const Color.fromARGB(255, 150, 125, 125),
                        child: Image.network(
                          storeImage,
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.error,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildAllProductss(BuildContext context) {
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: allProductsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SplashScreenWaitKhdamati());
        } else if (snapshot.hasError) {
          return Center(child: Text("error_loading_products".tr()));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("no_products_available".tr()));
        } else {
          List<DocumentSnapshot> products = snapshot.data!;

          return ListView.builder(
            shrinkWrap: true,
            itemCount: products.length,
            itemBuilder: (context, index) {
              DocumentSnapshot product = products[index];

              String productName = product['name'] ?? '';
              String productImage = product['image'] ?? '';
              double productPrice = (product['price'] ?? 0.0).toDouble();
              double productRate = (product['rate'] ?? 0.0).toDouble();
              String productId = product.id;

              int quantity = selectedProducts.firstWhere(
                  (prod) => prod['name'] == productName,
                  orElse: () => {'quantity': 0})['quantity'];

              return FutureBuilder<bool>(
                future: _isFavorite(productId),
                builder: (context, favSnapshot) {
                  if (!favSnapshot.hasData) return Container();

                  bool isFavorite = favSnapshot.data!;

                  return InkWell(
                    onTap: () {},
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 160,
                                child: Card(
                                  color: Colors.grey,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 50,
                                          backgroundColor: Colors.black,
                                          backgroundImage:
                                              NetworkImage(productImage),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(productName),
                                                      const SizedBox(
                                                          height: 15),
                                                      Text(
                                                          '$productPrice ${'currency'.tr()}'),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      '$productRate',
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                    const Icon(
                                                      Icons.star,
                                                      size: 18,
                                                      color: Color.fromARGB(
                                                          255, 222, 199, 0),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Expanded(
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.favorite,
                                                  color: isFavorite
                                                      ? Colors.red
                                                      : Colors.grey,
                                                ),
                                                onPressed: () async {
                                                  if (isFavorite) {
                                                    await _removeFromFavorites(
                                                        productId);
                                                  } else {
                                                    await _addToFavorites(
                                                        productId, {
                                                      'name': productName,
                                                      'price': productPrice,
                                                      'image': productImage,
                                                      'rate': productRate,
                                                    });
                                                  }
                                                  setState(() {});
                                                },
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                if (quantity > 0)
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.remove_circle,
                                                        color: Colors.red),
                                                    onPressed: () {
                                                      _removeProduct(
                                                          productName);
                                                    },
                                                  ),
                                                if (quantity > 0)
                                                  Text('$quantity'),
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.add_circle,
                                                      color: Colors.green),
                                                  onPressed: () {
                                                    _addProduct(
                                                        productName,
                                                        productPrice,
                                                        productImage);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isUploading == true) {
      return const SplashScreenWaitKhdamati();
    } else {
      return Scaffold(
        appBar: StyleAppBarKhdamati(
            title: Image.asset(
          'assets/image/khdamati-logo.png',
          height: 50,
        )),
        body: BackgroundSplashScreen(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeadStores(context),
                const SizedBox(height: 25),
                _buildAllProductss(context),
                const SizedBox(height: 25),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: selectedProducts.isEmpty
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PurchaseProcess(
                                          selectedProducts: selectedProducts,
                                          storeName: currentStoreName,
                                          currentStoreId: currentStoreId,
                                        ),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedProducts.isEmpty
                                  ? Colors.grey
                                  : Colors.black,
                              foregroundColor: selectedProducts.isEmpty
                                  ? Colors.black
                                  : Colors.white,
                            ),
                            child: Text('confirm_purchase'.tr()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
