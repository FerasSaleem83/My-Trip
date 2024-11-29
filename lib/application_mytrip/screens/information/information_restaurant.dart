// ignore_for_file: unused_local_variable, use_build_context_synchronously

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_trip/application_mytrip/screens/home_screen.dart';

import 'package:my_trip/style/appbar.dart';
import 'package:my_trip/style/background_mytrip.dart';

class InformationRestaurant extends StatefulWidget {
  final String restaurantName;
  final List<String> imageUrls;
  final double latitude;
  final double longitude;
  final double numberVisitors;
  final double restaurantCapacity;
  final double budget;
  final double rate;
  final String restaurantId;
  final int numberPerson;
  final double newBudget;

  const InformationRestaurant({
    Key? key,
    required this.restaurantName,
    required this.imageUrls,
    required this.latitude,
    required this.longitude,
    required this.numberVisitors,
    required this.restaurantCapacity,
    required this.budget,
    required this.rate,
    required this.restaurantId,
    required this.numberPerson,
    required this.newBudget,
  }) : super(key: key);

  @override
  State<InformationRestaurant> createState() => _InformationRestaurantState();
}

class _InformationRestaurantState extends State<InformationRestaurant> {
  int _currentIndex = 0;
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  double totalCost = 0.0;
  Map<String, int> productQuantities = {};

  @override
  void initState() {
    super.initState();
    markers.add(
      Marker(
        markerId: const MarkerId('stored_location'),
        position: LatLng(widget.latitude, widget.longitude),
        infoWindow: InfoWindow(
          title: widget.restaurantName,
        ),
      ),
    );
  }

  void _updateTotalCost(double price, int change) {
    setState(() {
      totalCost += price * change;
      if (totalCost > widget.newBudget) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('i_went_over_budget'.tr())),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StyleAppBarMyTrip(
        title: '${'restaurant_name'.tr()}: ${widget.restaurantName}',
      ),
      body: BackgroundMyTrip(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                color: const Color.fromARGB(23, 38, 35, 35),
                child: Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: CarouselSlider(
                      options: CarouselOptions(
                        height: 300.0,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < widget.imageUrls.length; i++)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      width: 15.0,
                      height: 15.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == i
                            ? const Color.fromARGB(255, 0, 0, 0)
                            : const Color.fromARGB(255, 24, 48, 181),
                      ),
                    ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                      child: Text(
                        '${'number_of_visitors'.tr()}: ${widget.numberVisitors}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                      child: Text(
                        '${'restaurant_capacity'.tr()}: ${widget.restaurantCapacity}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${'restaurant_evaluation'.tr()}: ${widget.rate}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
              Expanded(
                flex: 2,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('app_mytrip')
                      .doc('QXmlP0NZfyfeJrKUICjq')
                      .collection('restaurants')
                      .doc(widget.restaurantId)
                      .collection('product')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.black,
                        ),
                      );
                    }
                    var products = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        var product = products[index];
                        String productId = product['product_id'];
                        String productName = product['name'];
                        double price = product['price'].toDouble();
                        int quantity = productQuantities[productId] ?? 0;

                        return Card(
                          margin: const EdgeInsets.all(10),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${'price'.tr()}: $price',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        if (quantity > 0) {
                                          setState(() {
                                            productQuantities[productId] =
                                                quantity - 1;
                                          });
                                          _updateTotalCost(price, -1);
                                        }
                                      },
                                      icon: const Icon(Icons.remove),
                                    ),
                                    Text('$quantity'),
                                    if (totalCost < widget.newBudget)
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            productQuantities[productId] =
                                                quantity + 1;
                                          });
                                          _updateTotalCost(price, 1);
                                        },
                                        icon: const Icon(Icons.add),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              if (totalCost <= widget.newBudget && totalCost != 0)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => bookingrestaurant(widget.restaurantId,
                            widget.restaurantName, widget.imageUrls),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('reservation'.tr()),
                      ),
                    ),
                    const SizedBox(width: 25),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  final String userId = FirebaseAuth.instance.currentUser!.uid;
  void bookingrestaurant(String restaurantId, String restaurantName,
      List<String> imageUrls) async {
    try {
      double updatedBudget = widget.newBudget - totalCost;

      QuerySnapshot mytripSnapshot =
          await FirebaseFirestore.instance.collection('app_mytrip').get();

      for (var tripDoc in mytripSnapshot.docs) {
        QuerySnapshot restaurantSnapshot = await tripDoc.reference
            .collection('restaurants')
            .where(FieldPath.documentId, isEqualTo: restaurantId)
            .get();

        for (var restaurantDoc in restaurantSnapshot.docs) {
          await restaurantDoc.reference.update({
            'number_visitors': FieldValue.increment(widget.numberPerson),
            'number_chairs_avilable': FieldValue.increment(widget.numberPerson),
          });
        }
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('my_booking_restaurants')
          .add(
        {
          'activate': true,
          'restaurant_id': restaurantId,
          'name': restaurantName,
          'image': imageUrls,
          'person_number': widget.numberPerson,
          'budget': updatedBudget,
          'timestamp': Timestamp.now(),
          'latitude': widget.latitude,
          'longitude': widget.longitude,
        },
      );
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('my_booking_places')
          .limit(1)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          querySnapshot.docs.first.reference.update({
            'budget': updatedBudget,
          });
        }
      });

      QuerySnapshot mytripSnapshot2 =
          await FirebaseFirestore.instance.collection('app_mytrip').get();

      for (var tripDoc in mytripSnapshot2.docs) {
        QuerySnapshot restaurantSnapshot = await tripDoc.reference
            .collection('restaurants')
            .where(FieldPath.documentId, isEqualTo: restaurantId)
            .get();

        for (var restaurantDoc in restaurantSnapshot.docs) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('information')
              .doc(userId)
              .set(
            {
              'restaurant_booking': true,
              'wallet': updatedBudget,
              'point': FieldValue.increment(1),
            },
            SetOptions(merge: true),
          );
        }
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color.fromARGB(255, 38, 35, 35),
          title: Text('succeeded'.tr(),
              style: const TextStyle(color: Colors.white, fontSize: 22)),
          content: Text('a_restaurant_reservation_has_been_made'.tr(),
              style: const TextStyle(color: Colors.white)),
          actions: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white),
                    child: Text('done'.tr(),
                        style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color.fromARGB(255, 38, 35, 35),
          title: Text('error'.tr(),
              style: const TextStyle(color: Colors.white, fontSize: 22)),
          content: Text('error_booking'.tr(),
              style: const TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('close'.tr(),
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }
}
