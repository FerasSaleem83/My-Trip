// ignore_for_file: deprecated_member_use, unnecessary_null_comparison

import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:my_trip/application_mytrip/splashscreen/splashscreen_wait.dart';
import 'package:my_trip/style/appbar.dart';
import 'package:my_trip/style/color_splashscreen.dart';

class MapPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  const MapPage({Key? key, required this.latitude, required this.longitude})
      : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LocationData? currentLocation;
  Location location = Location();
  late LatLng destination;
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;
  dynamic helper = [];
  BitmapDescriptor? treeIcon;
  final Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    super.initState();
    destination = LatLng(widget.latitude, widget.longitude);
    _getCurrentLocation();
    polylinePoints = PolylinePoints();
    _loadIcons();
  }

  Future<void> _loadIcons() async {
    treeIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(100, 100)),
      'assets/image/logo-tree.png',
    );
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    currentLocation = await location.getLocation();
    _getPolyline();
    location.onLocationChanged.listen((LocationData loc) {
      setState(() {
        currentLocation = loc;
      });
    });
  }

  Future<void> _getPolyline() async {
    if (currentLocation == null) return;

    PolylineRequest polylineRequest = PolylineRequest(
      origin:
          PointLatLng(currentLocation!.latitude!, currentLocation!.longitude!),
      destination: PointLatLng(destination.latitude, destination.longitude),
      mode: TravelMode.driving,
    );

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: polylineRequest,
      googleApiKey: 'AIzaSyA4wJb3uf7Uvr_xT3QkokS8NaNdWD2iWSA',
    );

    if (result.status == 'OK' && result.points.isNotEmpty) {
      setState(() {
        polylineCoordinates = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
      });
    }
  }

  Future<void> _zoomToFitRoute() async {
    if (currentLocation == null || destination == null) return;

    LatLngBounds bounds;

    if (currentLocation!.latitude! > destination.latitude &&
        currentLocation!.longitude! > destination.longitude) {
      bounds = LatLngBounds(
        southwest: destination,
        northeast:
            LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
      );
    } else if (currentLocation!.latitude! > destination.latitude) {
      bounds = LatLngBounds(
        southwest: LatLng(destination.latitude, currentLocation!.longitude!),
        northeast: LatLng(currentLocation!.latitude!, destination.longitude),
      );
    } else if (currentLocation!.longitude! > destination.longitude) {
      bounds = LatLngBounds(
        southwest: LatLng(currentLocation!.latitude!, destination.longitude),
        northeast: LatLng(destination.latitude, currentLocation!.longitude!),
      );
    } else {
      bounds = LatLngBounds(
        southwest:
            LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        northeast: destination,
      );
    }

    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  Widget _buildHelperCarousel(BuildContext context) {
    return SizedBox(
      height: 200,
      child: CarouselSlider(
        options: CarouselOptions(
          height: 200.0,
          aspectRatio: MediaQuery.of(context).size.width /
              MediaQuery.of(context).size.height,
          viewportFraction: 1.0,
          enableInfiniteScroll: false,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 10),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: true,
          scrollDirection: Axis.horizontal,
        ),
        items: [
          Container(
            width: double.infinity,
            color: Colors.grey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${'if_you_want_guidance_on_the_way_to_go_follow_these_steps'.tr()}:',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                Text(
                  'drag_the_arrow_to_the_right'.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward,
                  size: 35,
                )
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.grey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '(1) ${'click_on_the_green_mark'.tr()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  Image.asset(
                    'assets/image/logo-tree.png',
                    width: 100,
                    height: 100,
                  )
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.grey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '(2) ${'click_on_this_sign_at_the_bottom_of_the_screen'.tr()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  Image.asset(
                    'assets/image/helper2.png',
                    width: 75,
                    height: 75,
                  )
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.grey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '(3) ${'when_you_are_transferred_to_the_google_maps_application_click_on_this_sign_to_be_directed_to_the_route'.tr()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  Image.asset(
                    'assets/image/helper3.png',
                    width: 100,
                    height: 50,
                  )
                ],
              ),
            ),
          ),
        ].map((imagePath) {
          return Container(
            child: imagePath,
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StyleAppBarMyTrip(
        title: 'determine_your_itinerary'.tr(),
      ),
      body: currentLocation == null
          ? const Center(child: SplashScreenWaitMyTrip())
          : BackgroundSplashScreen(
              child: Column(
                children: [
                  _buildHelperCarousel(context),
                  Expanded(
                    child: SizedBox(
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(currentLocation!.latitude!,
                              currentLocation!.longitude!),
                          zoom: 10,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('currentLocation'),
                            position: LatLng(currentLocation!.latitude!,
                                currentLocation!.longitude!),
                          ),
                          Marker(
                            markerId: const MarkerId('destination'),
                            position: destination,
                            icon: treeIcon!,
                          ),
                        },
                        polylines: {
                          Polyline(
                            polylineId: const PolylineId('route'),
                            points: polylineCoordinates,
                            color: const Color.fromARGB(255, 23, 55, 82),
                            width: 5,
                          ),
                        },
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                          _zoomToFitRoute();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
