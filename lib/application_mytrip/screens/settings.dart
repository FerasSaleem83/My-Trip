// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_trip/application_mytrip/screens/home_screen.dart';
import 'package:my_trip/style/application_color.dart';
import 'package:my_trip/style/background_mytrip.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  void logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<bool> onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text('settings'.tr()),
          centerTitle: true,
        ),
        body: BackgroundMyTrip(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/image/mytrip-logo.png',
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 100),
                  SizedBox(
                    width: 300,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 300,
                              child: Container(
                                color: const Color.fromARGB(255, 0, 0, 0),
                                child: TextButton.icon(
                                  onPressed: () {
                                    themeNotifier.toggleTheme();
                                  },
                                  icon: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      'assets/image/color.png',
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                                  label: Text(
                                    'discoloration'.tr(),
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),
                            SizedBox(
                              width: 300,
                              child: Container(
                                color: const Color.fromARGB(255, 0, 0, 0),
                                child: TextButton.icon(
                                  onPressed: () async {
                                    await EasyLocalization.of(context)
                                        ?.setLocale(
                                      EasyLocalization.of(context)?.locale ==
                                              const Locale('en', 'US')
                                          ? const Locale('ar', 'SA')
                                          : const Locale('en', 'US'),
                                    );
                                  },
                                  icon: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      'assets/image/language.png',
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                                  label: Text(
                                    'change_language'.tr(),
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 75),
                            SizedBox(
                              width: 300,
                              child: Container(
                                color: const Color.fromARGB(255, 0, 0, 0),
                                child: TextButton.icon(
                                  onPressed: logout,
                                  icon: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      'assets/image/arrow.png',
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                                  label: Text(
                                    'logout'.tr(),
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 150),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
