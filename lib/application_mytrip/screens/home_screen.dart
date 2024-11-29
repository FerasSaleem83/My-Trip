import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_trip/application_khadamati/splashscreen/splashscreen.dart';
import 'package:my_trip/application_mytrip/screens/booking/mybookings.dart';
import 'package:my_trip/application_mytrip/screens/booking/restaurants/booking_restaurant.dart';
import 'package:my_trip/application_mytrip/screens/map_screen.dart';
import 'package:my_trip/application_mytrip/screens/photos_page.dart';
import 'package:my_trip/application_mytrip/splashscreen/splashscreen_wait.dart';
import 'package:my_trip/application_tawselti/splashscreen/splashscreen.dart';
import 'package:my_trip/detailsuser.dart';
import 'package:my_trip/rating/rating_restaurant.dart';
import 'package:my_trip/rating/rating_store.dart';
import 'package:my_trip/style/appbar.dart';
import 'package:my_trip/style/background_mytrip.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_trip/widget/drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<QuerySnapshot<Map<String, dynamic>>> dataFuture;
  String userId = FirebaseAuth.instance.currentUser!.uid;
  late Future<DocumentSnapshot<Map<String, dynamic>>> usernameFuture;
  Map<String, dynamic>? weatherData;
  bool restaurantBooking = false;
  bool orderOnline = false;
  bool isRateStore = false;
  bool isRateProduct = false;
  bool isRateRestaurant = false;

  Future<QuerySnapshot<Map<String, dynamic>>> getData() async {
    User user = FirebaseAuth.instance.currentUser!;
    String userId = user.uid;
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(userId)
        .collection('my_booking_places')
        .where('activate', isEqualTo: true)
        .get();

    return snapshot;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getInfoData() async {
    User user = FirebaseAuth.instance.currentUser!;
    String userId = user.uid;
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(userId)
        .collection('information')
        .get();

    return snapshot;
  }

  Future<Map<String, dynamic>> fetchWeather(
      double latitude, double longitude) async {
    const apiKey = 'b1a2cd689b3b4cd5bdd153431241210';
    final url =
        'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$latitude,$longitude&lang=ar';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('failed_to_load_weather_data'.tr());
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUsers() async {
    User user = FirebaseAuth.instance.currentUser!;
    String userId = user.uid;
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(userId)
        .collection('information')
        .doc(userId)
        .get();

    return snapshot;
  }

  @override
  void initState() {
    super.initState();
    usernameFuture = getUsers();

    dataFuture = getData();
    dataFuture.then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        double latitude = data['latitude'].toDouble() ?? 0;
        double longitude = data['longitude'].toDouble() ?? 0;

        fetchWeather(latitude, longitude).then((data) {
          setState(() {
            weatherData = data;
          });
        });
      }
    });

    getInfoData().then((infoSnapshot) {
      if (infoSnapshot.docs.isNotEmpty) {
        final infoData = infoSnapshot.docs.first.data();
        setState(() {
          restaurantBooking = infoData['restaurant_booking'] ?? false;
          orderOnline = infoData['order_online'] ?? false;
          isRateStore = infoData['rate_store'] ?? false;
          isRateProduct = infoData['rate_product'] ?? false;
          isRateRestaurant = infoData['rate_restaurant'] ?? false;
        });
      }
    });
  }

  void finishTrip() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('information')
        .doc(userId)
        .set({
      'isBooking': false,
      'order_online': false,
      'restaurant_booking': false,
      'rate_place': false,
      'rate_product': false,
      'rate_restaurant': false,
      'rate_store': false,
      'wallet': 0.0
    }, SetOptions(merge: true));

    QuerySnapshot bookingSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('my_booking_places')
        .get();

    for (DocumentSnapshot bookingDoc in bookingSnapshot.docs) {
      await bookingDoc.reference.set({
        'activate': false,
      }, SetOptions(merge: true));
    }
    QuerySnapshot restaurantSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('my_booking_restaurants')
        .get();

    for (DocumentSnapshot restaurantDoc in restaurantSnapshot.docs) {
      await restaurantDoc.reference.set({
        'activate': false,
      }, SetOptions(merge: true));
    }

    QuerySnapshot orderSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('my_orders')
        .get();

    for (DocumentSnapshot orderDoc in orderSnapshot.docs) {
      await orderDoc.reference.set({
        'activate': false,
      }, SetOptions(merge: true));
    }
    QuerySnapshot tawseltiSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('my_journeys')
        .get();

    for (DocumentSnapshot tawseltiDoc in tawseltiSnapshot.docs) {
      await tawseltiDoc.reference.set({
        'activate': false,
      }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreenWaitMyTrip();
        } else if (snapshot.hasError) {
          return Center(
            child: Text('${'error'.tr()}: ${snapshot.error}'),
          );
        } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final docData = snapshot.data!.docs.first.data();
          String placeName = docData['name'];
          String placeWayToGo = docData['wayToGo'];
          double budget = docData['budget'].toDouble();
          double longitude = docData['longitude'].toDouble();
          double latitude = docData['latitude'].toDouble();
          int personNumber = docData['person_number'];
          String placeId = docData['place_id'];

          return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: usernameFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SplashScreenWaitMyTrip();
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('${'error'.tr()}: ${snapshot.error}'),
                  );
                } else if (snapshot.hasData) {
                  String username = snapshot.data!['username'];
                  String userEmail = snapshot.data!['email'];
                  String imageuser = snapshot.data!['image'];
                  String gender = snapshot.data!['gender'];
                  String phone = snapshot.data!['phonenumber'];
                  int age = snapshot.data!['age'];
                  String placeResidence = snapshot.data!['place_residence'];
                  int point = snapshot.data!['point'];
                  double wallet = snapshot.data!['wallet'].toDouble();

                  return Scaffold(
                    appBar: StyleAppBarMyTrip(title: 'home_page'.tr()),
                    drawer: MyDrawer(
                      snapshot: snapshot,
                      drawemail: '${FirebaseAuth.instance.currentUser?.email}',
                      drawusername: username,
                      imageusers: imageuser,
                      point: point,
                      wallet: wallet,
                      detailsUser: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsUser(
                              userName: username,
                              userEmail: userEmail,
                              imageUsers: imageuser,
                              userId: FirebaseAuth.instance.currentUser!.uid,
                              gender: gender,
                              phone: phone,
                              age: age,
                              placeResidence: placeResidence,
                            ),
                          ),
                        );
                      },
                    ),
                    body: BackgroundMyTrip(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      color:
                                          const Color.fromARGB(255, 83, 0, 0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${'place_name'.tr()}:  $placeName',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '${'weather_now'.tr()}:',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              if (weatherData != null)
                                                Column(
                                                  children: [
                                                    Text(
                                                      '${weatherData!['current']['temp_c']}°C',
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              if (weatherData == null)
                                                const CircularProgressIndicator(
                                                  color: Colors.black,
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        finishTrip();
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const MyBookings(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.black,
                                        fixedSize: const Size(175, 65),
                                        shape: ContinuousRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                      ),
                                      child: Text('end_the_trip'.tr()),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  if (placeWayToGo == 'سيارتي')
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MapPage(
                                                latitude: latitude,
                                                longitude: longitude,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: const Color.fromARGB(
                                              255, 83, 0, 0),
                                          fixedSize: const Size(175, 65),
                                          shape: ContinuousRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                        ),
                                        child: Text('directions'.tr()),
                                      ),
                                    ),
                                  if (placeWayToGo == 'توصيلتي')
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SplashScreenTawselti(
                                                latitude: latitude,
                                                longitude: longitude,
                                                username: username,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: const Color.fromARGB(
                                              255, 83, 0, 0),
                                          fixedSize: const Size(175, 65),
                                          shape: ContinuousRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              'assets/image/tawselti-icon.png',
                                              height: 50,
                                              width: 50,
                                            ),
                                            Text('tawselti'.tr()),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(50),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PhotosPage(
                                              placeId: placeId,
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: const Color.fromARGB(
                                            255, 123, 118, 118),
                                        fixedSize: const Size(150, 65),
                                        shape: ContinuousRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                      ),
                                      icon: Image.asset(
                                        'assets/image/gallery.png',
                                        width: 35,
                                        height: 35,
                                      ),
                                      label: Text('pictures_of_the_place'.tr()),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            if (restaurantBooking == true)
                              FutureBuilder<
                                  QuerySnapshot<Map<String, dynamic>>>(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userId)
                                    .collection('my_booking_restaurants')
                                    .where('activate', isEqualTo: true)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: SplashScreenWaitMyTrip());
                                  } else if (snapshot.hasError) {
                                    return Center(
                                        child: Text(
                                            '${'error'.tr()}: ${snapshot.error}'));
                                  } else if (snapshot.hasData &&
                                      snapshot.data!.docs.isNotEmpty) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: snapshot.data!.docs.length,
                                        itemBuilder: (context, index) {
                                          final restaurantData =
                                              snapshot.data!.docs[index].data();
                                          return Card(
                                            elevation: 4,
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${'restaurant_name'.tr()}: ${restaurantData['name']}',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: TextButton(
                                                            onPressed: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          MapPage(
                                                                    latitude: restaurantData[
                                                                            'latitude']
                                                                        .toDouble(),
                                                                    longitude: restaurantData[
                                                                            'longitude']
                                                                        .toDouble(),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: Text(
                                                              'map'.tr(),
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 16,
                                                                color:
                                                                    Colors.blue,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      if (isRateRestaurant ==
                                                          false)
                                                        Expanded(
                                                          child: Align(
                                                            alignment: Alignment
                                                                .centerRight,
                                                            child: TextButton(
                                                              onPressed: () {
                                                                Navigator
                                                                    .pushReplacement(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            RatingRestaurant(
                                                                      restaurantId:
                                                                          restaurantData['restaurant_id']
                                                                              .toString(),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: Text(
                                                                'rate'.tr(),
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
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
                                    );
                                  } else {
                                    return Center(
                                      child: Text('there_are_no_orders'.tr()),
                                    );
                                  }
                                },
                              )
                            else if (orderOnline == true)
                              FutureBuilder<
                                  QuerySnapshot<Map<String, dynamic>>>(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userId)
                                    .collection('my_orders')
                                    .where('activate', isEqualTo: true)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: SplashScreenWaitMyTrip());
                                  } else if (snapshot.hasError) {
                                    return Center(
                                        child: Text(
                                            '${'error'.tr()}: ${snapshot.error}'));
                                  } else if (snapshot.hasData &&
                                      snapshot.data!.docs.isNotEmpty) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: snapshot.data!.docs.length,
                                        itemBuilder: (context, index) {
                                          final orderData =
                                              snapshot.data!.docs[index].data();
                                          return Card(
                                            elevation: 4,
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${'store_name'.tr()}: ${orderData['store_name']}',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    '${'total_price'.tr()}: ${orderData['total_price']} ${'currency'}',
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    '${'delivery_fees'.tr()}: ${orderData['delivery_fee']} ${'currency'}',
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: TextButton(
                                                            onPressed:
                                                                () async {
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'users')
                                                                  .doc(userId)
                                                                  .collection(
                                                                      'information')
                                                                  .doc(userId)
                                                                  .set(
                                                                      {
                                                                    'order_online':
                                                                        false,
                                                                  },
                                                                      SetOptions(
                                                                          merge:
                                                                              true));
                                                              QuerySnapshot
                                                                  orderSnapshot =
                                                                  await FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'users')
                                                                      .doc(
                                                                          userId)
                                                                      .collection(
                                                                          'my_orders')
                                                                      .get();

                                                              for (DocumentSnapshot orderDoc
                                                                  in orderSnapshot
                                                                      .docs) {
                                                                await orderDoc
                                                                    .reference
                                                                    .set({
                                                                  'activate':
                                                                      false,
                                                                }, SetOptions(merge: true));
                                                              }
                                                            },
                                                            child: Text(
                                                              'the_request_has_been_received'
                                                                  .tr(),
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 16,
                                                                color:
                                                                    Colors.blue,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      if (isRateStore ==
                                                              false ||
                                                          isRateProduct ==
                                                              false)
                                                        Expanded(
                                                          child: Align(
                                                            alignment: Alignment
                                                                .centerRight,
                                                            child: TextButton(
                                                              onPressed: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            RatingStore(
                                                                      isRateStore:
                                                                          isRateStore,
                                                                      isRateProduct:
                                                                          isRateProduct,
                                                                      storeId: orderData[
                                                                              'store_id']
                                                                          .toString(),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: Text(
                                                                'rate'.tr(),
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
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
                                    );
                                  } else {
                                    return Center(
                                      child: Text('there_are_no_orders'.tr()),
                                    );
                                  }
                                },
                              ),
                            const SizedBox(height: 15),
                            if (wallet > 3 &&
                                orderOnline != true &&
                                restaurantBooking != true)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 0, 10, 50),
                                    child: Text(
                                      'do_you_want_to_buy_food'.tr(),
                                      style: const TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  BookingRestaurant(
                                                numberPerson: personNumber,
                                                newBudget: wallet,
                                                longitudeOld: longitude,
                                                latitudeOld: latitude,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.black,
                                          backgroundColor: Colors.grey,
                                          fixedSize: const Size(150, 125),
                                          shape: ContinuousRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Image.asset(
                                              'assets/image/logo-booking-restaurent.png',
                                              height: 75,
                                              width: 75,
                                            ),
                                            Text('restaurant_reservation'.tr()),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 25),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const SplashScreenKhdamati(),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.black,
                                          backgroundColor: Colors.grey,
                                          fixedSize: const Size(150, 125),
                                          shape: ContinuousRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Image.asset(
                                              'assets/image/khdamati-icon.png',
                                              height: 75,
                                              width: 75,
                                            ),
                                            Text('khdamati_application'.tr()),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 50),
                                ],
                              )
                            else if (budget <= 3)
                              Text(
                                'your_budget_is_not_enough_to_order_food'.tr(),
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return const Center(child: SplashScreenWaitMyTrip());
                }
              });
        } else {
          return const Center(child: SplashScreenWaitMyTrip());
        }
      },
    );
  }
}
