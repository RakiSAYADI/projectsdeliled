import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';

class DelayCard extends StatelessWidget {
  final Map<String, dynamic> delayData;

  const DelayCard({Key? key, required this.delayData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              timeTextLanguageArray[languageArrayIdentifier],
              style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${delayData['action_executor']['hours']} : ',
                  style: TextStyle(fontSize: heightScreen * 0.003 + widthScreen * 0.003, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '${delayData['action_executor']['minutes']} : ',
                  style: TextStyle(fontSize: heightScreen * 0.003 + widthScreen * 0.003, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '${delayData['action_executor']['seconds']}',
                  style: TextStyle(fontSize: heightScreen * 0.003 + widthScreen * 0.003, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class DeviceSceneCard extends StatelessWidget {
  final Map<String, dynamic> deviceSceneData;

  const DeviceSceneCard({Key? key, required this.deviceSceneData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              timeTextLanguageArray[languageArrayIdentifier],
              style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: const [],
            )
          ],
        ),
      ),
    );
  }
}
