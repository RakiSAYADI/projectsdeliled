import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_bispectrum/pages/Curves_paint.dart';
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
  String carbonLastStateOnHome = "assets/personnage-vert.png";
  String carbonStateOnHomeMessage = "Bon";

  DateTime deviceDate;

  DateTime now;

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
      if (myDevice.getConnectionState()) {
        now = DateTime.now();
        appTime = DateFormat('kk:mm').format(now);
        try {
          dataChar1 = String.fromCharCodes(await characteristicSensors.read());
          sensorsData = jsonDecode(dataChar1);
          String sensorsDataList = sensorsData['EnvData'].toString();
          deviceTimeValue = _stringListAsciiToListInt(sensorsDataList.codeUnits)[0];
          detectionTimeValue = _stringListAsciiToListInt(sensorsDataList.codeUnits)[1];
          temperatureValue = _stringListAsciiToListInt(sensorsDataList.codeUnits)[2];
          humidityValue = _stringListAsciiToListInt(sensorsDataList.codeUnits)[3];
          lightValue = _stringListAsciiToListInt(sensorsDataList.codeUnits)[4];
          co2Value = _stringListAsciiToListInt(sensorsDataList.codeUnits)[5];
          tvocValue = _stringListAsciiToListInt(sensorsDataList.codeUnits)[6];
          deviceWifiState = intToBool(_stringListAsciiToListInt(sensorsDataList.codeUnits)[7]);
        } catch (e) {
          print(e.message);
        }
      }

      print(deviceTimeValue);

      deviceDate = new DateTime.fromMillisecondsSinceEpoch(deviceTimeValue*1000);

      print(DateFormat('kk:mm').format(deviceDate));

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

      if (deactivateSleepAndReadingProcess) {
        break;
      }

      if ((carbonLastStateOnHome != carbonStateOnHome) | (timeToSleep == 0)) {
        print("change state co2 = $co2Value");

        if (timeToSleep <= 0) {
          mainWidgetScreen = sleepWidget(context);
        } else {
          mainWidgetScreen = appWidget(context);
        }
        carbonLastStateOnHome = carbonStateOnHome;
      }

      try {
        setState(() {});
      } catch (e) {
        print(e.message);
        break;
      }

      if (timeToSleep <= 0) {
        timeToSleep = (-1000);
      } else {
        timeToSleep -= 5000;
      }
      print(timeToSleep);
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
        deactivateSleepAndReadingProcess = false;
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
                  deactivateSleepAndReadingProcess = true;
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
                      createRoute(context, CurveShow());
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
                          padding: const EdgeInsets.all(2.0),
                          child: IconButton(
                              onPressed: null,
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

  List<int> _stringListAsciiToListInt(List<int> listInt) {
    List<int> ourListInt = [0];
    int listIntLength = listInt.length;
    int intNumber = (listIntLength / 4).round();
    ourListInt.length = intNumber;
    int listCounter;
    int listIntCounter = 0;
    String numberString = '';
    if (listInt.first == 91 && listInt.last == 93) {
      for (listCounter = 0; listCounter < listIntLength - 1; listCounter++) {
        if (!((listInt[listCounter] == 91) || (listInt[listCounter] == 93) || (listInt[listCounter] == 32) || (listInt[listCounter] == 44))) {
          numberString = '';
          do {
            numberString += String.fromCharCode(listInt[listCounter]);
            listCounter++;
          } while (!((listInt[listCounter] == 44) || (listInt[listCounter] == 93)));
          ourListInt[listIntCounter] = int.parse(numberString);
          listIntCounter++;
        }
      }
      return ourListInt;
    } else {
      return [0];
    }
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