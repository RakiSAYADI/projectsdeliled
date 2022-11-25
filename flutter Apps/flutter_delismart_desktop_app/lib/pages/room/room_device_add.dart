import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/cards/device/device_widget.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_device.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';
import 'package:get/get.dart';

class RoomDeviceAdd extends StatefulWidget {
  const RoomDeviceAdd({Key? key}) : super(key: key);

  @override
  State<RoomDeviceAdd> createState() => _RoomDeviceAddState();
}

class _RoomDeviceAddState extends State<RoomDeviceAdd> {
  Map<DeviceClass, bool> devices = {};

  @override
  void initState() {
    // TODO: implement initState
    if (appClass.users[userIdentifier].universes[universeIdentifier].rooms[roomIdentifier].devices.isEmpty) {
      for (var device in appClass.users[userIdentifier].universes[universeIdentifier].devices) {
        devices.addAll({device: false});
      }
    } else {
      for (var device in appClass.users[userIdentifier].universes[universeIdentifier].devices) {
        for (var deviceRoom in appClass.users[userIdentifier].universes[universeIdentifier].rooms[roomIdentifier].devices) {
          if (deviceRoom.id != device.id) {
            devices.addAll({device: false});
          }
        }
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(addRoomDevicePageTitleTextLanguageArray[languageArrayIdentifier] + appClass.users[userIdentifier].universes[universeIdentifier].rooms[roomIdentifier].name),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.check),
        backgroundColor: Colors.green,
        onPressed: () async {
          List<String> deviceIds = [];
          devices.forEach((device, state) {
            if (state) {
              deviceIds.add(device.id);
            }
          });
          await appClass.users[userIdentifier].universes[universeIdentifier].rooms[roomIdentifier].addDevice(deviceIds);
          if (!requestResponse) {
            showToastMessage(apiMessage);
          } else {
            showToastMessage('request is valid');
          }
          Get.back();
        },
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: devices.keys
              .map(
                (device) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 4,
                      child: DeviceCard(deviceClass: device),
                    ),
                    Expanded(
                      flex: 1,
                      child: Checkbox(
                        value: devices[device],
                        onChanged: (state) {
                          setState(() {
                            devices[device] = state!;
                            debugPrint(devices[device].toString());
                          });
                        },
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
