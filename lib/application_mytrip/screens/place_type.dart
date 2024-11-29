import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_trip/application_mytrip/screens/places.dart';
import 'package:my_trip/style/appbar.dart';
import 'package:my_trip/style/background_mytrip.dart';

class PlaceType extends StatefulWidget {
  final String selectOption;
  final double budget;
  final bool isGuest;
  const PlaceType({
    super.key,
    required this.selectOption,
    required this.budget,
    required this.isGuest,
  });

  @override
  State<PlaceType> createState() => _PlaceTypeState();
}

class _PlaceTypeState extends State<PlaceType> {
  bool heritageSelected = false;
  bool entertainmentSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StyleAppBarMyTrip(title: ''),
      body: BackgroundMyTrip(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
                    child: Text(
                      'you_can_choose_one_or_more'.tr(),
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                heritageSelected = !heritageSelected;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: heritageSelected
                                  ? Colors.white
                                  : Colors.black,
                              backgroundColor:
                                  heritageSelected ? Colors.blue : Colors.grey,
                              fixedSize: const Size(150, 150),
                              shape: ContinuousRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircleAvatar(
                                  backgroundImage: AssetImage(
                                    'assets/image/logo-heritage-places.jpeg',
                                  ),
                                  radius: 40,
                                ),
                                Text(
                                  'heritage_places'.tr(),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 25),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                entertainmentSelected = !entertainmentSelected;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: entertainmentSelected
                                  ? Colors.white
                                  : Colors.black,
                              backgroundColor: entertainmentSelected
                                  ? Colors.blue
                                  : Colors.grey,
                              fixedSize: const Size(150, 150),
                              shape: ContinuousRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircleAvatar(
                                  backgroundImage: AssetImage(
                                    'assets/image/entertainment.png',
                                  ),
                                  radius: 40,
                                  backgroundColor:
                                      Color.fromARGB(255, 21, 163, 188),
                                ),
                                Text(
                                  'entertainment_places'.tr(),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                  ElevatedButton(
                    onPressed: (heritageSelected || entertainmentSelected)
                        ? () {
                            if (heritageSelected && entertainmentSelected) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Places(
                                    selectOption: widget.selectOption,
                                    budget: widget.budget,
                                    isGuest: widget.isGuest,
                                    typePlace: 'all',
                                  ),
                                ),
                              );
                            } else if (heritageSelected) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Places(
                                    selectOption: widget.selectOption,
                                    budget: widget.budget,
                                    isGuest: widget.isGuest,
                                    typePlace: 'heritage',
                                  ),
                                ),
                              );
                            } else if (entertainmentSelected) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Places(
                                    selectOption: widget.selectOption,
                                    budget: widget.budget,
                                    isGuest: widget.isGuest,
                                    typePlace: 'entertainment',
                                  ),
                                ),
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: heritageSelected == false
                          ? (entertainmentSelected == false
                              ? Colors.black
                              : Colors.white)
                          : Colors.white,
                      backgroundColor: heritageSelected == false
                          ? (entertainmentSelected == false
                              ? Colors.grey
                              : Colors.green)
                          : Colors.green,
                      fixedSize: const Size(200, 75),
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Text('the_next'.tr()),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
