import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_trip/application_khadamati/screens/homepage_store.dart';
import 'package:my_trip/application_khadamati/splashscreen/splashscreen_wait.dart';
import 'package:my_trip/style/appbar.dart';
import 'package:my_trip/style/background_khdamati.dart';

class TypeRestaurantsPage extends StatefulWidget {
  final String typeId;

  const TypeRestaurantsPage({Key? key, required this.typeId}) : super(key: key);

  @override
  State<TypeRestaurantsPage> createState() => _TypeRestaurantsPageState();
}

class _TypeRestaurantsPageState extends State<TypeRestaurantsPage> {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  late Stream<List<DocumentSnapshot>> storeStream;

  @override
  void initState() {
    super.initState();
    getStore();
  }

  Future<void> getStore() async {
    storeStream = FirebaseFirestore.instance
        .collection('app_khdamati')
        .doc('Z764b2rk5LqsKvrPyNVm')
        .collection('stores')
        .where('product_id', arrayContains: widget.typeId)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StyleAppBarKhdamati(
          title: Image.asset(
        'assets/image/khdamati-logo.png',
        height: 50,
      )),
      body: BackgroundKhdamati(
        child: StreamBuilder<List<DocumentSnapshot>>(
          stream: storeStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: SplashScreenWaitKhdamati());
            }
            if (snapshot.hasError) {
              return const Center(child: Text("Error loading restaurants"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No restaurants available"));
            }

            List<DocumentSnapshot> stores = snapshot.data!;

            return ListView.builder(
              shrinkWrap: true,
              itemCount: stores.length,
              itemBuilder: (context, index) {
                DocumentSnapshot store = stores[index];

                String storeImage = store['image'] ?? '';
                String storeName = store['name'] ?? '';
                String storeLocation = store['place'] ?? '';
                String storeId = store['store_id'] ?? '';
                int rate = store['rate'] ?? 0;
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
                            Expanded(
                              child: SizedBox(
                                height: 150,
                                child: Card(
                                  color: Colors.grey,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Card(
                                      color: const Color.fromARGB(
                                          255, 205, 205, 205),
                                      child: Row(
                                        children: [
                                          Card(
                                            color: Colors.black,
                                            child: SizedBox(
                                              height: 125,
                                              width: 140,
                                              child: Image.network(
                                                storeImage,
                                                fit: BoxFit.fill,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
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
                                            builder:
                                                (context, favoriteSnapshot) {
                                              bool isFavorite = favoriteSnapshot
                                                      .hasData &&
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
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('users')
                                                        .doc(userId)
                                                        .collection(
                                                            'my_favorite_store')
                                                        .doc(storeId)
                                                        .delete();
                                                  } else {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('users')
                                                        .doc(userId)
                                                        .collection(
                                                            'my_favorite_store')
                                                        .doc(storeId)
                                                        .set({
                                                      'store_id': storeId,
                                                      'timestamp':
                                                          Timestamp.now(),
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
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
