import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/cards/automation/automation_element_mini_widgets.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_device.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';
import 'package:get/get.dart';

class ConditionAutomationModify extends StatefulWidget {
  const ConditionAutomationModify({Key? key}) : super(key: key);

  @override
  State<ConditionAutomationModify> createState() => _ConditionAutomationModifyState();
}

class _ConditionAutomationModifyState extends State<ConditionAutomationModify> {
  List<String> conditionsString = [];
  List<Widget> conditionWidgets = [];

  bool firstDisplay = true;

  void setupWidgets() {
    bool step = false;
    int conditionArray = -1;
    int specialCondition = 1;
    int i = 0;
    while (i < automationConditions.length) {
      if (step) {
        conditionArray++;
        final int conditionPos = conditionArray;
        switch (matchType) {
          case 1:
            conditionsString.add(orTextLanguageArray[languageArrayIdentifier]);
            break;
          case 2:
            conditionsString.add(andTextLanguageArray[languageArrayIdentifier]);
            break;
          case 3:
            if (conditionRule.substring(specialCondition, specialCondition + 2) == '&&') {
              conditionsString.add(andTextLanguageArray[languageArrayIdentifier]);
            } else {
              conditionsString.add(orTextLanguageArray[languageArrayIdentifier]);
            }
            specialCondition += 3;
            break;
        }
        conditionWidgets.add(
          StatefulBuilder(builder: (BuildContext context, StateSetter dropDownState) {
            return DropdownButton<String>(
              value: conditionsString[conditionPos],
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.grey[800], fontSize: 18),
              underline: Container(
                height: 2,
                color: Colors.blue[300],
              ),
              onChanged: (String? data) {
                dropDownState(() {
                  conditionsString[conditionPos] = data!;
                });
              },
              items: conditions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            );
          }),
        );
        step = false;
      } else {
        switch (automationConditions[i]['entity_type']) {
          case 1:
            for (DeviceClass device in appClass.users[userIdentifier].universes[universeIdentifier].devices) {
              if (automationConditions[i]['entity_id'] == device.id) {
                conditionWidgets.add(DeviceAutomationConditionCard(deviceClass: device, mapData: automationConditions[i], deleteVisibility: false));
              }
            }
            break;
          case 3:
            conditionWidgets.add(WeatherAutomationConditionCard(weatherData: automationConditions[i], deleteVisibility: false));
            break;
          case 6:
            conditionWidgets.add(TimeAutomationConditionCard(timeData: automationConditions[i], deleteVisibility: false));
            break;
          case 15:
            conditionWidgets.add(ExternalAutomationConditionCard(mapData: automationConditions[i], deleteVisibility: false));
            break;
        }
        step = true;
        i++;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (firstDisplay) {
      setupWidgets();
      firstDisplay = false;
    }
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(addAndModifyConditionsPageTitleTextLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.check),
        backgroundColor: Colors.green,
        onPressed: () {
          if (!conditionsString.contains(andTextLanguageArray[languageArrayIdentifier])) {
            matchType = 1;
          } else if (!conditionsString.contains(orTextLanguageArray[languageArrayIdentifier])) {
            matchType = 2;
          } else {
            matchType = 3;
            int pos = 1;
            conditionRule = '';
            for (String condition in conditionsString) {
              conditionRule += pos.toString();
              if (condition == andTextLanguageArray[languageArrayIdentifier]) {
                conditionRule += '&&';
              } else {
                conditionRule += '||';
              }
              pos++;
            }
            conditionRule += pos.toString();
          }
          Get.back();
        },
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: conditionWidgets,
        ),
      ),
    );
  }
}
