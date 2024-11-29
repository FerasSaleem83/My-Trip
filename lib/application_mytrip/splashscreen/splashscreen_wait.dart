// ignore_for_file: library_private_types_in_public_api

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_trip/style/color_splashscreen.dart';

class SplashScreenWaitMyTrip extends StatefulWidget {
  const SplashScreenWaitMyTrip({super.key});

  @override
  State<SplashScreenWaitMyTrip> createState() => _SplashScreenWaitMyTripState();
}

class _SplashScreenWaitMyTripState extends State<SplashScreenWaitMyTrip> {
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
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Text(
                    'download'.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      letterSpacing: 1,
                      fontSize: 30,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w900,
                      color: Color.fromARGB(255, 0, 0, 0),
                      decorationThickness: 3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
