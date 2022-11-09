import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/cards/automation_element_mini_widgets.dart';
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
  List<String> conditions = [];

  List<Widget> conditionWidgets = [];

  @override
  void initState() {
    for(int i = 0; i<automationConditions.length;i++){
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
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
          Get.back();
        },
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: automationConditions.map((element) {
            switch (element['entity_type']) {
              case 1:
                for (DeviceClass device in appClass.users[userIdentifier].universes[universeIdentifier].devices) {
                  if (element['entity_id'] == device.id) {
                    return DeviceAutomationConditionCard(deviceClass: device, mapData: element, deleteVisibility: false);
                  }
                }
                return Container();
              case 3:
                return WeatherAutomationConditionCard(weatherData: element, deleteVisibility: false);
              case 6:
                return TimeAutomationConditionCard(timeData: element, deleteVisibility: false);
              case 15:
                return ExternalAutomationConditionCard(mapData: element, deleteVisibility: false);
              default:
                return Container();
            }
          }).toList(),
        ),
      ),
    );
  }
}
