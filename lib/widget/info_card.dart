import 'package:flutter/material.dart';

class InfoCard {
  static Widget buildInfoCard(List<Widget> children, Color color) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: color,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Column(
                children: children,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
