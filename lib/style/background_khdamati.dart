import 'package:flutter/material.dart';

class BackgroundKhdamati extends StatelessWidget {
  final Widget child;
  const BackgroundKhdamati({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/image/khdamati-background.png"),
          fit: BoxFit.fill,
          opacity: 0.5,
        ),
      ),
      child: child,
    );
  }
}
