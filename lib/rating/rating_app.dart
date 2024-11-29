// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:my_trip/style/appbar.dart';
import 'package:my_trip/style/background_mytrip.dart';

class Rating extends StatefulWidget {
  String appName;
  Rating({
    Key? key,
    required this.appName,
  }) : super(key: key);

  @override
  State<Rating> createState() => _RatingState();
}

class _RatingState extends State<Rating> {
  late Future<void> ratingFuture;
  bool isUploading = false;
  double _rating = 0;

  sendRating() async {
    try {
      setState(() {
        isUploading = true;
      });

      DocumentReference docRef;
      if (widget.appName == 'tawselti'.tr()) {
        docRef =
            FirebaseFirestore.instance.collection('app_tawselti').doc('rate');
      } else if (widget.appName == 'khdamati'.tr()) {
        docRef =
            FirebaseFirestore.instance.collection('app_khdamati').doc('rate');
      } else {
        docRef =
            FirebaseFirestore.instance.collection('app_mytrip').doc('rate');
      }

      DocumentSnapshot snapshot = await docRef.get();
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        int currentPersonNumber = data['personNumber'] ?? 0;
        double currentRate = data['rate'].toDouble() ?? 0.0;

        int newPersonNumber = currentPersonNumber + 1;
        double newRate =
            ((currentRate * currentPersonNumber) + _rating) / newPersonNumber;

        await docRef.set({
          'personNumber': newPersonNumber,
          'rate': newRate,
        }, SetOptions(merge: true));

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
              'rating_added_successfully'.tr(),
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'done'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        );
      } else {
        await docRef.set({
          'personNumber': 1,
          'rate': _rating,
        });

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
              'rating_added_successfully'.tr(),
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'done'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        isUploading = false;
      });

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
            'a_verification_error_occurred'.tr(),
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 83, 0, 0),
                foregroundColor: Colors.white,
              ),
              child: Text(
                'good'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StyleAppBarMyTrip(title: 'app_evaluation'.tr()),
      body: BackgroundMyTrip(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.appName == 'mytrip'.tr())
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/image/mytrip-logo.png',
                          width: 220,
                          height: 220,
                        ),
                        Text(
                          'mytrip'.tr(),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  if (widget.appName == 'tawselti'.tr())
                    Image.asset(
                      'assets/image/tawselti-logo.png',
                      width: 220,
                      height: 220,
                    ),
                  if (widget.appName == 'khdamati'.tr())
                    Image.asset(
                      'assets/image/khdamati-logo.png',
                      width: 220,
                      height: 220,
                    ),
                  const SizedBox(height: 40),
                  Image.asset('assets/image/emoji${_rating.toInt()}.png'),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RatingBar.builder(
                        initialRating: _rating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        itemSize: 48,
                        unratedColor: Colors.amber.withAlpha(50),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          setState(() {
                            _rating = rating;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${'rate'.tr()} $_rating',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 25),
                      if (isUploading)
                        const CircularProgressIndicator(
                          color: Colors.black,
                        ),
                      if (!isUploading)
                        SizedBox(
                          width: 200,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: sendRating,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                            ),
                            child: Text(
                              'send'.tr(),
                              style: const TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
