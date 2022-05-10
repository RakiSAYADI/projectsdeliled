import 'package:flutter/material.dart';
import 'package:wifiglobalapp/services/uvc_device.dart';

class DeviceCard extends StatelessWidget {
  final Device device;
  final Function connect;

  DeviceCard({required this.device, required this.connect});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 12.0, 0, 0),
              child: Text(
                device.deviceAddress,
                style: TextStyle(fontSize: 10.0, color: Colors.black),
              ),
            ),
            SizedBox(height: 2.0),
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 0, 0, 12.0),
              child: Text(
                device.nameDevice,
                style: TextStyle(fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 2.0, 0, 2.0),
              child: TextButton.icon(
                onPressed: () => connect,
                icon: Icon(
                  Icons.wifi,
                  color: Colors.blue,
                ),
                label: Text(
                  'connect',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
