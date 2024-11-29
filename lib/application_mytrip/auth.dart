import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_trip/application_mytrip/screens/home_screen.dart';
import 'package:my_trip/application_mytrip/screens/enter_budget.dart';
import 'package:my_trip/application_mytrip/splashscreen/splashscreen_wait.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  @override
  void initState() {
    super.initState();
    getUsers();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getUsers() async {
    User? user = FirebaseAuth.instance.currentUser;

    String userId = user!.uid;
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('information')
        .where('email', isEqualTo: user.email)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreenWaitMyTrip();
          } else if (snapshot.hasError) {
            return AlertDialog(
              content: Text('${'error'.tr()} ${snapshot.error}'),
            );
          } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            final isBooking = snapshot.data!.docs.first['isBooking'];
            if (isBooking == true) {
              return const HomeScreen();
            } else if (isBooking == false) {
              return const PageBudget();
            } else {
              return AlertDialog(
                title: Text('error'.tr()),
                content: Text('no_data'.tr()),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('done'.tr()),
                  ),
                ],
              );
            }
          } else {
            return const SplashScreenWaitMyTrip();
          }
        },
      ),
    );
  }
}
