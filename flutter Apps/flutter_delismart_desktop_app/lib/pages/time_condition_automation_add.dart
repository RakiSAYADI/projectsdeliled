import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';
import 'package:get/get.dart';

class TimeConditionAutomationAdd extends StatefulWidget {
  const TimeConditionAutomationAdd({Key? key}) : super(key: key);

  @override
  State<TimeConditionAutomationAdd> createState() => _TimeConditionAutomationAddState();
}

class _TimeConditionAutomationAddState extends State<TimeConditionAutomationAdd> {
  String automationTimeYear = '2022';
  String automationTimeMonth = '01';
  String automationTimeDay = '01';

  String automationTimeHour = '00';
  String automationTimeMinute = '00';

  String loops = '1111111';

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    List<bool> days = [charToBool(loops[0]), charToBool(loops[1]), charToBool(loops[2]), charToBool(loops[3]), charToBool(loops[4]), charToBool(loops[5]), charToBool(loops[6])];
    List<Color> daysColor = [
      days[0] ? Colors.green : Colors.red,
      days[1] ? Colors.green : Colors.red,
      days[2] ? Colors.green : Colors.red,
      days[3] ? Colors.green : Colors.red,
      days[4] ? Colors.green : Colors.red,
      days[5] ? Colors.green : Colors.red,
      days[6] ? Colors.green : Colors.red
    ];
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(addTimePageTitleTextLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                timeAndDatePageTitleTextLanguageArray[languageArrayIdentifier],
                style: TextStyle(color: Colors.grey[800], fontSize: heightScreen * 0.03 + widthScreen * 0.03),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: heightScreen * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<String>(
                    value: automationTimeHour,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 16,
                    itemHeight: 50,
                    style: TextStyle(color: Colors.grey[800], fontSize: heightScreen * 0.015 + widthScreen * 0.015),
                    onChanged: (String? data) {
                      setState(() {
                        automationTimeHour = data!;
                      });
                    },
                    items: hour.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[800], fontSize: heightScreen * 0.015 + widthScreen * 0.015),
                        ),
                      );
                    }).toList(),
                  ),
                  Text(
                    ':',
                    style: TextStyle(color: Colors.grey[800], fontSize: heightScreen * 0.015 + widthScreen * 0.015),
                    textAlign: TextAlign.center,
                  ),
                  DropdownButton<String>(
                    value: automationTimeMinute,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 16,
                    itemHeight: 50,
                    style: TextStyle(color: Colors.grey[800], fontSize: heightScreen * 0.015 + widthScreen * 0.015),
                    onChanged: (String? data) {
                      setState(() {
                        automationTimeMinute = data!;
                      });
                    },
                    items: minute.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[800], fontSize: heightScreen * 0.015 + widthScreen * 0.015),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: heightScreen * 0.05),
              ToggleButtons(
                borderRadius: BorderRadius.circular(18.0),
                isSelected: days,
                onPressed: (int index) {
                  String newLoops = '';
                  for (int i = 0; i < loops.length; i++) {
                    if (i == index) {
                      newLoops += changeCharState(loops[index]);
                    } else {
                      newLoops += loops[i];
                    }
                  }
                  loops = newLoops;
                  setState(() {});
                },
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(sundayTextLanguageArray[languageArrayIdentifier],
                        style: TextStyle(fontSize: widthScreen * 0.015, color: daysColor[0], fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(mondayTextLanguageArray[languageArrayIdentifier],
                        style: TextStyle(fontSize: widthScreen * 0.015, color: daysColor[1], fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(tuesdayTextLanguageArray[languageArrayIdentifier],
                        style: TextStyle(fontSize: widthScreen * 0.015, color: daysColor[2], fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(wednesdayTextLanguageArray[languageArrayIdentifier],
                        style: TextStyle(fontSize: widthScreen * 0.015, color: daysColor[3], fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(thursdayTextLanguageArray[languageArrayIdentifier],
                        style: TextStyle(fontSize: widthScreen * 0.015, color: daysColor[4], fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(fridayTextLanguageArray[languageArrayIdentifier],
                        style: TextStyle(fontSize: widthScreen * 0.015, color: daysColor[5], fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(saturdayTextLanguageArray[languageArrayIdentifier],
                        style: TextStyle(fontSize: widthScreen * 0.015, color: daysColor[6], fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                ],
                selectedColor: Colors.black,
                selectedBorderColor: Colors.black,
                fillColor: Colors.white.withOpacity(0.5),
              ),
              SizedBox(height: heightScreen * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<String>(
                    value: automationTimeYear,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 16,
                    itemHeight: 50,
                    style: TextStyle(color: Colors.grey[800], fontSize: heightScreen * 0.015 + widthScreen * 0.015),
                    onChanged: (String? data) {
                      setState(() {
                        automationTimeYear = data!;
                      });
                    },
                    items: automationYear.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[800], fontSize: heightScreen * 0.015 + widthScreen * 0.015),
                        ),
                      );
                    }).toList(),
                  ),
                  Text(
                    '/',
                    style: TextStyle(color: Colors.grey[800], fontSize: heightScreen * 0.015 + widthScreen * 0.015),
                    textAlign: TextAlign.center,
                  ),
                  DropdownButton<String>(
                    value: automationTimeMonth,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 16,
                    itemHeight: 50,
                    style: TextStyle(color: Colors.grey[800], fontSize: heightScreen * 0.015 + widthScreen * 0.015),
                    onChanged: (String? data) {
                      setState(() {
                        automationTimeMonth = data!;
                      });
                    },
                    items: automationMonth.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[800], fontSize: heightScreen * 0.015 + widthScreen * 0.015),
                        ),
                      );
                    }).toList(),
                  ),
                  Text(
                    '/',
                    style: TextStyle(color: Colors.grey[800], fontSize: heightScreen * 0.015 + widthScreen * 0.015),
                    textAlign: TextAlign.center,
                  ),
                  DropdownButton<String>(
                    value: automationTimeDay,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 16,
                    itemHeight: 50,
                    style: TextStyle(color: Colors.grey[800], fontSize: heightScreen * 0.015 + widthScreen * 0.015),
                    onChanged: (String? data) {
                      setState(() {
                        automationTimeDay = data!;
                      });
                    },
                    items: automationDay.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[800], fontSize: heightScreen * 0.015 + widthScreen * 0.015),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: heightScreen * 0.05),
              TextButton(
                onPressed: () {
                  automationConditions.add({
                    'order_num': automationConditions.length + 1,
                    'entity_type': 6,
                    'entity_id': 'timer',
                    'display': {
                      'date': automationTimeYear + automationTimeMonth + automationTimeDay,
                      'loops': loops,
                      'time': automationTimeHour + ':' + automationTimeMinute,
                      'timezone_id': 'Europe/Paris'
                    }
                  });
                  Get.back();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    addButtonTextLanguageArray[languageArrayIdentifier],
                    style: TextStyle(color: Colors.white, fontSize: widthScreen * 0.02 + heightScreen * 0.02),
                  ),
                ),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(60.0))),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
