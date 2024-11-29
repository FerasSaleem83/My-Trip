// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_trip/application_mytrip/screens/home_screen.dart';
import 'package:my_trip/application_tawselti/screens/account.dart';
import 'package:my_trip/application_tawselti/screens/history.dart';
import 'package:my_trip/application_tawselti/screens/homepage.dart';
import 'package:my_trip/style/appbar.dart';

class MainScreenTawselti extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String username;

  const MainScreenTawselti({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.username,
  });

  @override
  State<MainScreenTawselti> createState() => _MainScreenTawseltiState();
}

class _MainScreenTawseltiState extends State<MainScreenTawselti> {
  int _selectedIndex = 0;

  Future<bool> onWillPop() async {
    if (_selectedIndex == 0) {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content:
                  Text('do_you_want_to_close_the_Tawasliti_application'.tr()),
              actions: <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        },
                        child: Text('yes'.tr()),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('no'.tr()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ) ??
          false;
    } else {
      setState(() {
        _selectedIndex = 0;
      });
      return false;
    }
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      Homepage(
        latitude: widget.latitude,
        longitude: widget.longitude,
        username: widget.username,
      ),
      const History(),
      const Account(),
    ];
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: StyleAppBarTawselti(
          title: Image.asset(
            'assets/image/tawselti-title.png',
            height: 50,
          ),
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: widgetOptions,
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color.fromARGB(255, 1, 64, 7),
          selectedItemColor: const Color.fromARGB(255, 55, 255, 0),
          unselectedItemColor: const Color.fromARGB(255, 255, 253, 253),
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/image/tawselti-icon.png',
                height: 50,
                width: 50,
              ),
              label: 'home'.tr(),
              backgroundColor: const Color.fromARGB(255, 1, 64, 7),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.history),
              label: 'history'.tr(),
              backgroundColor: const Color.fromARGB(255, 1, 64, 7),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: 'my_account'.tr(),
              backgroundColor: const Color.fromARGB(255, 1, 64, 7),
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: onItemTapped,
        ),
      ),
    );
  }
}
