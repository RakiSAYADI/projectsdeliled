import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/cards/device_widget.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';

class ScanListDevice extends StatefulWidget {
  const ScanListDevice({Key? key}) : super(key: key);

  @override
  _ScanListDeviceState createState() => _ScanListDeviceState();
}

class _ScanListDeviceState extends State<ScanListDevice> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(scanDevicePageTitleTextLanguageArray[languageArrayIdentifier] + appClass.users[userIdentifier].universes[universeIdentifier].name),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        backgroundColor: Colors.blue,
        onPressed: () async {
          await appClass.users[userIdentifier].universes[universeIdentifier].getDevices();
          if (!requestResponse) {
            showToastMessage('test toast message');
          }
          setState(() {});
        },
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(children: appClass.users[userIdentifier].universes[universeIdentifier].devices.map((device) => DeviceCard(deviceClass: device)).toList()),
      ),
    );
  }
}
