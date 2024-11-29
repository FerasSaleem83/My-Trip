//ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_trip/application_khadamati/screens/account.dart';
import 'package:my_trip/application_khadamati/screens/homepage.dart';
import 'package:my_trip/application_khadamati/screens/new_order.dart';
import 'package:my_trip/application_mytrip/screens/home_screen.dart';
import 'package:my_trip/style/appbar.dart';

class MainScreenKhdamati extends StatefulWidget {
  const MainScreenKhdamati({super.key});

  @override
  State<MainScreenKhdamati> createState() => _MainScreenKhdamatiState();
}

class _MainScreenKhdamatiState extends State<MainScreenKhdamati> {
  int _selectedIndex = 0;

  Future<bool> onWillPop() async {
    if (_selectedIndex == 0) {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Text('do_you_want_to_close_khdamati_application'.tr()),
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
      const HomePage(),
      const NewOrder(),
      const Account(),
    ];

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: StyleAppBarKhdamati(
          title: Image.asset(
            'assets/image/khdamati-logo.png',
            height: 50,
          ),
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: widgetOptions,
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: const Color.fromARGB(255, 72, 119, 121),
          unselectedItemColor: const Color.fromARGB(255, 255, 255, 255),
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/image/khdamati-icon.png',
                height: 50,
                width: 50,
              ),
              label: 'home'.tr(),
              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.list_alt),
              label: 'requests'.tr(),
              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: 'my_account'.tr(),
              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: onItemTapped,
        ),
      ),
    );
  }
}
