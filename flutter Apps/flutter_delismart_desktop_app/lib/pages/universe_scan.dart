import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/cards/univers_widget.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';

class ScanListUniverse extends StatefulWidget {
  const ScanListUniverse({Key? key}) : super(key: key);

  @override
  _ScanListUniverseState createState() => _ScanListUniverseState();
}

class _ScanListUniverseState extends State<ScanListUniverse> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        backgroundColor: Colors.blue,
        onPressed: () async {
          appClass.users[userIdentifier].universes.clear();
          waitingRequestWidget();
          await appClass.users[userIdentifier].getUniverses();
          if (!requestResponse) {
            showToastMessage('Error request');
          }
          exitRequestWidget();
          setState(() {});
        },
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
            children: appClass.users[userIdentifier].universes
                .map((universe) => UniverseCard(
                    universeClass: universe,
                    connect: () async {
                      universe.devices.clear();
                      await universe.getDevices();
                      universeIdentifier = appClass.users[userIdentifier].universes.indexOf(universe);
                      if (!requestResponse) {
                        showToastMessage('Error request');
                      } else {
                        Navigator.pushNamed(context, '/device_list');
                      }
                    }))
                .toList()),
      ),
    );
  }
}
