import 'package:flutter/material.dart';

import 'bleDeviceClass.dart';

class DeviceCard extends StatelessWidget {
  final Device device;
  final Function connect;

  DeviceCard({this.device, this.connect});

  @override
  Widget build(BuildContext context) {
    String deviceName;
    if ((device.device.name == null) || (device.device.name.isEmpty)) {
      deviceName = 'Appareil sans nom';
    } else {
      deviceName = device.device.name;
    }
    return Card(
      margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              deviceName,
              style: TextStyle(fontSize: 10.0, color: Colors.grey[600]),
            ),
            SizedBox(height: 2.0),
            Text(
              device.device.id.toString(),
              style: TextStyle(fontSize: 16.0, color: Colors.grey[800]),
            ),
            SizedBox(height: 8.0),
            FlatButton.icon(onPressed: connect, icon: Icon(Icons.bluetooth), label: Text('connect'))
          ],
        ),
      ),
    );
  }
}
