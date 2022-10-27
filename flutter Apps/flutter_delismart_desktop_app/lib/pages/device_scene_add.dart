import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/cards/device_widget.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';
import 'package:get/get.dart';

class DeviceSceneAdd extends StatefulWidget {
  const DeviceSceneAdd({Key? key}) : super(key: key);

  @override
  State<DeviceSceneAdd> createState() => _DeviceSceneAddState();
}

class _DeviceSceneAddState extends State<DeviceSceneAdd> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(addRoomDevicePageTitleTextLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.check),
        backgroundColor: Colors.green,
        onPressed: () => Get.back(),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
            children: appClass.users[userIdentifier].universes[universeIdentifier].devices
                .map(
                  (device) => GestureDetector(
                    onTap: () {},
                    child: DeviceCard(deviceClass: device),
                  ),
                )
                .toList()),
      ),
    );
  }
}
