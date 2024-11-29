// ignore_for_file: must_be_immutable

import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_trip/application_mytrip/screens/information/more_information_place.dart';
import 'package:my_trip/application_mytrip/screens/booking/places/booking_place.dart';
import 'package:my_trip/style/appbar.dart';
import 'package:my_trip/style/background_mytrip.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class InformationPlace extends StatefulWidget {
  final String placeName;
  final List<String> imageUrls;
  final double latitude;
  final double longitude;
  final int numberVisitors;
  final double newBudget;
  final double oldBudget;
  final String placeId;
  final String placeDetails;
  bool islogin = true;
  final String selectOption;

  InformationPlace({
    required this.placeName,
    required this.imageUrls,
    required this.latitude,
    required this.longitude,
    required this.numberVisitors,
    Key? key,
    required this.newBudget,
    required this.placeId,
    required this.placeDetails,
    required this.oldBudget,
    required this.selectOption,
  }) : super(key: key);

  @override
  State<InformationPlace> createState() => _InformationPlaceState();
}

class _InformationPlaceState extends State<InformationPlace> {
  int _currentIndex = 0;
  GoogleMapController? mapController;
  Set<Marker> markers = {};

  Future<Map<String, dynamic>> fetchWeather(
      double latitude, double longitude) async {
    const apiKey = 'b1a2cd689b3b4cd5bdd153431241210';
    final url =
        'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$latitude,$longitude&lang=ar';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Map<String, dynamic>? weatherData;

  @override
  void initState() {
    super.initState();
    markers.add(
      Marker(
        markerId: const MarkerId('stored_location'),
        position: LatLng(widget.latitude, widget.longitude),
        infoWindow: InfoWindow(
          title: widget.placeName,
        ),
      ),
    );

    fetchWeather(widget.latitude, widget.longitude).then((data) {
      setState(() {
        weatherData = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StyleAppBarMyTrip(title: widget.placeName),
      body: BackgroundMyTrip(
        child: Column(
          children: [
            Container(
              color: const Color.fromARGB(23, 38, 35, 35),
              child: Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 250.0,
                      aspectRatio: 16 / 9,
                      viewportFraction: 0.8,
                      initialPage: _currentIndex,
                      enableInfiniteScroll: true,
                      reverse: false,
                      autoPlay: false,
                      autoPlayInterval: const Duration(seconds: 3),
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      scrollDirection: Axis.horizontal,
                    ),
                    items: widget.imageUrls.map((imageUrl) {
                      return Builder(
                        builder: (BuildContext context) {
                          return GestureDetector(
                            onTap: () {},
                            child: SizedBox(
                              width: double.infinity,
                              height: 200,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(70),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor:
                                const Color.fromARGB(255, 38, 35, 35),
                            title: Text(
                              'do_you_want_to_book'.tr(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                            ),
                            actions: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BookingPlace(
                                                oldBudget: widget.oldBudget,
                                                longitude: widget.longitude,
                                                latitude: widget.latitude,
                                                placeId: widget.placeId,
                                                placeName: widget.placeName,
                                                imageUrls: widget.imageUrls,
                                                newBudget: widget.newBudget,
                                                selectOption:
                                                    widget.selectOption),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text(
                                        'yes'.tr(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 25),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color.fromARGB(255, 83, 0, 0),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text(
                                        'cancellation'.tr(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'booking'.tr(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MoreInformationPlace(
                                placeName: widget.placeName,
                                placeDetails: widget.placeDetails),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'information_about_the_place'.tr(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GoogleMap(
                  onMapCreated: (controller) {
                    setState(
                      () {
                        mapController = controller;
                      },
                    );
                  },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      widget.latitude,
                      widget.longitude,
                    ),
                    zoom: 17,
                  ),
                  markers: markers,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      color: const Color.fromARGB(255, 83, 0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${'weather_now'.tr()}:',
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (weatherData != null)
                            Column(
                              children: [
                                Text(
                                  '${weatherData!['current']['temp_c']}°C',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          else
                            const CircularProgressIndicator(
                              color: Colors.black,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
