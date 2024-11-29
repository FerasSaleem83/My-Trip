import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_trip/application_khadamati/screens/homepage_store.dart';
import 'package:my_trip/application_khadamati/screens/type_store.dart';
import 'package:my_trip/application_khadamati/splashscreen/splashscreen_wait.dart';
import 'package:my_trip/style/appbar.dart';
import 'package:my_trip/style/background_khdamati.dart';

class Store extends StatefulWidget {
  final String namestore;
  final String storesId;
  const Store({
    super.key,
    required this.namestore,
    required this.storesId,
  });

  @override
  State<Store> createState() => _StoreState();
}

class _StoreState extends State<Store> {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  List<dynamic> favorite = [];
  List<dynamic> type = [];
  List<dynamic> restaurant = [];
  List<dynamic> allStores = [];
  bool _isUploading = false;
  bool isFavorite = true;

  @override
  void initState() {
    super.initState();
    _isUploading = true;
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isUploading = true;
      });
      final favoriteData = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('my_favorite_store')
          .get();
      final typeData = FirebaseFirestore.instance
          .collection('app_khdamati')
          .doc('Z764b2rk5LqsKvrPyNVm')
          .collection('store_product_type')
          .where('activate', isEqualTo: true)
          .where('store_type_id', isEqualTo: widget.storesId)
          .get();
      final restaurantData = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('my_orders')
          .get();
      final allStoresData = FirebaseFirestore.instance
          .collection('app_khdamati')
          .doc('Z764b2rk5LqsKvrPyNVm')
          .collection('stores')
          .where('activate', isEqualTo: true)
          .where('store_type_id', isEqualTo: widget.storesId)
          .get();
      final results = await Future.wait(
          [favoriteData, typeData, restaurantData, allStoresData]);
      setState(() {
        favorite = results[0].docs;
        type = results[1].docs;
        restaurant = results[2].docs;
        allStores = results[3].docs;
        _isUploading = false;
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Widget _buildType(BuildContext context) {
    if (type.isEmpty) {
      return const Center(
        child: SplashScreenWaitKhdamati(),
      );
    }
    return SizedBox(
      height: 150,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 1,
          childAspectRatio: 1.5,
        ),
        itemCount: type.length,
        itemBuilder: (context, index) {
          String typeId = type[index]['store_type_product_id'];
          String typeImage = type[index]['image'] ?? '';
          String typeName = type[index]['name'] ?? '';

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TypeRestaurantsPage(typeId: typeId),
                ),
              );
            },
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  child: ClipOval(
                    child: Image.network(
                      typeImage,
                      width: 80,
                      height: 80,
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.error,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    typeName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRestaurant(BuildContext context) {
    if (restaurant.isEmpty) {
      return const Center(
        child: SplashScreenWaitKhdamati(),
      );
    }

    return SizedBox(
      height: 350,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: SizedBox(
          height:
              MediaQuery.of(context).size.height * 0.4, // ضبط الطول بشكل نسبي
          child: CarouselSlider(
            options: CarouselOptions(
              height:
                  MediaQuery.of(context).size.height * 0.35, // الطول الديناميكي
              aspectRatio: 16 / 9,
              viewportFraction: 0.8,
              initialPage: 0,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: false,
              enlargeCenterPage: true,
              scrollDirection: Axis.horizontal,
            ),
            items: restaurant.map((order) {
              String storeId = order['store_id'] ?? '';

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('app_khdamati')
                    .doc('Z764b2rk5LqsKvrPyNVm')
                    .collection('stores')
                    .doc(storeId)
                    .get(),
                builder: (context, storeSnapshot) {
                  if (storeSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.black,
                      ),
                    );
                  }
                  if (!storeSnapshot.hasData || storeSnapshot.data == null) {
                    return Text("store_not_found".tr());
                  }

                  var restaurant = storeSnapshot.data!;
                  String restaurantImage = restaurant['image'] ?? '';
                  String restaurantName = restaurant['name'] ?? '';
                  String restaurantPlace = restaurant['place'] ?? '';
                  double rate = restaurant['rate'].toDouble() ?? 0;
                  int personRateNumber = restaurant['personRateNumber'] ?? 0;
                  double total = 0;
                  if (rate != 0 && personRateNumber != 0) {
                    total = rate / personRateNumber;
                  } else {
                    total = 0.0;
                  }
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePageStore(storeId: storeId),
                        ),
                      );
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Card(
                          color: Colors.grey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SingleChildScrollView(
                                  child: SizedBox(
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 60),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 10, 0, 0),
                                          child: Text(restaurantName),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 10, 0, 0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: Color.fromARGB(
                                                    255, 222, 199, 0),
                                              ),
                                              Text('$total'),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 10, 0, 0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                  Icons.location_on_rounded),
                                              Text(restaurantPlace),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: -15,
                          left: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                            child: ClipOval(
                              child: Image.network(
                                restaurantImage,
                                width: 80,
                                height: 80,
                                fit: BoxFit.fill,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.error,
                                        color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .collection('my_favorite_store')
                                .doc(storeId)
                                .get(),
                            builder: (context, favoriteSnapshot) {
                              bool isFavorite = favoriteSnapshot.hasData &&
                                  favoriteSnapshot.data!.exists;

                              return IconButton(
                                icon: Icon(
                                  Icons.favorite,
                                  color: isFavorite ? Colors.red : Colors.green,
                                ),
                                onPressed: () async {
                                  if (isFavorite) {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(userId)
                                        .collection('my_favorite_store')
                                        .doc(storeId)
                                        .delete();
                                  } else {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(userId)
                                        .collection('my_favorite_store')
                                        .doc(storeId)
                                        .set({
                                      'store_id': storeId,
                                      'timestamp': Timestamp.now(),
                                    });
                                  }
                                  setState(() {});
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildAllStores(BuildContext context) {
    if (allStores.isEmpty) {
      return const Center(
        child: SplashScreenWaitKhdamati(),
      );
    }
    return SingleChildScrollView(
      child: Expanded(
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisSpacing: 1,
            childAspectRatio: 2.20,
          ),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: allStores.length,
          itemBuilder: (context, index) {
            DocumentSnapshot store = allStores[index];

            String storeImage = store['image'] ?? '';
            String storeName = store['name'] ?? '';
            String storeLocation = store['place'] ?? '';
            String storeId = store['store_id'] ?? '';
            double rate = store['rate'].toDouble() ?? 0;
            int personRateNumber = store['personRateNumber'] ?? 0;
            double total = 0;
            if (rate != 0 && personRateNumber != 0) {
              total = rate / personRateNumber;
            } else {
              total = 0.0;
            }
            return SizedBox(
              height: 200,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePageStore(storeId: storeId),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 150,
                          width: 400,
                          child: Card(
                            color: Colors.grey,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                color: const Color.fromARGB(255, 205, 205, 205),
                                child: Row(
                                  children: [
                                    Card(
                                      color: Colors.black,
                                      child: SizedBox(
                                        height: 125,
                                        width: 100,
                                        child: Image.network(
                                          storeImage,
                                          fit: BoxFit.fill,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                            Icons.error,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(storeName),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: Color.fromARGB(
                                                    255, 222, 199, 0),
                                              ),
                                              Text('$total'),
                                            ],
                                          ),
                                          Text(storeLocation),
                                        ],
                                      ),
                                    ),
                                    FutureBuilder<DocumentSnapshot>(
                                      future: FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(userId)
                                          .collection('my_favorite_store')
                                          .doc(storeId)
                                          .get(),
                                      builder: (context, favoriteSnapshot) {
                                        bool isFavorite =
                                            favoriteSnapshot.hasData &&
                                                favoriteSnapshot.data!.exists;

                                        return IconButton(
                                          icon: Icon(
                                            Icons.favorite,
                                            color: isFavorite
                                                ? Colors.red
                                                : Colors.green,
                                          ),
                                          onPressed: () async {
                                            if (isFavorite) {
                                              await FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(userId)
                                                  .collection(
                                                      'my_favorite_store')
                                                  .doc(storeId)
                                                  .delete();
                                            } else {
                                              await FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(userId)
                                                  .collection(
                                                      'my_favorite_store')
                                                  .doc(storeId)
                                                  .set({
                                                'store_id': storeId,
                                                'timestamp': Timestamp.now(),
                                              });
                                            }
                                            setState(() {});
                                          },
                                        );
                                      },
                                    ),
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
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isUploading) {
      return const SplashScreenWaitKhdamati();
    } else {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: StyleAppBarKhdamati(
            title: Image.asset(
          'assets/image/khdamati-logo.png',
          height: 50,
        )),
        body: BackgroundKhdamati(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
            child: ListView(
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              children: [
                _buildType(context),
                if (restaurant.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: Row(
                      children: [
                        Expanded(child: Text('your_recent_orders'.tr())),
                      ],
                    ),
                  ),
                const SizedBox(height: 25),
                if (restaurant.isNotEmpty) _buildRestaurant(context),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${'all'.tr()} ${widget.namestore} ',
                        ),
                      ),
                    ],
                  ),
                ),
                _buildAllStores(context),
              ],
            ),
          ),
        ),
      );
    }
  }
}
