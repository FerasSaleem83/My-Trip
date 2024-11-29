import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_trip/application_mytrip/auth.dart';
import 'package:my_trip/rating/rating_app.dart';
import 'package:my_trip/style/appbar.dart';
import 'package:my_trip/style/background_mytrip.dart';

class MyBookings extends StatefulWidget {
  const MyBookings({super.key});

  @override
  State<MyBookings> createState() => _MyBookingsState();
}

class _MyBookingsState extends State<MyBookings> {
  late Stream<List<DocumentSnapshot>> tripsStream;

  _uploadData() {
    setState(() {});
    tripsStream = FirebaseFirestore.instance
        .collection('MyPlaceBookings')
        .where(
          'email',
          isEqualTo: FirebaseAuth.instance.currentUser!.email,
        )
        .snapshots()
        .map((snapshot) => snapshot.docs);

    setState(() {});
  }

  @override
  void initState() {
    _uploadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StyleAppBarMyTrip(title: 'evaluation_stage'.tr()),
      body: BackgroundMyTrip(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 75, 8, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'tell_us_what_you_think_about_our_apps'.tr(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 25),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => Rating(
                                      appName: 'mytrip'.tr(),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  padding: const EdgeInsets.all(16),
                                  shape: const CircleBorder(
                                    side: BorderSide(
                                      width: 2,
                                      color: Colors.black,
                                    ),
                                  ),
                                  foregroundColor:
                                      const Color.fromARGB(255, 0, 0, 0)),
                              child: Image.asset(
                                'assets/image/mytrip-logo.png',
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => Rating(
                                      appName: 'khdamati'.tr(),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  padding: const EdgeInsets.all(16),
                                  shape: const CircleBorder(
                                    side: BorderSide(
                                      width: 2,
                                      color: Colors.black,
                                    ),
                                  ),
                                  foregroundColor:
                                      const Color.fromARGB(255, 0, 0, 0)),
                              child: Image.asset(
                                'assets/image/khdamati-icon.png',
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => Rating(
                                      appName: 'tawselti'.tr(),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  padding: const EdgeInsets.all(16),
                                  shape: const CircleBorder(
                                    side: BorderSide(
                                      width: 2,
                                      color: Colors.black,
                                    ),
                                  ),
                                  foregroundColor:
                                      const Color.fromARGB(255, 0, 0, 0)),
                              child: Image.asset(
                                'assets/image/tawselti-icon.png',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const Auth(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                            padding: const EdgeInsets.all(16),
                            foregroundColor:
                                const Color.fromARGB(255, 255, 255, 255)),
                        child: Text('return_to_the_home_page'.tr()),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
