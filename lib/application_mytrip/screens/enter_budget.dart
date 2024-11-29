import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_trip/application_mytrip/screens/way_to_go.dart';
import 'package:my_trip/style/appbar.dart';
import 'package:my_trip/style/background_mytrip.dart';

class PageBudget extends StatefulWidget {
  const PageBudget({super.key});

  @override
  State<PageBudget> createState() => _PageBudgetState();
}

class _PageBudgetState extends State<PageBudget> {
  final TextEditingController budgetController = TextEditingController();
  bool isButtonActive = false;

  @override
  void initState() {
    super.initState();

    budgetController.addListener(() {
      final isFilled = budgetController.text.isNotEmpty;
      setState(() {
        isButtonActive = isFilled;
      });
    });
  }

  @override
  void dispose() {
    budgetController.dispose();
    super.dispose();
  }

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 50),
                  child: Text(
                    'enter_your_appropriate_budget_for_the_trip'.tr(),
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: TextFormField(
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'my_budget'.tr(),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 150),
                ElevatedButton(
                  onPressed: isButtonActive
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WayToGo(
                                budget:
                                    double.parse(budgetController.text.trim()),
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    foregroundColor:
                        isButtonActive ? Colors.white : Colors.black,
                    backgroundColor:
                        isButtonActive ? Colors.green : Colors.grey,
                    fixedSize: const Size(200, 75),
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
