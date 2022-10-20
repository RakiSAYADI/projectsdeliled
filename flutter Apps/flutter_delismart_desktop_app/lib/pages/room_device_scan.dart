import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/cards/room_device_widget.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';

class ScanListRoomDevice extends StatefulWidget {
  const ScanListRoomDevice({Key? key}) : super(key: key);

  @override
  State<ScanListRoomDevice> createState() => _ScanListRoomDeviceState();
}

class _ScanListRoomDeviceState extends State<ScanListRoomDevice> {
  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(scanDevicePageTitleTextLanguageArray[languageArrayIdentifier] + appClass.users[userIdentifier].universes[universeIdentifier].rooms[roomIdentifier].name),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.add, size: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.white),
                label: Text(
                  addDeviceButtonTextLanguageArray[languageArrayIdentifier],
                  style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search),
        backgroundColor: Colors.blue,
        onPressed: () async {
          appClass.users[userIdentifier].universes[universeIdentifier].rooms[roomIdentifier].devices.clear();
          await appClass.users[userIdentifier].universes[universeIdentifier].rooms[roomIdentifier].getDevices();
          if (!requestResponse) {
            showToastMessage('test toast message');
          }
          setState(() {});
        },
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: appClass.users[userIdentifier].universes[universeIdentifier].rooms[roomIdentifier].devices
              .map(
                (device) => DeviceRoomCard(deviceClass: device),
              )
              .toList(),
        ),
      ),
    );
  }
}
