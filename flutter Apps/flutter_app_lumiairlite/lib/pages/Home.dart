import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_bispectrum/pages/settings.dart';
import 'package:flutter_app_bispectrum/services/DataVariables.dart';
import 'package:flutter_app_bispectrum/services/animation_between_pages.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int timeToSleep;

  int boolToInt(bool a) => a == true ? 1 : 0;

  bool intToBool(int a) => a == 1 ? true : false;

  bool firstDisplayMainWidget = true;
  String carbonStateOnSleepGif = "assets/fond-vert-veille.gif";
  String carbonStateOnHome = "assets/personnage-vert.png";
  String carbonStateOnHomeMessage = "Bon";

  DateTime deviceDate;

  @override
  void initState() {
    // TODO: implement initState
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    super.initState();
  }

  void appRefreshData(BuildContext context) async {
    timeToSleep = timeSleep;
    mainWidgetScreen = appWidget(context);
    Map<String, dynamic> sensorsData;
    do {
      if (co2Value > 2000) {
        carbonStateOnSleepGif = "assets/fond-rouge-veille.gif";
        carbonStateOnHome = "assets/personnage-rouge.png";
        carbonStateOnHomeMessage = "Mauvais";
      }
      if ((co2Value >= 1000) & (co2Value <= 2000)) {
        carbonStateOnSleepGif = "assets/fond-orange-veille.gif";
        carbonStateOnHome = "assets/personnage-orange.png";
        carbonStateOnHomeMessage = "Moyen";
      }
      if (co2Value < 1000) {
        carbonStateOnSleepGif = "assets/fond-vert-veille.gif";
        carbonStateOnHome = "assets/personnage-vert.png";
        carbonStateOnHomeMessage = "Bon";
      }
      if (stateOfSleepAndReadingProcess == 0) {
        try {
          if (myDevice.getConnectionState()) {
            dataChar1 = String.fromCharCodes(await characteristicSensors.read());
            sensorsData = jsonDecode(dataChar1);
            String sensorsDataList = sensorsData['EnvData'].toString();
            deviceTimeValue = stringListAsciiToListInt(sensorsDataList.codeUnits)[0];
            detectionTimeValue = stringListAsciiToListInt(sensorsDataList.codeUnits)[1];
            temperatureValue = stringListAsciiToListInt(sensorsDataList.codeUnits)[2];
            humidityValue = stringListAsciiToListInt(sensorsDataList.codeUnits)[3];
            lightValue = stringListAsciiToListInt(sensorsDataList.codeUnits)[4];
            co2Value = stringListAsciiToListInt(sensorsDataList.codeUnits)[5];
            tvocValue = stringListAsciiToListInt(sensorsDataList.codeUnits)[6];
            deviceWifiState = intToBool(stringListAsciiToListInt(sensorsDataList.codeUnits)[7]);
            deviceDate = new DateTime.fromMillisecondsSinceEpoch(deviceTimeValue * 1000);
            appTime = DateFormat('kk:mm').format(deviceDate);
          }
        } catch (e) {
          print(e.message);
        }
        try {
          setState(() {
            if (timeToSleep <= 0) {
              mainWidgetScreen = sleepWidget(context);
            } else {
              mainWidgetScreen = appWidget(context);
            }
          });
        } catch (e) {
          print('setState error');
        }

        if (timeToSleep <= 0) {
          timeToSleep = (-1000);
        } else {
          timeToSleep -= 5000;
        }
      }
      if (stateOfSleepAndReadingProcess == 1) {
        break;
      }

      await Future.delayed(Duration(seconds: 5));
    } while (true);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (firstDisplayMainWidget) {
      try {
        stateOfSleepAndReadingProcess = 0;
        appRefreshData(context);
      } catch (e) {
        print('erreur');
      }
      firstDisplayMainWidget = false;
    }
    return WillPopScope(
      child: GestureDetector(
        child: mainWidgetScreen,
        onTap: () {
          setState(() {
            timeToSleep = timeSleep;
            mainWidgetScreen = appWidget(context);
          });
        },
      ),
      onWillPop: () => showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('Attention'),
          content: Text('Êtes-vous sûr de vouloir revenir à la page de sélection des cartes Maestro™ ?'),
          actions: [
            TextButton(
                child: Text('Oui'),
                onPressed: () async {
                  if (myDevice != null) {
                    await myDevice.disconnect();
                  }
                  stateOfSleepAndReadingProcess = 1;
                  Navigator.pop(c, true);
                }),
            TextButton(
              child: Text('Non'),
              onPressed: () => Navigator.pop(c, false),
            ),
          ],
        ),
      ),
    );
  }

  Widget appWidget(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background-bispectrum.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ToggleButtons(
                  borderRadius: BorderRadius.circular(18.0),
                  isSelected: [true, true, true, true, true],
                  onPressed: (int index) async {
                    if (index == 0) {
                      //createRoute(context, CurveShow());
                    }
                  },
                  children: [
                    Container(
                        width: (widthScreen - 80) / 5,
                        height: (heightScreen - 80) / 5,
                        child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                          new SizedBox(width: 4.0),
                          new Text("Température\n$temperatureValue °C", style: TextStyle(fontSize: widthScreen * 0.025), textAlign: TextAlign.center)
                        ])),
                    Container(
                        width: (widthScreen - 80) / 5,
                        height: (heightScreen - 80) / 5,
                        child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                          new SizedBox(width: 4.0),
                          new Text("Humidité\n$humidityValue %", style: TextStyle(fontSize: widthScreen * 0.025), textAlign: TextAlign.center)
                        ])),
                    Container(
                        width: (widthScreen - 80) / 5,
                        height: (heightScreen - 80) / 5,
                        child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                          new SizedBox(width: 4.0),
                          new Text("luminosité\n$lightValue lux", style: TextStyle(fontSize: widthScreen * 0.025), textAlign: TextAlign.center)
                        ])),
                    Container(
                        width: (widthScreen - 80) / 5,
                        height: (heightScreen - 80) / 5,
                        child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                          new SizedBox(width: 4.0),
                          new Text("CO2\n$co2Value ppm", style: TextStyle(fontSize: widthScreen * 0.025), textAlign: TextAlign.center)
                        ])),
                    Container(
                        width: (widthScreen - 80) / 5,
                        height: (heightScreen - 80) / 5,
                        child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                          new SizedBox(width: 4.0),
                          new Text("TVOC\n$tvocValue mg/m3", style: TextStyle(fontSize: widthScreen * 0.025), textAlign: TextAlign.center)
                        ])),
                  ],
                  borderWidth: 2,
                  selectedColor: Colors.white,
                  selectedBorderColor: Colors.black,
                  fillColor: Color(0xFF264eb6),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18.0),
                          color: Color(0xFFFFFFF0),
                          shape: BoxShape.rectangle,
                        ),
                        width: widthScreen * 0.8,
                        height: heightScreen * 0.25,
                        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 16.0, 0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'QUALITÉ DE L\'AIR :',
                                      style: TextStyle(
                                        color: Color(0xFF264eb6),
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      carbonStateOnHomeMessage,
                                      style: TextStyle(
                                        color: Color(0xFF264eb6),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Image.asset(
                            carbonStateOnHome,
                            height: heightScreen * 0.4,
                            width: widthScreen * 0.5,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18.0),
                          color: Color(0xFF264eb6),
                          shape: BoxShape.rectangle,
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          appTime,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18.0),
                          color: Color(0xFF264eb6),
                          shape: BoxShape.rectangle,
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Ambiances',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 35,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18.0),
                          color: Color(0xFF264eb6),
                          shape: BoxShape.rectangle,
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'LED',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 35,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18.0),
                            color: Color(0xFF264eb6),
                            shape: BoxShape.rectangle,
                          ),
                          padding: const EdgeInsets.all(2.0),
                          child: IconButton(
                              onPressed: () {
                                stateOfSleepAndReadingProcess = 2;
                                createRoute(context, Settings());
                              },
                              iconSize: 50.0,
                              icon: Icon(
                                Icons.settings,
                                color: Colors.white,
                              ))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget sleepWidget(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.blue[400],
      body: Center(
        child: Image.asset(carbonStateOnSleepGif, fit: BoxFit.cover, height: heightScreen, width: widthScreen),
      ),
    );
  }
}
