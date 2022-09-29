import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_universe.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';

class UniverseCard extends StatelessWidget {
  final UniverseClass universeClass;
  final Function() connect;

  const UniverseCard({required this.universeClass, required this.connect});

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              universeClass.name,
              style: TextStyle(fontSize: heightScreen * 0.013 + widthScreen * 0.013, color: Colors.grey[800]),
            ),
            SizedBox(height: heightScreen * 0.001, width: widthScreen * 0.001),
            Text(
              universeClass.geoName,
              style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.grey[600]),
            ),
            SizedBox(height: heightScreen * 0.001, width: widthScreen * 0.001),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'lon : ${universeClass.lon}',
                  style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.grey[800]),
                ),
                SizedBox(height: heightScreen * 0.001, width: widthScreen * 0.001),
                Text(
                  ' lat : ${universeClass.lat}',
                  style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.grey[800]),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: connect,
              icon: Icon(Icons.connect_without_contact, size: heightScreen * 0.009 + widthScreen * 0.009),
              label: Text(
                deviceConnectButtonTextLanguageArray[languageArrayIdentifier],
                style: TextStyle(fontSize: heightScreen * 0.009 + widthScreen * 0.009),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
