import 'package:flutter/material.dart';

class BackgroundSplashScreen extends StatelessWidget {
  final Widget child;
  const BackgroundSplashScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/image/background-splashscreen.png"),
          fit: BoxFit.fill,
          opacity: 0.5,
        ),
      ),
      child: child,
    );
  }
}
