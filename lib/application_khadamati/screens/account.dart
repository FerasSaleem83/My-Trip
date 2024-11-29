// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_trip/application_khadamati/main_screen.dart';
import 'package:my_trip/application_khadamati/splashscreen/splashscreen_wait.dart';
import 'package:my_trip/application_mytrip/authscreen.dart';
import 'package:my_trip/detailsuser.dart';
import 'package:my_trip/style/application_color.dart';
import 'package:my_trip/style/color_splashscreen.dart';
import 'package:my_trip/widget/info_card.dart';
import 'package:provider/provider.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> usernameFuture;
  late Future<int> orderCountFuture;
  Box<String>? hiveBox;

  @override
  void initState() {
    super.initState();
    initializeHive();
    usernameFuture = getUserInfo();
    orderCountFuture = getOrderCount();
  }

  Future<void> initializeHive() async {
    await Hive.initFlutter();
    hiveBox = await Hive.openBox<String>('userCache');
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserInfo() async {
    User user = FirebaseAuth.instance.currentUser!;
    String userId = user.uid;
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(userId)
        .collection('information')
        .doc(userId)
        .get();

    if (snapshot.exists) {
      hiveBox?.put('username', snapshot['username']);
      hiveBox?.put('userEmail', snapshot['email']);
      hiveBox?.put('imageUser', snapshot['image']);
      hiveBox?.put('gender', snapshot['gender']);
      hiveBox?.put('phonenumber', snapshot['phonenumber']);
      hiveBox?.put('age', snapshot['age'].toString());
      hiveBox?.put('placeResidence', snapshot['place_residence']);
      hiveBox?.put('point', snapshot['point'].toString());
      hiveBox?.put('wallet', snapshot['wallet'].toString());
    }

    return snapshot;
  }

  Future<int> getOrderCount() async {
    User user = FirebaseAuth.instance.currentUser!;
    String userId = user.uid;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('my_orders')
        .get();
    return snapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: usernameFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreenWaitKhdamati();
          } else if (snapshot.hasError) {
            return Center(
              child: Text('${'error'.tr()}: ${snapshot.error}'),
            );
          } else if (snapshot.hasData || hiveBox != null) {
            String username = snapshot.data?['username'] ??
                hiveBox?.get('username') ??
                'User';
            String userEmail = snapshot.data?['email'] ??
                hiveBox?.get('userEmail') ??
                'email@example.com';
            String imageUser =
                snapshot.data?['image'] ?? hiveBox?.get('imageUser') ?? '';
            String gender = snapshot.data?['gender'] ??
                hiveBox?.get('gender') ??
                'Not Specified';
            String phone = snapshot.data?['phonenumber'] ??
                hiveBox?.get('phonenumber') ??
                'N/A';
            int age = int.parse(
                snapshot.data?['age'].toString() ?? hiveBox?.get('age') ?? '0');
            String placeResidence = snapshot.data?['place_residence'] ??
                hiveBox?.get('placeResidence') ??
                'Unknown';
            int point = int.parse(snapshot.data?['point'].toString() ??
                hiveBox?.get('point') ??
                '0');
            double wallet = double.parse(snapshot.data?['wallet'].toString() ??
                hiveBox?.get('wallet') ??
                '0');

            return Scaffold(
              body: BackgroundSplashScreen(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: InfoCard.buildInfoCard([
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor:
                                        const Color.fromARGB(255, 0, 0, 0),
                                    backgroundImage:
                                        CachedNetworkImageProvider(imageUser),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          username,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 23,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          userEmail,
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    DetailsUser(
                                                  userName: username,
                                                  userEmail: userEmail,
                                                  imageUsers: imageUser,
                                                  userId: FirebaseAuth.instance
                                                      .currentUser!.uid,
                                                  gender: gender,
                                                  phone: phone,
                                                  age: age,
                                                  placeResidence:
                                                      placeResidence,
                                                ),
                                              ),
                                            );
                                          },
                                          icon: Image.asset(
                                            'assets/image/edit.png',
                                            width: 25,
                                            height: 25,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ], const Color.fromARGB(255, 205, 205, 205)),
                          ),
                        ],
                      ),
                      FutureBuilder<int>(
                        future: orderCountFuture,
                        builder: (context, orderSnapshot) {
                          if (orderSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SplashScreenWaitKhdamati();
                          } else if (orderSnapshot.hasError) {
                            return Text(
                                '${'error'.tr()}: ${orderSnapshot.error}');
                          } else {
                            int orderCount = orderSnapshot.data ?? 0;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: InfoCard.buildInfoCard([
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () {},
                                          icon: Image.asset(
                                              'assets/image/wallet.png',
                                              width: 40,
                                              height: 40),
                                          label: Text(
                                            '${'my_wallet'.tr()} : $wallet ${'currency'.tr()}',
                                            style: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 0, 0, 0),
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () {},
                                          icon: Image.asset(
                                              'assets/image/box.png',
                                              width: 40,
                                              height: 40),
                                          label: Text(
                                            '${'my_points'.tr()} : $point',
                                            style: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 0, 0, 0),
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () {},
                                          icon: Image.asset(
                                              'assets/image/checklist.png',
                                              width: 40,
                                              height: 40),
                                          label: Text(
                                            '${'my_orders'.tr()} : $orderCount',
                                            style: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 0, 0, 0),
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ], const Color.fromARGB(255, 205, 205, 205)),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: InfoCard.buildInfoCard([
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextButton.icon(
                                          onPressed: () {
                                            themeNotifier.toggleTheme();
                                          },
                                          icon: Image.asset(
                                            'assets/image/color.png',
                                            width: 30,
                                            height: 30,
                                          ),
                                          label: Text(
                                            'discoloration'.tr(),
                                            style: const TextStyle(
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextButton.icon(
                                          onPressed: () async {
                                            Locale newLocale =
                                                EasyLocalization.of(context)
                                                            ?.locale ==
                                                        const Locale('en', 'US')
                                                    ? const Locale('ar', 'SA')
                                                    : const Locale('en', 'US');

                                            await EasyLocalization.of(context)
                                                ?.setLocale(newLocale);

                                            Navigator.of(context)
                                                .pushAndRemoveUntil(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const MainScreenKhdamati()),
                                              (Route<dynamic> route) => false,
                                            );
                                          },
                                          icon: Image.asset(
                                            'assets/image/language.png',
                                            width: 30,
                                            height: 30,
                                          ),
                                          label: Text(
                                            'change_language'.tr(),
                                            style: const TextStyle(
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ], const Color.fromARGB(255, 205, 205, 205)),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: InfoCard.buildInfoCard([
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton.icon(
                                      onPressed: () async {
                                        await FirebaseAuth.instance.signOut();
                                        await Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const AuthScreen(),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.power_settings_new,
                                        color: Colors.red,
                                        size: 27,
                                      ),
                                      label: Text(
                                        'logout'.tr(),
                                        style: const TextStyle(
                                          color: Color.fromARGB(255, 0, 0, 0),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ], const Color.fromARGB(255, 205, 205, 205)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Center(
              child: SplashScreenWaitKhdamati(),
            );
          }
        });
  }
}
