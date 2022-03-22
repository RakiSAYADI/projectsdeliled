import 'package:flutter/material.dart';
import 'package:flutter_app_dmx_maestro/services/DataVariables.dart';

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
      color: Colors.transparent,
      margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: modeColor[backGroundColorSelect]),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF000000).withOpacity(0.45),
              blurRadius: 6,
              offset: Offset(0, 5), // changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 12.0, 0, 0),
                child: Text(
                  device.device.id.toString(),
                  style: TextStyle(fontSize: 10.0, color: textColor[backGroundColorSelect]),
                ),
              ),
              SizedBox(height: 2.0),
              Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 0, 0, 12.0),
                child: Text(
                  deviceName,
                  style: TextStyle(fontSize: 16.0, color: textColor[backGroundColorSelect], fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 2.0, 0, 2.0),
                child: FlatButton.icon(
                  onPressed: connect,
                  icon: Icon(
                    Icons.bluetooth,
                    color: textColor[backGroundColorSelect],
                  ),
                  label: Text(
                    'connect',
                    style: TextStyle(color: textColor[backGroundColorSelect]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
