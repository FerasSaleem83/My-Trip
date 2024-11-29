// ignore_for_file: must_be_immutable, use_build_context_synchronously, deprecated_member_use

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_trip/application_mytrip/screens/home_screen.dart';

import 'package:my_trip/application_mytrip/screens/information/information_restaurant.dart';
import 'package:my_trip/application_mytrip/splashscreen/splashscreen_wait.dart';
import 'package:my_trip/style/appbar.dart';
import 'package:my_trip/style/background_mytrip.dart';

class BookingRestaurant extends StatefulWidget {
  int numberPerson;
  double newBudget;
  double longitudeOld;
  double latitudeOld;

  BookingRestaurant({
    Key? key,
    required this.numberPerson,
    required this.newBudget,
    required this.longitudeOld,
    required this.latitudeOld,
  }) : super(key: key);

  @override
  State<BookingRestaurant> createState() => _BookingRestaurantState();
}

class _BookingRestaurantState extends State<BookingRestaurant> {
  final TextEditingController numberPersonController = TextEditingController();
  bool isUploading = false;
  late Stream<List<DocumentSnapshot>> tripsStream;
  final _isUploading = false;
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<List<DocumentSnapshot>> _fetchAndFilterRestaurants() async {
    List<DocumentSnapshot> filteredRestaurants = [];

    QuerySnapshot tripSnapshot =
        await FirebaseFirestore.instance.collection('app_mytrip').get();

    for (var tripDoc in tripSnapshot.docs) {
      QuerySnapshot restaurantSnapshot =
          await tripDoc.reference.collection('restaurants').get();

      List<DocumentSnapshot> restaurants = restaurantSnapshot.docs;

      List<DocumentSnapshot> filtered = restaurants.where((doc) {
        double lat = doc['latitude'].toDouble();
        double lon = doc['longitude'].toDouble();
        double distance = _calculateDistance(
          widget.latitudeOld,
          widget.longitudeOld,
          lat,
          lon,
        );
        return distance <= 5;
      }).toList();

      filteredRestaurants.addAll(filtered);
    }

    filteredRestaurants.sort((a, b) {
      double latA = a['latitude'].toDouble();
      double lonA = a['longitude'].toDouble();
      double latB = b['latitude'].toDouble();
      double lonB = b['longitude'].toDouble();
      double distanceA = _calculateDistance(
        widget.latitudeOld,
        widget.longitudeOld,
        latA,
        lonA,
      );
      double distanceB = _calculateDistance(
        widget.latitudeOld,
        widget.longitudeOld,
        latB,
        lonB,
      );
      return distanceA.compareTo(distanceB);
    });

    return filteredRestaurants;
  }

