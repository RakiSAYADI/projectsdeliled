import 'package:flutter/material.dart';
import 'package:flutter_app_ambimaestro/services/ble_device_class.dart';

class DeviceCard extends StatelessWidget {
  final Device? device;
  final Function connect;

  const DeviceCard({Key? key, this.device, required this.connect}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String deviceName;
    if (device!.device.name.isEmpty) {
      deviceName = 'Appareil sans nom';
    } else {
      deviceName = device!.device.name;
    }
    return Card(
      margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              device!.device.id.toString(),
              style: TextStyle(fontSize: 10.0, color: Colors.grey[600]),
            ),
            const SizedBox(height: 2.0),
            Text(
              deviceName,
              style: TextStyle(fontSize: 16.0, color: Colors.grey[800]),
            ),
            const SizedBox(height: 8.0),
            TextButton.icon(onPressed: () => connect, icon: const Icon(Icons.bluetooth), label: const Text('connect'))
          ],
        ),
      ),
    );
  }
}
