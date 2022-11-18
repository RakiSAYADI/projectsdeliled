import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_device.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';

class DelaySceneCard extends StatelessWidget {
  final Map<String, dynamic> delayData;

  const DelaySceneCard({Key? key, required this.delayData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Card(
      semanticContainer: false,
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
                    style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(delayData['executor_property'] as Map<String, dynamic>)['hours'].toString()} : ',
                        style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '${(delayData['executor_property'] as Map<String, dynamic>)['minutes'].toString()} : ',
                        style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        (delayData['executor_property'] as Map<String, dynamic>)['seconds'].toString(),
                        style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
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
                  style: TextStyle(fontSize: heightScreen * 0.008 + widthScreen * 0.008, color: Colors.red),
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
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        deviceClass.name,
                        style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        mapData['executor_property'].toString(),
                        style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: deviceClass.imageUrl.isEmpty
                      ? Image.asset(
                          'assets/device.png',
                          height: heightScreen * 0.09,
                          width: widthScreen * 0.09,
                        )
                      : Image.network(
                          'https://images.tuyaeu.com/' + deviceClass.imageUrl,
                          height: heightScreen * 0.09,
                          width: widthScreen * 0.09,
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
                      style: TextStyle(fontSize: heightScreen * 0.008 + widthScreen * 0.008, color: Colors.red),
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

class AutomationSceneCard extends StatelessWidget {
  final String elementName;
  final bool sceneOrAutomation;
  final Map<String, dynamic> mapData;

  const AutomationSceneCard({Key? key, required this.elementName, required this.mapData, required this.sceneOrAutomation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Card(
      semanticContainer: false,
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
                    elementName,
                    style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  _automationType(heightScreen, widthScreen, mapData['action_executor'].toString()),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: TextButton.icon(
                onPressed: () {
                  if (sceneOrAutomation) {
                    sceneActions.remove(mapData);
                  } else {
                    automationActions.remove(mapData);
                  }
                },
                icon: Icon(Icons.delete, size: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.red),
                label: Text(
                  deleteButtonTextLanguageArray[languageArrayIdentifier],
                  style: TextStyle(fontSize: heightScreen * 0.008 + widthScreen * 0.008, color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _automationType(double height, double width, String type) {
    String text = '';
    Color textColor = Colors.white;
    switch (mapData['action_executor'].toString()) {
      case 'ruleEnable':
        text = 'Enable';
        textColor = Colors.green;
        break;
      case 'ruleDisable':
        text = 'Disable';
        textColor = Colors.red;
        break;
      default:
        text = 'Trigger';
        textColor = Colors.blue;
        break;
    }
    return Text(
      text,
      style: TextStyle(fontSize: height * 0.01 + width * 0.01, color: textColor),
      textAlign: TextAlign.center,
    );
  }
}

class DeviceGroupSceneCard extends StatelessWidget {
  final Map<String, dynamic> mapData;

  const DeviceGroupSceneCard({Key? key, required this.mapData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Card(
      semanticContainer: false,
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
                    groupTextLanguageArray[languageArrayIdentifier],
                    style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    mapData['executor_property'].toString(),
                    style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ],
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
                  style: TextStyle(fontSize: heightScreen * 0.008 + widthScreen * 0.008, color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
