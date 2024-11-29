import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_trip/application_khadamati/screens/homepage_store.dart';
import 'package:my_trip/application_khadamati/screens/popular_stores_today.dart';
import 'package:my_trip/application_khadamati/screens/store.dart';
import 'package:my_trip/application_khadamati/splashscreen/splashscreen_wait.dart';
import 'package:my_trip/style/background_khdamati.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> banners = [];
  List<dynamic> stores = [];
  List<dynamic> storesPopular = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final bannersData = FirebaseFirestore.instance
          .collection('app_khdamati')
          .doc('Z764b2rk5LqsKvrPyNVm')
          .collection('stores')
          .where('activate', isEqualTo: true)
          .where('banner', isEqualTo: true)
          .get();

      final storesData = FirebaseFirestore.instance
          .collection('app_khdamati')
          .doc('Z764b2rk5LqsKvrPyNVm')
          .collection('store_type')
          .where('activate', isEqualTo: true)
          .get();

      final popularData = FirebaseFirestore.instance
          .collection('app_khdamati')
          .doc('Z764b2rk5LqsKvrPyNVm')
          .collection('stores')
          .where('activate', isEqualTo: true)
          .where('popular_today', isEqualTo: true)
          .get();

      final results = await Future.wait([bannersData, storesData, popularData]);

      setState(() {
        banners = results[0].docs;
        stores = results[1].docs;
        storesPopular = results[2].docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreenWaitKhdamati();
    } else {
      return Scaffold(
        body: BackgroundKhdamati(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBannerCarousel(context),
                _buildStoresGrid(context),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('popular_today'.tr()),
                      ),
                      if (storesPopular.length > 8)
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PopularStoresToday(),
                              ),
                            );
                          },
                          child: Text('view_all'.tr()),
                        ),
                    ],
                  ),
                ),
                _buildPopularStores(context),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildBannerCarousel(BuildContext context) {
    if (banners.isEmpty) {
      return const Center(
        child: SplashScreenWaitKhdamati(),
      );
    }
    return SizedBox(
      height: 175,
      child: CarouselSlider(
        options: CarouselOptions(
          height: 175.0,
          viewportFraction: 1.0,
          enableInfiniteScroll: true,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 15),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: true,
          scrollDirection: Axis.horizontal,
        ),
        items: banners.map(
          (banner) {
            String bannersImage = banner['bannerImage'] ?? '';
            String bannersId = banner['store_id'] ?? '';

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePageStore(
                      storeId: bannersId,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(bannersImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _buildStoresGrid(BuildContext context) {
    if (stores.isEmpty) {
      return const Center(
        child: SplashScreenWaitKhdamati(),
      );
    }

    return SizedBox(
      height: 300,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 3,
          childAspectRatio: 2.5,
        ),
        itemCount: stores.length > 5 ? 5 : stores.length,
        itemBuilder: (context, index) {
          return Row(
            children: stores
                .sublist(
              index * 3,
              (index * 3) + 3 > stores.length ? stores.length : (index * 3) + 3,
            )
                .map(
              (store) {
                String storesName = store['name'] ?? '';
                String storesImage = store['image'] ?? '';
                String storesId = store['store_type_id'] ?? '';
                return Expanded(
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Store(
                                namestore: storesName,
                                storesId: storesId,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          color: const Color.fromARGB(139, 80, 79, 79),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor:
                                      const Color.fromARGB(255, 0, 0, 0),
                                  backgroundImage: NetworkImage(storesImage),
                                ),
                                Text(storesName),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ).toList(),
          );
        },
      ),
    );
  }

  Widget _buildPopularStores(BuildContext context) {
    if (storesPopular.isEmpty) {
      return const Center(
        child: SplashScreenWaitKhdamati(),
      );
    }

    return SizedBox(
      height: 225,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 1,
          childAspectRatio: 1.75,
        ),
        itemCount: storesPopular.length > 8 ? 8 : storesPopular.length,
        itemBuilder: (context, index) {
          String storesImage = storesPopular[index]['image'] ?? '';
          String storesName = storesPopular[index]['name'] ?? '';
          String storesId = storesPopular[index]['store_id'] ?? '';

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePageStore(
                    storeId: storesId,
                  ),
                ),
              );
            },
            child: Column(
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(storesImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    storesName,
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
}
