import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_device.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';

class DeviceRoomCard extends StatelessWidget {
  final DeviceClass deviceClass;

  const DeviceRoomCard({Key? key, required this.deviceClass}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    deviceClass.name,
                    style: TextStyle(fontSize: heightScreen * 0.013 + widthScreen * 0.013, color: Colors.grey[800]),
                  ),
                  SizedBox(height: heightScreen * 0.001, width: widthScreen * 0.001),
                  deviceClass.online
                      ? Text(
                          'Online',
                          style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.green),
                        )
                      : Text(
                          'Offline',
                          style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.red),
                        ),
                  SizedBox(height: heightScreen * 0.001, width: widthScreen * 0.001),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: deviceClass.imageUrl.isEmpty
                  ? Image.asset(
                      'assets/device.png',
                      height: heightScreen * 0.1,
                      width: widthScreen * 0.1,
                    )
                  : Image.network(
                      'https://images.tuyaeu.com/' + deviceClass.imageUrl,
                      height: heightScreen * 0.1,
                      width: widthScreen * 0.1,
                    ),
            ),
            Expanded(
              flex: 2,
              child: TextButton.icon(
                onPressed: () {
                  moveDeviceRoomRequestWidget(deviceClass.id);
                },
                icon: Icon(Icons.place, size: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.blue),
                label: Text(
                  moveRoomButtonTextLanguageArray[languageArrayIdentifier],
                  style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.blue),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: TextButton.icon(
                onPressed: () {
                  deleteDeviceRoomRequestWidget(deviceClass.id);
                },
                icon: Icon(Icons.delete, size: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.red),
                label: Text(
                  deleteDeviceRoomButtonTextLanguageArray[languageArrayIdentifier],
                  style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
