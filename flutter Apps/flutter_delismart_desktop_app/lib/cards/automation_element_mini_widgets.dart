import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_device.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';

class TimeAutomationConditionCard extends StatelessWidget {
  final Map<String, dynamic> timeData;
  final bool deleteVisibility;

  const TimeAutomationConditionCard({Key? key, required this.timeData, required this.deleteVisibility}) : super(key: key);

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
              flex: 1,
              child: Container(
                width: widthScreen * 0.07,
                height: heightScreen * 0.07,
                decoration: BoxDecoration(
                  border: Border.all(width: 2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    timeData['order_num'].toString(),
                    style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
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
                        '${(timeData['display'] as Map<String, String>)['time']!.split(':')[0]} : ',
                        style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        (timeData['display'] as Map<String, String>)['time']!.split(':')[1],
                        style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Text(
                    dateTextLanguageArray[languageArrayIdentifier],
                    style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(timeData['display'] as Map<String, String>)['date']!.substring(0, 4)} / ',
                        style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '${(timeData['display'] as Map<String, String>)['date']!.substring(4, 6)} / ',
                        style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        (timeData['display'] as Map<String, String>)['date']!.substring(6, 8),
                        style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Text(
                    dayTextLanguageArray[languageArrayIdentifier],
                    style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        (timeData['display'] as Map<String, String>)['loops']![1] == '1' ? mondayTextLanguageArray[languageArrayIdentifier] + ', ' : '',
                        style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        (timeData['display'] as Map<String, String>)['loops']![2] == '1' ? tuesdayTextLanguageArray[languageArrayIdentifier] + ', ' : '',
                        style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        (timeData['display'] as Map<String, String>)['loops']![3] == '1' ? wednesdayTextLanguageArray[languageArrayIdentifier] + ', ' : '',
                        style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        (timeData['display'] as Map<String, String>)['loops']![4] == '1' ? thursdayTextLanguageArray[languageArrayIdentifier] + ', ' : '',
                        style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        (timeData['display'] as Map<String, String>)['loops']![5] == '1' ? fridayTextLanguageArray[languageArrayIdentifier] + ', ' : '',
                        style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        (timeData['display'] as Map<String, String>)['loops']![6] == '1' ? saturdayTextLanguageArray[languageArrayIdentifier] + ', ' : '',
                        style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        (timeData['display'] as Map<String, String>)['loops']![0] == '1' ? sundayTextLanguageArray[languageArrayIdentifier] : '',
                        style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                ],
              ),
            ),
            Visibility(
              visible: deleteVisibility,
              child: Expanded(
                flex: 2,
                child: TextButton.icon(
                  onPressed: () {
                    automationConditions.remove(timeData);
                    int i = 0;
                    for (var condition in automationConditions) {
                      condition['order_num'] = ++i;
                    }
                  },
                  icon: Icon(Icons.delete, size: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.red),
                  label: Text(
                    deleteButtonTextLanguageArray[languageArrayIdentifier],
                    style: TextStyle(fontSize: heightScreen * 0.008 + widthScreen * 0.008, color: Colors.red),
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

class DeviceAutomationConditionCard extends StatelessWidget {
  final Map<String, dynamic> mapData;
  final DeviceClass deviceClass;
  final bool deleteVisibility;

  const DeviceAutomationConditionCard({Key? key, required this.deviceClass, required this.mapData, required this.deleteVisibility}) : super(key: key);

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
              flex: 1,
              child: Container(
                width: widthScreen * 0.07,
                height: heightScreen * 0.07,
                decoration: BoxDecoration(
                  border: Border.all(width: 2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    mapData['order_num'].toString(),
                    style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  Text(
                    deviceClass.name,
                    style: TextStyle(fontSize: heightScreen * 0.013 + widthScreen * 0.013, color: Colors.grey[800]),
                  ),
                  Center(
                    child: (mapData['display'] as Map<String, dynamic>).isEmpty
                        ? Text(
                            mapData['entity_id'].toString(),
                            style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
                            textAlign: TextAlign.center,
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                (mapData['display'] as Map<String, dynamic>)['code'].toString(),
                                style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                (mapData['display'] as Map<String, dynamic>)['operator'].toString(),
                                style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                (mapData['display'] as Map<String, dynamic>)['value'].toString(),
                                style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
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
            Visibility(
              visible: deleteVisibility,
              child: Expanded(
                flex: 1,
                child: TextButton.icon(
                  onPressed: () {
                    automationConditions.remove(mapData);
                    int i = 0;
                    for (var condition in automationConditions) {
                      condition['order_num'] = ++i;
                    }
                  },
                  icon: Icon(Icons.delete, size: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.red),
                  label: Text(
                    deleteButtonTextLanguageArray[languageArrayIdentifier],
                    style: TextStyle(fontSize: heightScreen * 0.008 + widthScreen * 0.008, color: Colors.red),
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

class ExternalAutomationConditionCard extends StatelessWidget {
  final Map<String, dynamic> mapData;
  final bool deleteVisibility;

  const ExternalAutomationConditionCard({Key? key, required this.mapData, required this.deleteVisibility}) : super(key: key);

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
              flex: 1,
              child: Container(
                width: widthScreen * 0.07,
                height: heightScreen * 0.07,
                decoration: BoxDecoration(
                  border: Border.all(width: 2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    mapData['order_num'].toString(),
                    style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (mapData['display'] as Map<String, dynamic>)['code'].toString(),
                      style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      (mapData['display'] as Map<String, dynamic>)['operator'].toString(),
                      style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      (mapData['display'] as Map<String, dynamic>)['value'].toString(),
                      style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: deleteVisibility,
              child: Expanded(
                flex: 2,
                child: TextButton.icon(
                  onPressed: () {
                    automationConditions.remove(mapData);
                    int i = 0;
                    for (var condition in automationConditions) {
                      condition['order_num'] = ++i;
                    }
                  },
                  icon: Icon(Icons.delete, size: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.red),
                  label: Text(
                    deleteButtonTextLanguageArray[languageArrayIdentifier],
                    style: TextStyle(fontSize: heightScreen * 0.008 + widthScreen * 0.008, color: Colors.red),
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

class WeatherAutomationConditionCard extends StatelessWidget {
  final Map<String, dynamic> weatherData;
  final bool deleteVisibility;

  const WeatherAutomationConditionCard({Key? key, required this.weatherData, required this.deleteVisibility}) : super(key: key);

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
              flex: 1,
              child: Container(
                width: widthScreen * 0.07,
                height: heightScreen * 0.07,
                decoration: BoxDecoration(
                  border: Border.all(width: 2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    weatherData['order_num'].toString(),
                    style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Center(
                child: (weatherData['display'] as Map<String, dynamic>).isEmpty
                    ? Text(
                        weatherData['entity_id'].toString(),
                        style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
                        textAlign: TextAlign.center,
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            (weatherData['display'] as Map<String, dynamic>)['code'].toString(),
                            style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            (weatherData['display'] as Map<String, dynamic>)['operator'].toString(),
                            style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            (weatherData['display'] as Map<String, dynamic>)['value'].toString(),
                            style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
              ),
            ),
            Visibility(
              visible: deleteVisibility,
              child: Expanded(
                flex: 1,
                child: TextButton.icon(
                  onPressed: () {
                    automationConditions.remove(weatherData);
                    int i = 0;
                    for (var condition in automationConditions) {
                      condition['order_num'] = ++i;
                    }
                  },
                  icon: Icon(Icons.delete, size: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.red),
                  label: Text(
                    deleteButtonTextLanguageArray[languageArrayIdentifier],
                    style: TextStyle(fontSize: heightScreen * 0.008 + widthScreen * 0.008, color: Colors.red),
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

class DelayAutomationActionCard extends StatelessWidget {
  final Map<String, dynamic> timeData;

  const DelayAutomationActionCard({Key? key, required this.timeData}) : super(key: key);

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
                        '${(timeData['executor_property'] as Map<String, String>)['hours'].toString()} : ',
                        style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '${(timeData['executor_property'] as Map<String, String>)['minutes'].toString()} : ',
                        style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        (timeData['executor_property'] as Map<String, String>)['seconds'].toString(),
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
                  automationActions.remove(timeData);
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

class DeviceAutomationActionCard extends StatelessWidget {
  final DeviceClass deviceClass;
  final Map<String, dynamic> mapData;

  const DeviceAutomationActionCard({Key? key, required this.deviceClass, required this.mapData}) : super(key: key);

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
                      automationActions.remove(mapData);
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
