import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_device.dart';
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
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 5,
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
            Expanded(
              flex: 1,
              child: TextButton.icon(
                onPressed: () {
                  sceneActions.remove(delayData);
                },
                icon: Icon(Icons.delete, size: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.red),
                label: Text(
                  deleteButtonTextLanguageArray[languageArrayIdentifier],
                  style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeviceSceneCard extends StatelessWidget {
  final DeviceClass deviceClass;
  final Map<String, dynamic> mapData;

  const DeviceSceneCard({Key? key, required this.deviceClass, required this.mapData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    deviceClass.name,
                    style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
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
                  flex: 1,
                  child: TextButton.icon(
                    onPressed: () {
                      sceneActions.remove(mapData);
                    },
                    icon: Icon(Icons.delete, size: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.red),
                    label: Text(
                      deleteButtonTextLanguageArray[languageArrayIdentifier],
                      style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
