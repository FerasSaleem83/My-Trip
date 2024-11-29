import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_trip/application_mytrip/screens/login/login_screen.dart';
import 'package:my_trip/style/appbar.dart';
import 'package:my_trip/style/background_mytrip.dart';

class MainScreenMyTrip extends StatefulWidget {
  const MainScreenMyTrip({super.key});

  @override
  State<MainScreenMyTrip> createState() => _MainScreenMyTripState();
}

class _MainScreenMyTripState extends State<MainScreenMyTrip> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StyleAppBarMyTrip(
        title: '',
        actionBar: IconButton(
          onPressed: () async {
            await EasyLocalization.of(context)?.setLocale(
              EasyLocalization.of(context)?.locale == const Locale('en', 'US')
                  ? const Locale('ar', 'SA')
                  : const Locale('en', 'US'),
            );
          },
          icon: Image.asset(
            'assets/image/language.png',
            width: 40,
            height: 40,
          ),
        ),
      ),
      body: BackgroundMyTrip(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                icon: Image.asset(
                  'assets/image/booking.png',
                  height: 75,
                  width: 75,
                ),
                label: Text('reservation'.tr()),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.grey,
                  fixedSize: const Size(250, 150),
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
