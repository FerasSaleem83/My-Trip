import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_trip/application_khadamati/screens/homepage_store.dart';
import 'package:my_trip/application_khadamati/splashscreen/splashscreen_wait.dart';
import 'package:my_trip/style/appbar.dart';
import 'package:my_trip/style/background_khdamati.dart';

class PopularStoresToday extends StatefulWidget {
  const PopularStoresToday({super.key});

  @override
  State<PopularStoresToday> createState() => _PopularStoresTodayState();
}

class _PopularStoresTodayState extends State<PopularStoresToday> {
  bool _isUploading = false;

  List<dynamic> storesPopular = [];

  @override
  void initState() {
    super.initState();

    _fetchstoresPopular();
  }

  Future<void> _fetchstoresPopular() async {
    setState(() {
      _isUploading = true;
    });

    try {
      final Future<QuerySnapshot<Map<String, dynamic>>> popularData =
          FirebaseFirestore.instance
              .collection('app_khdamati')
              .doc('Z764b2rk5LqsKvrPyNVm')
              .collection('stores')
              .where('popular_today', isEqualTo: true)
              .get();

      final results = await Future.wait([popularData]);

      setState(() {
        storesPopular = results[0].docs;
        _isUploading = false;
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Widget _buildPopularStores(BuildContext context) {
    return GridView.builder(
      scrollDirection: Axis.vertical,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 1,
        childAspectRatio: 2.5,
      ),
      itemCount: storesPopular.length,
      itemBuilder: (context, index) {
        String storesImage = storesPopular[index]['image'] ?? '';
        String storesName = storesPopular[index]['name'] ?? '';
        int numberAllOrder = storesPopular[index]['number_all_order'] ?? 0;
        int rate = storesPopular[index]['rate'] ?? 0;
        int personRateNumber = storesPopular[index]['personRateNumber'] ?? 1;
        double total = personRateNumber > 0 ? rate / personRateNumber : 0;

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
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Card(
              color: Colors.grey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                      backgroundImage: NetworkImage(storesImage),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(storesName),
                          Text("${'evaluation'.tr()}: $total"),
                          Text("${'number_of_orders'.tr()}: $numberAllOrder"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StyleAppBarKhdamati(title: Text('popular_stores_today'.tr())),
      body: _isUploading == false
          ? BackgroundKhdamati(
              child: _buildPopularStores(context),
            )
          : const Center(
              child: SplashScreenWaitKhdamati(),
            ),
    );
  }
}
