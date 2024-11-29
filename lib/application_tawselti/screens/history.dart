import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_trip/application_tawselti/splashscreen/splashscreen_wait.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getOrderHistory() {
    return _firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('my_journeys')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getOrderHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: SplashScreenWaitTawselti());
          }

          if (snapshot.hasError) {
            return Center(child: Text('error_upload'.tr()));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('no_order'.tr()));
          }

          final orderList = snapshot.data!;
          return ListView.builder(
            itemCount: orderList.length,
            itemBuilder: (context, index) {
              final order = orderList[index];
              final userName = order['userName'] ?? 'not_avilable'.tr();
              final driverName = order['driverName'] ?? 'not_avilable'.tr();
              final orderTime = order['orderTime'] != null
                  ? (order['orderTime'] as Timestamp).toDate()
                  : null;
              final orderStatus =
                  order['activate'] == true ? 'activate'.tr() : 'canceled'.tr();

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text('${'oreder_in'.tr()} $userName'),
                  subtitle: Text('${'driver'.tr()}: $driverName\n'
                      '${'order_time'.tr()}: ${orderTime != null ? orderTime.toString() : 'not_avilable'.tr()}\n'
                      '${'order_state'.tr()}: $orderStatus'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
