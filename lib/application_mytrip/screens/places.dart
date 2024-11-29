import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_trip/application_mytrip/screens/information/information_place.dart';
import 'package:my_trip/application_mytrip/splashscreen/splashscreen_wait.dart';
import 'package:my_trip/style/appbar.dart';
import 'package:my_trip/style/background_mytrip.dart';
import 'package:my_trip/style/text.dart';

class Places extends StatefulWidget {
  final String selectOption;
  final double budget;
  final bool isGuest;
  final String typePlace;
  const Places(
      {super.key,
      required this.selectOption,
      required this.budget,
      required this.isGuest,
      required this.typePlace});

  @override
  State<Places> createState() => _PlacesState();
}

class _PlacesState extends State<Places> {
  Stream<List<DocumentSnapshot>>? tripsStream;
  final bool _isUploading = false;
  bool isPress = false;
  bool isFilter = false;
  String? selectedRegistrationPlace;
  Set<Marker> markers = {};
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool markerTappedOnce = false;
  double? distanceInMeters;
  double? cost;
  double? adjustedBudget;
  double? personCost;
  int? numberOfPersons;
  Position? currentPosition;
  double remainingBudget = 0;

  void uploadData() async {
    if (widget.isGuest == false) {
      if (widget.selectOption == 'سيارتي') {
        adjustedBudget = widget.budget;

        currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        if (widget.typePlace == 'all') {
          FirebaseFirestore.instance
              .collection('app_mytrip')
              .snapshots()
              .listen((snapshot) async {
            List<DocumentSnapshot> filteredTrips = [];

            for (var doc in snapshot.docs) {
              var placesSnapshot = await doc.reference
                  .collection('places')
                  .where('activate', isEqualTo: true)
                  .get();
              for (var trip in placesSnapshot.docs) {
                double destinationLat = trip['latitude'].toDouble();
                double destinationLng = trip['longitude'].toDouble();

                double distanceInMeters = Geolocator.distanceBetween(
                  currentPosition!.latitude,
                  currentPosition!.longitude,
                  destinationLat,
                  destinationLng,
                );

                double distanceInKm = distanceInMeters / 1000;

                double travelCost = (distanceInKm / 5).ceil() * 2;

                double newBudget = adjustedBudget! - travelCost;

                if (newBudget <= widget.budget && newBudget > 0) {
                  filteredTrips.add(trip);
                }
              }
            }

            setState(() {
              tripsStream = Stream.value(filteredTrips);
            });
          });
        } else if (widget.typePlace == 'entertainment') {
          FirebaseFirestore.instance
              .collection('app_mytrip')
              .snapshots()
              .listen((snapshot) async {
            List<DocumentSnapshot> filteredTrips = [];

            for (var doc in snapshot.docs) {
              var placesSnapshot = await doc.reference
                  .collection('places')
                  .where('entertainment', isEqualTo: true)
                  .where('activate', isEqualTo: true)
                  .get();

              for (var trip in placesSnapshot.docs) {
                double destinationLat = trip['latitude'].toDouble();
                double destinationLng = trip['longitude'].toDouble();

                double distanceInMeters = Geolocator.distanceBetween(
                  currentPosition!.latitude,
                  currentPosition!.longitude,
                  destinationLat,
                  destinationLng,
                );

                double distanceInKm = distanceInMeters / 1000;

                double travelCost = (distanceInKm / 5).ceil() * 2;

                double newBudget = adjustedBudget! - travelCost;
                if (newBudget <= widget.budget && newBudget > 0) {
                  filteredTrips.add(trip);
                }
              }
            }
            setState(() {
              tripsStream = Stream.value(filteredTrips);
            });
          });
        } else {
          FirebaseFirestore.instance
              .collection('app_mytrip')
              .snapshots()
              .listen((snapshot) async {
            List<DocumentSnapshot> filteredTrips = [];

            for (var doc in snapshot.docs) {
              var placesSnapshot = await doc.reference
                  .collection('places')
                  .where('heritage', isEqualTo: true)
                  .where('activate', isEqualTo: true)
                  .get();

              for (var trip in placesSnapshot.docs) {
                double destinationLat = trip['latitude'].toDouble();
                double destinationLng = trip['longitude'].toDouble();

                double distanceInMeters = Geolocator.distanceBetween(
                  currentPosition!.latitude,
                  currentPosition!.longitude,
                  destinationLat,
                  destinationLng,
                );

                double distanceInKm = distanceInMeters / 1000;

                double travelCost = (distanceInKm / 5).ceil() * 2;

                double newBudget = adjustedBudget! - travelCost;

                if (newBudget <= widget.budget && newBudget > 0) {
                  filteredTrips.add(trip);
                }
              }
            }
            setState(() {
              tripsStream = Stream.value(filteredTrips);
            });
          });
        }
      } else {
        adjustedBudget = widget.budget;

        currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        if (widget.typePlace == 'all') {
          FirebaseFirestore.instance
              .collection('app_mytrip')
              .snapshots()
              .listen((snapshot) async {
            List<DocumentSnapshot> filteredTrips = [];

            for (var doc in snapshot.docs) {
              var placesSnapshot = await doc.reference
                  .collection('places')
                  .where('activate', isEqualTo: true)
                  .get();

              for (var trip in placesSnapshot.docs) {
                double destinationLat = trip['latitude'].toDouble();
                double destinationLng = trip['longitude'].toDouble();

                double distanceInMeters = Geolocator.distanceBetween(
                  currentPosition!.latitude,
                  currentPosition!.longitude,
                  destinationLat,
                  destinationLng,
                );

                double distanceInKm = (distanceInMeters / 1000) + 13;
                double travelCost = (distanceInKm / 5).ceil() * 2;
                double newTravelCost = travelCost * 1.5;
                double newBudget = adjustedBudget! - newTravelCost;

                if (newBudget <= widget.budget && newBudget > 0) {
                  filteredTrips.add(trip);
                }
              }
            }

            setState(() {
              tripsStream = Stream.value(filteredTrips);
            });
          });
        } else if (widget.typePlace == 'entertainment') {
          FirebaseFirestore.instance
              .collection('app_mytrip')
              .snapshots()
              .listen((snapshot) async {
            List<DocumentSnapshot> filteredTrips = [];

            for (var doc in snapshot.docs) {
              var placesSnapshot = await doc.reference
                  .collection('places')
                  .where('entertainment', isEqualTo: true)
                  .where('activate', isEqualTo: true)
                  .get();

              for (var trip in placesSnapshot.docs) {
                double destinationLat = trip['latitude'].toDouble();
                double destinationLng = trip['longitude'].toDouble();

                double distanceInMeters = Geolocator.distanceBetween(
                  currentPosition!.latitude,
                  currentPosition!.longitude,
                  destinationLat,
                  destinationLng,
                );

                double distanceInKm = (distanceInMeters / 1000) + 13;
                double travelCost = (distanceInKm / 5).ceil() * 2;
                double newTravelCost = travelCost * 1.5;
                double newBudget = adjustedBudget! - newTravelCost;

                if (newBudget <= widget.budget && newBudget > 0) {
                  filteredTrips.add(trip);
                }
              }
            }
            setState(() {
              tripsStream = Stream.value(filteredTrips);
            });
          });
        } else {
          FirebaseFirestore.instance
              .collection('app_mytrip')
              .snapshots()
              .listen((snapshot) async {
            List<DocumentSnapshot> filteredTrips = [];

            for (var doc in snapshot.docs) {
              var placesSnapshot = await doc.reference
                  .collection('places')
                  .where('heritage', isEqualTo: true)
                  .where('activate', isEqualTo: true)
                  .get();

              for (var trip in placesSnapshot.docs) {
                double destinationLat = trip['latitude'].toDouble();
                double destinationLng = trip['longitude'].toDouble();

                double distanceInMeters = Geolocator.distanceBetween(
                  currentPosition!.latitude,
                  currentPosition!.longitude,
                  destinationLat,
                  destinationLng,
                );

                double distanceInKm = (distanceInMeters / 1000) + 13;
                double travelCost = (distanceInKm / 5).ceil() * 2;
                double newTravelCost = travelCost * 1.5;
                double newBudget = adjustedBudget! - newTravelCost;

                if (newBudget <= widget.budget && newBudget > 0) {
                  filteredTrips.add(trip);
                }
              }
            }
            setState(() {
              tripsStream = Stream.value(filteredTrips);
            });
          });
        }
      }
    } else {
      if (widget.typePlace == 'all') {
        FirebaseFirestore.instance
            .collection('app_mytrip')
            .snapshots()
            .listen((snapshot) async {
          List<DocumentSnapshot> filteredTrips = [];

          for (var doc in snapshot.docs) {
            var placesSnapshot = await doc.reference
                .collection('places')
                .where('activate', isEqualTo: true)
                .get();

            filteredTrips.addAll(placesSnapshot.docs);
          }

          setState(() {
            tripsStream = Stream.value(filteredTrips);
          });
        });
      } else if (widget.typePlace == 'entertainment') {
        FirebaseFirestore.instance
            .collection('app_mytrip')
            .snapshots()
            .listen((snapshot) async {
          List<DocumentSnapshot> filteredTrips = [];

          for (var doc in snapshot.docs) {
            var placesSnapshot = await doc.reference
                .collection('places')
                .where('entertainment', isEqualTo: true)
                .where('activate', isEqualTo: true)
                .get();

            // إضافة العناصر المفعّلة والتي تتوافق مع الشرط إلى filteredTrips
            filteredTrips.addAll(placesSnapshot.docs);
          }

          setState(() {
            tripsStream = Stream.value(filteredTrips);
          });
        });
      } else {
        FirebaseFirestore.instance
            .collection('app_mytrip')
            .snapshots()
            .listen((snapshot) async {
          List<DocumentSnapshot> filteredTrips = [];

          for (var doc in snapshot.docs) {
            var placesSnapshot = await doc.reference
                .collection('places')
                .where('heritage', isEqualTo: true)
                .where('activate', isEqualTo: true)
                .get();

            // إضافة العناصر المفعّلة والتي تتوافق مع الشرط إلى filteredTrips
            filteredTrips.addAll(placesSnapshot.docs);
          }

          setState(() {
            tripsStream = Stream.value(filteredTrips);
          });
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    uploadData();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectOption == 'سيارتي') {
      return Scaffold(
        appBar: StyleAppBarMyTrip(
          title: widget.typePlace == 'all'
              ? 'heritage_and_entertainment_places'.tr()
              : widget.typePlace == 'entertainment'
                  ? 'entertainment_places'.tr()
                  : 'heritage_places'.tr(),
          actionBar: IconButton(
              onPressed: () {
                setState(() {
                  isFilter = !isFilter;
                });
              },
              icon: isFilter
                  ? const Icon(Icons.close)
                  : const Icon(Icons.filter_list_rounded)),
        ),
        body: BackgroundMyTrip(
          child: tripsStream == null
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                )
              : StreamBuilder<List<DocumentSnapshot>>(
                  stream: tripsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SplashScreenWaitMyTrip();
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('${'error'.tr()}: ${snapshot.error}'),
                      );
                    } else if (_isUploading) {
                      return const CircularProgressIndicator(
                        color: Colors.black,
                      );
                    } else if (snapshot.hasData) {
                      List<DocumentSnapshot> trips = snapshot.data!;
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              if (widget.isGuest == false)
                                TextTitle(
                                    title:
                                        '${'your_budget'.tr()}: $adjustedBudget'),
                              if (isFilter)
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: selectedRegistrationPlace,
                                        items: selectSearch.map(
                                          (String place) {
                                            return DropdownMenuItem<String>(
                                              value: place,
                                              child: Text(
                                                place,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            );
                                          },
                                        ).toList(),
                                        onChanged: (selectedPlace) {
                                          setState(() {
                                            selectedRegistrationPlace =
                                                selectedPlace;
                                            if (selectedRegistrationPlace ==
                                                'evaluation'.tr()) {
                                              trips.sort((a, b) => b['rate']
                                                  .compareTo(a['rate']));
                                            } else if (selectedRegistrationPlace ==
                                                'number_of_visitors'.tr()) {
                                              trips.sort((a, b) => b[
                                                      'number_visitors']
                                                  .compareTo(
                                                      a['number_visitors']));
                                            }
                                          });
                                        },
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                        decoration: InputDecoration(
                                          labelStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                          hintText: 'filter'.tr(),
                                          fillColor: Colors.grey[100],
                                          filled: true,
                                          alignLabelWithHint: true,
                                          floatingLabelAlignment:
                                              FloatingLabelAlignment.center,
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Colors.black,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            vertical: 5.0,
                                            horizontal: 20,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Colors.blue,
                                              width: 2.5,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          selectedRegistrationPlace = null;
                                        });
                                      },
                                      icon: const Icon(Icons.delete),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 15),
                              Expanded(
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                    mainAxisSpacing: 2,
                                    childAspectRatio: 2,
                                    mainAxisExtent: 200,
                                  ),
                                  itemCount: trips.length,
                                  itemBuilder: (context, index) {
                                    var trip = trips[index];
                                    String placeId = trip['place_id'];
                                    String placeName = trip['name'];
                                    String placeDetails = trip['details'];
                                    final List<String> imageUrls =
                                        (trip['image'] as List).cast<String>();
                                    int numberVisitors =
                                        trip['number_visitors'];
                                    double placeRate = trip['rate'].toDouble();

                                    double destinationLat =
                                        trip['latitude'].toDouble();
                                    double destinationLng =
                                        trip['longitude'].toDouble();
                                    double distanceInMeters =
                                        Geolocator.distanceBetween(
                                      currentPosition!.latitude,
                                      currentPosition!.longitude,
                                      destinationLat,
                                      destinationLng,
                                    );

                                    double distanceInKm =
                                        (distanceInMeters / 1000);
                                    double travelCost =
                                        ((distanceInKm / 5)).ceil() * 2;
                                    double newBudget =
                                        adjustedBudget! - travelCost;

                                    return InkWell(
                                      onTap: widget.isGuest == false
                                          ? () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      InformationPlace(
                                                          oldBudget:
                                                              widget.budget,
                                                          placeName: placeName,
                                                          imageUrls: imageUrls,
                                                          latitude:
                                                              destinationLat,
                                                          longitude:
                                                              destinationLng,
                                                          numberVisitors:
                                                              numberVisitors,
                                                          newBudget: newBudget,
                                                          placeId: placeId,
                                                          placeDetails:
                                                              placeDetails,
                                                          selectOption: widget
                                                              .selectOption),
                                                ),
                                              );
                                            }
                                          : () {},
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(75.0),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 6.0,
                                            ),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(35)),
                                            gradient: const LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                                Colors.white,
                                                Colors.white,
                                              ],
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: SizedBox(
                                              width: 320,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 135,
                                                    height: 135,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  25)),
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                            imageUrls[0]),
                                                        fit: BoxFit.fill,
                                                        opacity: 0.8,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            placeName,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            '${'number_of_visitors_now'.tr()}: $numberVisitors',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                '${'evaluation'.tr()} : $placeRate ',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              const Icon(
                                                                Icons.star,
                                                                size: 15,
                                                                color: Colors
                                                                    .yellow,
                                                              ),
                                                            ],
                                                          ),
                                                          Text(
                                                            '${'round_trip_cost'.tr()}: ${travelCost.toStringAsFixed(2)} ${'currency'.tr()}', // عرض تكلفة الذهاب
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            '${'distance'.tr()}: ${distanceInKm.toStringAsFixed(2)} ${'unit_distance'.tr()}', // عرض تكلفة الذهاب
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Center(
                        child: Text('no_data'.tr()),
                      );
                    }
                  },
                ),
        ),
      );
    } else {
      return Scaffold(
        appBar: StyleAppBarMyTrip(
          title: widget.typePlace == 'all'
              ? 'heritage_and_entertainment_places'.tr()
              : widget.typePlace == 'entertainment'
                  ? 'entertainment_places'.tr()
                  : 'heritage_places'.tr(),
          actionBar: IconButton(
              onPressed: () {
                setState(() {
                  isFilter = !isFilter;
                });
              },
              icon: isFilter
                  ? const Icon(Icons.close)
                  : const Icon(Icons.filter_list_rounded)),
        ),
        body: BackgroundMyTrip(
          child: tripsStream == null
              ? const Center(
                  child: SplashScreenWaitMyTrip(),
                )
              : StreamBuilder<List<DocumentSnapshot>>(
                  stream: tripsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SplashScreenWaitMyTrip();
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('${'error'.tr()}: ${snapshot.error}'),
                      );
                    } else if (_isUploading) {
                      return const SplashScreenWaitMyTrip();
                    } else if (snapshot.hasData) {
                      List<DocumentSnapshot> trips = snapshot.data!;
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              TextTitle(
                                  title:
                                      '${'your_budget'.tr()}: $adjustedBudget'),
                              if (isFilter)
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: selectedRegistrationPlace,
                                        items: selectSearch.map(
                                          (String place) {
                                            return DropdownMenuItem<String>(
                                              value: place,
                                              child: Text(
                                                place,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            );
                                          },
                                        ).toList(),
                                        onChanged: (selectedPlace) {
                                          setState(() {
                                            selectedRegistrationPlace =
                                                selectedPlace;
                                            if (selectedRegistrationPlace ==
                                                'evaluation'.tr()) {
                                              trips.sort((a, b) => b['rate']
                                                  .compareTo(a['rate']));
                                            } else if (selectedRegistrationPlace ==
                                                'number_of_visitors'.tr()) {
                                              trips.sort((a, b) => b[
                                                      'number_visitors']
                                                  .compareTo(
                                                      a['number_visitors']));
                                            }
                                          });
                                        },
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                        decoration: InputDecoration(
                                          labelStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                          hintText: 'filter'.tr(),
                                          fillColor: Colors.grey[100],
                                          filled: true,
                                          alignLabelWithHint: true,
                                          floatingLabelAlignment:
                                              FloatingLabelAlignment.center,
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Colors.black,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            vertical: 5.0,
                                            horizontal: 20,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Colors.blue,
                                              width: 2.5,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          selectedRegistrationPlace = null;
                                        });
                                      },
                                      icon: const Icon(Icons.delete),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 15),
                              Expanded(
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                    mainAxisSpacing: 2,
                                    childAspectRatio: 2,
                                    mainAxisExtent: 200,
                                  ),
                                  itemCount: trips.length,
                                  itemBuilder: (context, index) {
                                    var trip = trips[index];
                                    String placeId = trip['place_id'];
                                    String placeName = trip['name'];
                                    String placeDetails = trip['details'];
                                    final List<String> imageUrls =
                                        (trip['image'] as List).cast<String>();
                                    int numberVisitors =
                                        trip['number_visitors'];
                                    double placeRate = trip['rate'].toDouble();

                                    double destinationLat =
                                        trip['latitude'].toDouble();
                                    double destinationLng =
                                        trip['longitude'].toDouble();
                                    double distanceInMeters =
                                        Geolocator.distanceBetween(
                                      currentPosition!.latitude,
                                      currentPosition!.longitude,
                                      destinationLat,
                                      destinationLng,
                                    );

                                    double distanceInKm =
                                        (distanceInMeters / 1000) + 13;
                                    double travelCost =
                                        ((distanceInKm / 5)).ceil() * 2;

                                    double newTravelCost = travelCost * 1.5;

                                    double newBudget =
                                        widget.budget - newTravelCost;

                                    return InkWell(
                                      onTap: widget.isGuest == false
                                          ? () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      InformationPlace(
                                                          oldBudget:
                                                              widget.budget,
                                                          placeName: placeName,
                                                          imageUrls: imageUrls,
                                                          latitude:
                                                              destinationLat,
                                                          longitude:
                                                              destinationLng,
                                                          numberVisitors:
                                                              numberVisitors,
                                                          newBudget: newBudget,
                                                          placeId: placeId,
                                                          placeDetails:
                                                              placeDetails,
                                                          selectOption: widget
                                                              .selectOption),
                                                ),
                                              );
                                            }
                                          : () {},
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(75.0),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 6.0,
                                            ),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(35)),
                                            gradient: const LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                                Colors.white,
                                                Colors.white,
                                              ],
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: SizedBox(
                                              width: 320,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 135,
                                                    height: 135,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  25)),
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                            imageUrls[0]),
                                                        fit: BoxFit.fill,
                                                        opacity: 0.8,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            placeName,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            '${'number_of_visitors_now'.tr()}: $numberVisitors',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                '${'evaluation'.tr()} : $placeRate ',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              const Icon(
                                                                Icons.star,
                                                                size: 15,
                                                                color: Colors
                                                                    .yellow,
                                                              ),
                                                            ],
                                                          ),
                                                          Text(
                                                            '${'round_trip_cost'.tr()}: ${newTravelCost.toStringAsFixed(2)} ${'currency'.tr()}', // عرض تكلفة الذهاب

                                                            style:
                                                                const TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            '${'distance'.tr()}: ${distanceInKm.toStringAsFixed(2)} ${'unit_distance'.tr()}', // عرض تكلفة الذهاب
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Center(
                        child: Text('no_data'.tr()),
                      );
                    }
                  },
                ),
        ),
      );
    }
  }
}

final List<String> selectSearch = [
  'evaluation'.tr(),
  'number_of_visitors'.tr()
];
