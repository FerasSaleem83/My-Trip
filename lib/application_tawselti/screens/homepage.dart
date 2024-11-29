// ignore_for_file: deprecated_member_use, unnecessary_null_comparison

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:my_trip/application_tawselti/splashscreen/splashscreen_wait.dart';
import 'package:my_trip/style/color_splashscreen.dart';

class Homepage extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String username;
  const Homepage(
      {super.key,
      required this.latitude,
      required this.longitude,
      required this.username});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with SingleTickerProviderStateMixin {
  LocationData? currentLocation;
  Location location = Location();
  late LatLng destination;
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;
  dynamic helper = [];
  bool pressDriver = false;
  bool orderCanceled = true;
  final Completer<GoogleMapController> _controller = Completer();

  BitmapDescriptor? carIcon;
  BitmapDescriptor? treeIcon;

  @override
  void initState() {
    super.initState();
    destination = LatLng(widget.latitude, widget.longitude);
    _getCurrentLocation();
    polylinePoints = PolylinePoints();
    _loadIcons();
    _checkActiveOrder();
  }

  Future<void> _checkActiveOrder() async {
    final userOrdersCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('my_journeys');

    QuerySnapshot activeOrderSnapshot = await userOrdersCollection
        .where('activate', isEqualTo: true)
        .orderBy('orderTime', descending: true)
        .limit(1)
        .get();

    if (activeOrderSnapshot.docs.isNotEmpty) {
      var activeOrder = activeOrderSnapshot.docs.first;
      double driverLat = activeOrder['driverLocation']['latitude'].toDouble();
      double driverLng = activeOrder['driverLocation']['longitude'].toDouble();

      setState(() {
        destination = LatLng(driverLat, driverLng);
        pressDriver = true;
        orderCanceled = false;
      });

      await _getPolyline();
      await _zoomToFitRoute();
    }
  }

  Future<void> sendOrderDetailsToFirestore({
    required LatLng driverLocation,
    required String driverName,
    required String userName,
    required DateTime orderTime,
    required LatLng userLocation,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('my_journeys')
        .add({
      'activate': true,
      'driverLocation': {
        'latitude': driverLocation.latitude,
        'longitude': driverLocation.longitude,
      },
      'driverName': driverName,
      'userName': userName,
      'orderTime': orderTime,
      'userLocation': {
        'latitude': userLocation.latitude,
        'longitude': userLocation.longitude,
      },
    });
  }

  Future<void> _loadIcons() async {
    carIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(100, 100)),
      'assets/image/car.png',
    );
    treeIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(100, 100)),
      'assets/image/logo-tree.png',
    );
  }

  Future<void> _findNearestDriver() async {
    setState(() {
      pressDriver = true;
      orderCanceled = false;
    });

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('drivers')
        .where('activate', isEqualTo: true)
        .get();
    List<DocumentSnapshot> drivers = snapshot.docs;

    double shortestDistance = double.infinity;
    LatLng? nearestDriverLocation;
    String nearestDriverName = '';

    for (var driver in drivers) {
      double driverLat = driver['latitude'].toDouble();
      double driverLng = driver['longitude'].toDouble();
      String driverName = driver['name'];

      double distance = Geolocator.distanceBetween(
        currentLocation!.latitude!,
        currentLocation!.longitude!,
        driverLat,
        driverLng,
      );

      if (distance < shortestDistance) {
        shortestDistance = distance;
        nearestDriverLocation = LatLng(driverLat, driverLng);
        nearestDriverName = driverName;
      }
    }

    setState(() {
      destination = nearestDriverLocation!;
    });
    await _getPolyline();
    await _zoomToFitRoute();

    await sendOrderDetailsToFirestore(
      driverLocation: nearestDriverLocation!,
      driverName: nearestDriverName,
      userName: widget.username,
      orderTime: DateTime.now(),
      userLocation:
          LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
    );
  }

  Future<void> _cancelOrder() async {
    setState(() {
      pressDriver = false;
      orderCanceled = true;
      destination = LatLng(widget.latitude, widget.longitude);
      polylineCoordinates.clear();
    });

    await _getPolyline();
    await _zoomToFitRoute();

    final userOrdersCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('my_journeys');

    QuerySnapshot activeOrderSnapshot = await userOrdersCollection
        .where('activate', isEqualTo: true)
        .orderBy('orderTime', descending: true)
        .limit(1)
        .get();

    await activeOrderSnapshot.docs.first.reference.update({'activate': false});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentLocation == null
          ? const Center(child: SplashScreenWaitTawselti())
          : BackgroundSplashScreen(
              child: Column(
                children: [
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
                          if (orderCanceled == false)
                            Marker(
                              markerId: const MarkerId('destination'),
                              position: destination,
                              icon: carIcon!,
                            ),
                          if (orderCanceled == true)
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
                  if (!pressDriver)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _findNearestDriver,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 0, 53, 3),
                                  foregroundColor: Colors.white),
                              child: Text('order_your_car_now'.tr()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (pressDriver)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    content: Text(
                                        'do_you_want_to_cancel_the_order'.tr()),
                                    actions: <Widget>[
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextButton(
                                              onPressed: () {
                                                _cancelOrder();
                                                Navigator.pop(context);
                                              },
                                              child: Text('yes'.tr()),
                                            ),
                                          ),
                                          Expanded(
                                            child: TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text('no'.tr()),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 0, 53, 3),
                                  foregroundColor: Colors.white),
                              child: Text('cancel_order'.tr()),
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
