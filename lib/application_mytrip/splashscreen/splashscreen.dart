// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:my_trip/application_mytrip/authscreen.dart';
import 'package:my_trip/style/color_splashscreen.dart';

class SplashScreenMyTrip extends StatefulWidget {
  const SplashScreenMyTrip({super.key});

  @override
  State<SplashScreenMyTrip> createState() => _SplashScreenMyTripState();
}

class _SplashScreenMyTripState extends State<SplashScreenMyTrip> {
  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 8),
      () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const AuthScreen(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundSplashScreen(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/image/mytrip-logo.png',
              width: 350,
              height: 350,
            ),
          ],
        ),
      ),
    );
  }
}