  void bookingrestaurant(String restaurantId, String restaurantName,
      List<String> imageUrls) async {
    try {
      QuerySnapshot mytripSnapshot =
          await FirebaseFirestore.instance.collection('app_mytrip').get();

      for (var tripDoc in mytripSnapshot.docs) {
        QuerySnapshot restaurantSnapshot = await tripDoc.reference
            .collection('restaurants')
            .where(FieldPath.documentId, isEqualTo: restaurantId)
            .get();

        for (var restaurantDoc in restaurantSnapshot.docs) {
          await restaurantDoc.reference.update({
            'number_visitors': FieldValue.increment(
              widget.numberPerson,
            ),
            'number_chairs_avilable': FieldValue.increment(
              widget.numberPerson,
            ),
          });
        }
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('my_booking_restaurants')
          .add(
        {
          'restaurant_id': restaurantId,
          'name': restaurantName,
          'image': imageUrls,
          'person_number': widget.numberPerson,
          'budget': widget.newBudget,
          'latitude': widget.latitudeOld,
          'longitude': widget.longitudeOld,
          'timestamp': Timestamp.now(),
        },
      );
      QuerySnapshot mytripSnapshot2 =
          await FirebaseFirestore.instance.collection('app_mytrip').get();

      for (var tripDoc in mytripSnapshot2.docs) {
        QuerySnapshot restaurantSnapshot = await tripDoc.reference
            .collection('restaurants')
            .where(FieldPath.documentId, isEqualTo: restaurantId)
            .get();

        for (var restaurantDoc in restaurantSnapshot.docs) {
          double currentBudget = restaurantDoc['budget']?.toDouble() ?? 0.0;

          double newBudget =
              currentBudget - (widget.newBudget * widget.numberPerson);

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('information')
              .doc(userId)
              .set(
            {
              'restaurant_booking': true,
              'wallet': newBudget,
              'point': FieldValue.increment(1),
            },
            SetOptions(merge: true),
          );
        }
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color.fromARGB(255, 38, 35, 35),
          title: Text(
            'succeeded'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          content: Text(
            'a_restaurant_reservation_has_been_made'.tr(),
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'done'.tr(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color.fromARGB(255, 38, 35, 35),
          title: Text(
            'error'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          content: Text(
            'error_booking_message'.tr(),
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 83, 0, 0),
                foregroundColor: Colors.white,
              ),
              child: Text(
                'good'.tr(),
                style: const TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    tripsStream = FirebaseFirestore.instance
        .collection('app_mytrip')
        .snapshots()
        .asyncMap((snapshot) async {
      List<DocumentSnapshot> filteredDocs = await _fetchAndFilterRestaurants();
      return filteredDocs;
    });
  }

  Future<bool> onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text('do_you_want_to_leave'.tr()),
            actions: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: Text('yes'.tr()),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('no'.tr()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: StyleAppBarMyTrip(
            title:
                '${'booking_restaurant'.tr()} ${widget.newBudget.toStringAsFixed(2)} ${'currency'.tr()}'),
        body: BackgroundMyTrip(
          child: StreamBuilder<List<DocumentSnapshot>>(
            stream: tripsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreenWaitMyTrip();
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('${'error'.tr()}: ${snapshot.error}'),
                );
              } else if (_isUploading) {
                return const CircularProgressIndicator(
                  color: Colors.black,
                );
              } else if (snapshot.hasData || !_isUploading) {
                List<DocumentSnapshot> trips = snapshot.data!;
                if (trips.isEmpty) {
                  return Center(
                    child: Text('no_restaurant'.tr()),
                  );
                }
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisSpacing: 2,
                        childAspectRatio: 2,
                        mainAxisExtent: 325,
                      ),
                      itemCount: (trips.length / 1).ceil(),
                      itemBuilder: (context, index) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: trips
                              .sublist(
                            index * 1,
                            (index * 1) + 1 > trips.length
                                ? trips.length
                                : (index * 1) + 1,
                          )
                              .map((trip) {
                            String restaurantName = trip['name'];
                            final List<String> imageUrls =
                                (trip['image'] as List).cast<String>();
                            double latitude = trip['latitude'].toDouble();
                            double longitude = trip['longitude'].toDouble();
                            double numberVisitors =
                                trip['number_visitors'].toDouble();
                            double restaurantCapacity =
                                trip['capacity'].toDouble();
                            double budget = trip['budget'].toDouble();
                            double rate = trip['rate'].toDouble();
                            String restaurantId = trip['restaurant_id'];

                            return SizedBox(
                              width: 300,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(75.0),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 6.0,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(35)),
                                    gradient: const LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Color.fromARGB(255, 131, 131, 131),
                                        Color.fromARGB(255, 131, 131, 131),
                                      ],
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 4.0,
                                            ),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(100)),
                                            gradient: const LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                                Color.fromARGB(
                                                    255, 255, 255, 255),
                                                Colors.white,
                                              ],
                                            ),
                                          ),
                                          child: CircleAvatar(
                                            backgroundImage:
                                                NetworkImage(imageUrls[0]),
                                            radius: 75,
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 0, 0, 0),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            restaurantName,
                                            style: const TextStyle(
                                              fontSize: 23,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          InformationRestaurant(
                                                        restaurantName:
                                                            restaurantName,
                                                        imageUrls: imageUrls,
                                                        latitude: latitude,
                                                        longitude: longitude,
                                                        numberVisitors:
                                                            numberVisitors,
                                                        restaurantCapacity:
                                                            restaurantCapacity,
                                                        budget:
                                                            budget.toDouble(),
                                                        restaurantId:
                                                            restaurantId,
                                                        rate: rate,
                                                        numberPerson:
                                                            widget.numberPerson,
                                                        newBudget:
                                                            widget.newBudget,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 0, 9, 81),
                                                  foregroundColor: Colors.white,
                                                ),
                                                child: Text('reservation'.tr()),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                );
              } else {
                return Center(
                  child: Text('no_data'.tr()),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
