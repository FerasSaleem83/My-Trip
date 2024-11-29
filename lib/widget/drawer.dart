// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_trip/application_mytrip/screens/settings.dart';
import 'package:my_trip/application_mytrip/authscreen.dart';

class MyDrawer extends StatefulWidget {
  final AsyncSnapshot<dynamic> snapshot;
  final String drawemail;
  final String drawusername;
  final String? imageusers;
  final int point;
  final double wallet;

  final Function() detailsUser;
  const MyDrawer({
    super.key,
    required this.snapshot,
    required this.drawemail,
    required this.drawusername,
    this.imageusers,
    required this.detailsUser,
    required this.point,
    required this.wallet,
  });

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String imagepersonal =
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcShB7IwN9gr4q2Tn-1CRfbgANRN-8SWlYMMy9iq467T1A&s';

  void logoutUser() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color.fromARGB(255, 153, 197, 199),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 46, 75, 76),
              ),
              accountName: Text(
                widget.drawusername,
              ),
              accountEmail: Text(widget.drawemail),
              currentAccountPicture: GestureDetector(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    widget.imageusers ?? imagepersonal,
                  ),
                  radius: 100,
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(35, 0, 35, 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: widget.detailsUser,
                    icon: Image.asset(
                      'assets/image/account.png',
                      width: 40,
                      height: 40,
                    ),
                    label: Text(
                      'my_account'.tr(),
                      style: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(35, 0, 35, 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/image/wallet.png',
                      width: 40,
                      height: 40,
                    ),
                    label: Text(
                      '${'my_wallet'.tr()}: ${widget.wallet}',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(35, 0, 35, 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/image/box.png',
                      width: 40,
                      height: 40,
                    ),
                    label: Text(
                      '${'my_rewards'.tr()}: ${widget.point}',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(35, 0, 35, 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingPage(),
                        ),
                      );
                    },
                    icon: Image.asset(
                      'assets/image/setting.png',
                      width: 40,
                      height: 40,
                    ),
                    label: Text(
                      'settings'.tr(),
                      style: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.fromLTRB(35, 0, 35, 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: logoutUser,
                    icon: Image.asset(
                      'assets/image/arrow.png',
                      width: 40,
                      height: 40,
                    ),
                    label: Text(
                      'logout'.tr(),
                      style: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.bold,
                      ),
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
