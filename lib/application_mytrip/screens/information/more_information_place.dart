import 'package:flutter/material.dart';
import 'package:my_trip/style/appbar.dart';
import 'package:my_trip/style/color_splashscreen.dart';

class MoreInformationPlace extends StatefulWidget {
  final String placeName;
  final String placeDetails;
  const MoreInformationPlace(
      {super.key, required this.placeName, required this.placeDetails});

  @override
  State<MoreInformationPlace> createState() => _MoreInformationPlaceState();
}

class _MoreInformationPlaceState extends State<MoreInformationPlace> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StyleAppBarMyTrip(title: widget.placeName),
      body: BackgroundSplashScreen(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Center(
              child: Text(
                widget.placeDetails,
                style: const TextStyle(
                  fontSize: 22,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
