import 'package:flutter/material.dart';

class BackgroundMyTrip extends StatelessWidget {
  final Widget child;
  const BackgroundMyTrip({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/image/mytrip-background.jpg"),
          fit: BoxFit.fill,
          opacity: 0.5,
        ),
      ),
      child: child,
    );
  }
}
