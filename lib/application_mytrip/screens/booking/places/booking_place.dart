// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:my_trip/application_mytrip/screens/home_screen.dart';
import 'package:my_trip/style/appbar.dart';
import 'package:my_trip/style/background_mytrip.dart';

class BookingPlace extends StatefulWidget {
  double longitude;
  double latitude;
  String placeId;
  String placeName;
  List<String> imageUrls;
  double newBudget;
  double oldBudget;
  final String selectOption;

  BookingPlace({
    Key? key,
    required this.longitude,
    required this.latitude,
    required this.placeId,
    required this.placeName,
    required this.imageUrls,
    required this.newBudget,
    required this.oldBudget,
    required this.selectOption,
  }) : super(key: key);

  @override
  State<BookingPlace> createState() => _BookingPlaceState();
}

class _BookingPlaceState extends State<BookingPlace> {
  final TextEditingController numberPersonController = TextEditingController();
  bool isUploading = false;
  int _currentIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void bookingplace() async {
    final valid = _formKey.currentState!.validate();
    if (!valid) {
      return;
    }

    setState(() {
      isUploading = true;
    });
    await FirebaseFirestore.instance
        .collection('app_mytrip')
        .doc('QXmlP0NZfyfeJrKUICjq')
        .collection('places')
        .doc(widget.placeId)
        .update(
      {
        'number_visitors': FieldValue.increment(
          int.parse(numberPersonController.text.trim()),
        ),
      },
    );
    User? user = FirebaseAuth.instance.currentUser;

    String userId = user!.uid;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('my_booking_places')
        .add(
      {
        'place_id': widget.placeId,
        'name': widget.placeName,
        'image': widget.imageUrls,
        'person_number': int.parse(numberPersonController.text.trim()),
        'timestamp': Timestamp.now(),
        'budget': widget.newBudget,
        'oldBudget': widget.oldBudget,
        'longitude': widget.longitude,
        'latitude': widget.latitude,
        'activate': true,
        'wayToGo': widget.selectOption,
      },
    );

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('information')
        .doc(userId)
        .set({
      'isBooking': true,
      'wallet': widget.newBudget,
      'point': FieldValue.increment(1),
    }, SetOptions(merge: true));
    setState(() {
      isUploading = false;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 38, 35, 35),
          title: Text(
            'succeeded'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          content: Text(
            'the_place_has_been_booked_successfully'.tr(),
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
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                        (Route<dynamic> route) => false,
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StyleAppBarMyTrip(title: 'venue_reservation_page'.tr()),
      body: BackgroundMyTrip(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  color: const Color.fromARGB(23, 38, 35, 35),
                  child: Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: 300.0,
                          aspectRatio: 16 / 9,
                          viewportFraction: 0.8,
                          initialPage: _currentIndex,
                          enableInfiniteScroll: true,
                          reverse: false,
                          autoPlay: false,
                          autoPlayInterval: const Duration(seconds: 3),
                          autoPlayAnimationDuration:
                              const Duration(milliseconds: 800),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          enlargeCenterPage: true,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                          scrollDirection: Axis.horizontal,
                        ),
                        items: widget.imageUrls.map((imageUrl) {
                          return Builder(
                            builder: (BuildContext context) {
                              return GestureDetector(
                                onTap: () {},
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 200,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(70),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: TextFormField(
                    controller: numberPersonController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'enter_the_number_of_people'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value == '0') {
                        return 'please_enter_the_number_of_people'.tr();
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                if (isUploading)
                  const CircularProgressIndicator(
                    color: Color.fromARGB(255, 38, 35, 35),
                  ),
                if (!isUploading)
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SizedBox(
                      width: 1000,
                      child: ElevatedButton(
                        onPressed: bookingplace,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 38, 35, 35),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(15),
                        ),
                        child: Text(
                          'reserve_the_place'.tr(),
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 1000,
                    child: Container(
                      color: const Color.fromARGB(255, 83, 0, 0),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text(
                            '${'remaining_budget'.tr()}: ${widget.newBudget.toStringAsFixed(2)} دينار',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
