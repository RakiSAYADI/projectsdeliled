import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/cards/device/device_widget.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';
import 'package:get/get.dart';

class DeviceConditionAutomationAdd extends StatefulWidget {
  const DeviceConditionAutomationAdd({Key? key}) : super(key: key);

  @override
  State<DeviceConditionAutomationAdd> createState() => _DeviceConditionAutomationAddState();
}

class _DeviceConditionAutomationAddState extends State<DeviceConditionAutomationAdd> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(addRoomDevicePageTitleTextLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
            children: appClass.users[userIdentifier].universes[universeIdentifier].devices
                .map(
                  (device) => GestureDetector(
                    onTap: () => Get.toNamed('/device_functions_automation_condition_modify', arguments: {'device': device}),
                    child: DeviceCard(deviceClass: device),
                  ),
                )
                .toList()),
      ),
    );
  }
}
