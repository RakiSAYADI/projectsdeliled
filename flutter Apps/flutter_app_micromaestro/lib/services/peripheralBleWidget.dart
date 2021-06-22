import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';

class PeripheralCard extends StatelessWidget {
  final Peripheral peripheral;
  final Function connect;

  PeripheralCard({this.peripheral, this.connect});

  @override
  Widget build(BuildContext context) {
    String deviceName;
    if ((peripheral.name == null)||(peripheral.name.isEmpty)) {
      deviceName = 'Appareil sans nom';
    } else {
      deviceName = peripheral.name;
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
              peripheral.identifier,
              style: TextStyle(fontSize: 16.0, color: Colors.grey[800]),
            ),
            SizedBox(height: 8.0),
            FlatButton.icon(
                onPressed: connect,
                icon: Icon(Icons.bluetooth),
                label: Text('connect'))
          ],
        ),
      ),
    );
  }
}
