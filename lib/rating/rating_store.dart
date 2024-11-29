// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:my_trip/style/appbar.dart';
import 'package:my_trip/style/background_mytrip.dart';

class RatingStore extends StatefulWidget {
  bool isRateStore;
  bool isRateProduct;
  String storeId;
  RatingStore({
    Key? key,
    required this.isRateStore,
    required this.isRateProduct,
    required this.storeId,
  }) : super(key: key);

  @override
  State<RatingStore> createState() => _RatingStoreState();
}

class _RatingStoreState extends State<RatingStore> {
  late Future<void> ratingFuture;
  bool isUploading = false;
  bool isUploading2 = false;
  double _rating = 0;

  final String userId = FirebaseAuth.instance.currentUser!.uid;
  @override
  void initState() {
    super.initState();
  }

  sendRatingStore() async {
    try {
      setState(() {
        isUploading = true;
      });

      DocumentReference docRef;
      docRef = FirebaseFirestore.instance
          .collection('app_khdamati')
          .doc('Z764b2rk5LqsKvrPyNVm')
          .collection('stores')
          .doc(widget.storeId);

      DocumentSnapshot snapshot = await docRef.get();
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        int currentPersonNumber = data['personRateNumber'] ?? 0;
        double currentRate = data['rate'].toDouble() ?? 0.0;

        int newPersonNumber = currentPersonNumber + 1;
        double newRate =
            ((currentRate * currentPersonNumber) + _rating) / newPersonNumber;

        await docRef.set({
          'personRateNumber': newPersonNumber,
          'rate': newRate,
        }, SetOptions(merge: true));
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('information')
            .doc(userId)
            .set(
          {'rate_store': true},
          SetOptions(merge: true),
        );
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
          'personRateNumber': 1,
          'rate': _rating,
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('information')
            .doc(userId)
            .set(
          {'rate_store': true},
          SetOptions(merge: true),
        );
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
      appBar: StyleAppBarMyTrip(title: 'تقييم'.tr()),
      body: BackgroundMyTrip(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/image/khdamati-logo.png',
                        width: 220,
                        height: 220,
                      ),
                      Text(
                        'khdamati'.tr(),
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (widget.isRateStore == false)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('تقييم المتجر'.tr()),
                        const SizedBox(height: 40),
                        Image.asset(
                          'assets/image/emoji${_rating.toInt()}.png',
                          width: 50,
                          height: 50,
                        ),
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
                                  onPressed: sendRatingStore,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                        255, 255, 255, 255),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
