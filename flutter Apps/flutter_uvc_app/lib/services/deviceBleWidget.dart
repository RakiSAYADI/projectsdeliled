import 'package:flutter/material.dart';

import 'bleDeviceClass.dart';

class DeviceCard extends StatelessWidget {
  final Device device;
  final Function connect;

  DeviceCard({@required this.device, @required this.connect});

  Image iconDeepLight;

  @override
  Widget build(BuildContext context) {
    if (device.device.name.contains('DEEPLIGHT')) {
      iconDeepLight = Image.asset(
        'assets/scan-uvc-deeplight.png',
        height: 40.0,
        width: 40.0,
      );
    } else {
      iconDeepLight = Image.asset(
        'assets/scan-uvc-deeplight.png',
        height: 40.0,
        width: 40.0,
        color: Colors.white,
      );
    }
    return Card(
      margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              device.device.id.toString(),
              style: TextStyle(fontSize: 10.0, color: Colors.grey[600]),
            ),
            SizedBox(height: 2.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  device.device.name,
                  style: TextStyle(fontSize: 20.0, color: Colors.grey[800]),
                ),
                SizedBox(width: 2.0),
                iconDeepLight
              ],
            ),
            SizedBox(height: 8.0),
            FlatButton.icon(onPressed: connect, icon: Icon(Icons.bluetooth), label: Text('connect'))
          ],
        ),
      ),
    );
  }
}
