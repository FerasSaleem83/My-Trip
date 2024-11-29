// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:my_trip/application_khadamati/main_screen.dart';

class SplashScreenKhdamati extends StatefulWidget {
  const SplashScreenKhdamati({super.key});

  @override
  State<SplashScreenKhdamati> createState() => _SplashScreenKhdamatiState();
}

class _SplashScreenKhdamatiState extends State<SplashScreenKhdamati> {
  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 6),
      () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainScreenKhdamati(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFB28742),
        child: Center(
          child: Image.asset(
            'assets/image/khdamati-logo2.png',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
        ),
      ),
    );
  }
}
