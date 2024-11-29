import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_trip/style/color_splashscreen.dart';

class SplashScreenWaitKhdamati extends StatefulWidget {
  const SplashScreenWaitKhdamati({super.key});

  @override
  State<SplashScreenWaitKhdamati> createState() =>
      _SplashScreenWaitKhdamatiState();
}

class _SplashScreenWaitKhdamatiState extends State<SplashScreenWaitKhdamati> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundSplashScreen(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/image/khdamati-logo.png',
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
