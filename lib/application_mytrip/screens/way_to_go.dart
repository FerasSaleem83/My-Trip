import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_trip/application_mytrip/screens/place_type.dart';
import 'package:my_trip/style/appbar.dart';
import 'package:my_trip/style/background_mytrip.dart';

class WayToGo extends StatefulWidget {
  final double budget;
  const WayToGo({
    Key? key,
    required this.budget,
  }) : super(key: key);

  @override
  State<WayToGo> createState() => _WayToGoState();
}

class _WayToGoState extends State<WayToGo> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StyleAppBarMyTrip(title: ''),
      body: BackgroundMyTrip(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 50),
                  child: Text(
                    'choose_your_way_to_go'.tr(),
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      selectedOption = 'سيارتي';
                    });
                  },
                  icon: Image.asset(
                    'assets/image/logo-car.png',
                    height: 75,
                    width: 75,
                  ),
                  label: Text('my_car'.tr()),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: selectedOption == 'سيارتي'
                        ? Colors.white
                        : Colors.black,
                    backgroundColor: selectedOption == 'سيارتي'.tr()
                        ? Colors.blue
                        : Colors.grey,
                    fixedSize: const Size(200, 150),
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      selectedOption = 'توصيلتي'.tr();
                    });
                  },
                  icon: Image.asset(
                    'assets/image/tawselti-icon.png',
                    height: 75,
                    width: 75,
                  ),
                  label: Text('tawselti'.tr()),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: selectedOption == 'توصيلتي'.tr()
                        ? Colors.white
                        : Colors.black,
                    backgroundColor: selectedOption == 'توصيلتي'.tr()
                        ? Colors.blue
                        : Colors.grey,
                    fixedSize: const Size(200, 150),
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: selectedOption != null
                      ? () {
                          if (selectedOption == 'سيارتي'.tr()) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlaceType(
                                  selectOption: 'سيارتي',
                                  budget: widget.budget,
                                  isGuest: false,
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlaceType(
                                  selectOption: 'توصيلتي',
                                  budget: widget.budget,
                                  isGuest: false,
                                ),
                              ),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    foregroundColor:
                        selectedOption == null ? Colors.black : Colors.white,
                    backgroundColor:
                        selectedOption == null ? Colors.grey : Colors.green,
                    fixedSize: const Size(150, 50),
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Text('the_next'.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
