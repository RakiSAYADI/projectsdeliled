import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_bispectrum/pages/LED_control.dart';
import 'package:flutter_app_bispectrum/pages/ambiances.dart';
import 'package:flutter_app_bispectrum/pages/settings.dart';
import 'package:flutter_app_bispectrum/services/DataVariables.dart';
import 'package:flutter_app_bispectrum/services/animation_between_pages.dart';
import 'package:flutter_app_bispectrum/services/uvcToast.dart';
import 'package:intl/intl.dart';
import 'package:pinput/pin_put/pin_put.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int timeToSleep;
  final int dataReadDuration = 1;

  bool firstDisplayMainWidget = true;

  String carbonStateOnSleepGif = "assets/fond-vert-veille.gif";
  String carbonStateOnHome = "assets/personnage-vert.png";
  String carbonStateOnHomeMessage = "Bon";
  String pinCode;
  String myPinCode = '';

  final TextEditingController _pinPutController = TextEditingController();

  DateTime deviceDate;

  ToastyMessage myUvcToast;

  @override
  void initState() {
    // TODO: implement initState
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    myUvcToast = ToastyMessage(toastContext: context);
    super.initState();
  }

  void appRefreshData(BuildContext context) async {
    timeToSleep = timeSleep;
    mainWidgetScreen = appWidget(context);
    Map<String, dynamic> sensorsData;
    do {
      if (co2Value > 1500) {
        carbonStateOnSleepGif = "assets/fond-rouge-veille.gif";
        carbonStateOnHome = "assets/personnage-rouge.png";
        carbonStateOnHomeMessage = "Mauvais";
      }
      if ((co2Value >= 800) & (co2Value <= 1500)) {
        carbonStateOnSleepGif = "assets/fond-orange-veille.gif";
        carbonStateOnHome = "assets/personnage-orange.png";
        carbonStateOnHomeMessage = "Moyen";
      }
      if (co2Value < 800) {
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
          timeToSleep -= 1000 * dataReadDuration;
        }
      }
      if (stateOfSleepAndReadingProcess == 1) {
        break;
      }

      await Future.delayed(Duration(seconds: dataReadDuration));
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
                  homePageState = false;
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
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10.0, 0, 10.0),
                  child: ToggleButtons(
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
                            new Text("Température\n$temperatureValue °C",
                                style: TextStyle(fontSize: widthScreen * 0.025), textAlign: TextAlign.center)
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
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
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
                        padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 10.0),
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
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
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
                                fontSize: 35,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18.0),
                              color: Color(0xFF264eb6),
                              shape: BoxShape.rectangle,
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: TextButton(
                              onPressed: () {
                                stateOfSleepAndReadingProcess = 2;
                                createRoute(context, AmbiancePage());
                              },
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
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(18.0),
                              gradient: LinearGradient(colors: [Colors.red, Colors.green, Colors.blue]),
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: TextButton(
                              onPressed: () {
                                stateOfSleepAndReadingProcess = 2;
                                createRoute(context, LEDPage());
                              },
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
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18.0),
                                color: Color(0xFF264eb6),
                                shape: BoxShape.rectangle,
                              ),
                              padding: const EdgeInsets.all(2.0),
                              child: IconButton(
                                  onPressed: () {
                                    pinSecurity(context);
                                  },
                                  iconSize: 50.0,
                                  icon: Icon(
                                    Icons.settings,
                                    color: Colors.white,
                                  ))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> pinSecurity(BuildContext buildContext) async {
    double widthScreen = MediaQuery.of(buildContext).size.width;
    double heightScreen = MediaQuery.of(buildContext).size.height;
    try {
      var parsedJson = json.decode(dataChar2);
      pinCodeAccess = parsedJson['PP'].toString();
    } catch (e) {
      print('erreur pin');
      pinCodeAccess = '1234';
    }
    return showDialog<void>(
        barrierDismissible: false,
        context: buildContext,
        builder: (BuildContext buildContext1) {
          return AlertDialog(
            content: Container(
              child: Builder(
                builder: (buildContext1) {
                  return Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Entrer le code de sécurité :',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: widthScreen * 0.04,
                            ),
                          ),
                          SizedBox(height: heightScreen * 0.05),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(flex: 1, child: SizedBox(height: heightScreen * 0.01)),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  margin: EdgeInsets.all(20),
                                  padding: EdgeInsets.all(10),
                                  child: PinPut(
                                    fieldsCount: 4,
                                    onSubmit: (String pin) => pinCode = pin,
                                    focusNode: AlwaysDisabledFocusNode(),
                                    controller: _pinPutController,
                                    textStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: widthScreen * 0.04,
                                    ),
                                    submittedFieldDecoration: _pinPutDecoration.copyWith(borderRadius: BorderRadius.circular(20)),
                                    selectedFieldDecoration: _pinPutDecoration,
                                    followingFieldDecoration: _pinPutDecoration.copyWith(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(color: Colors.grey[600].withOpacity(.5), width: 3),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(flex: 1, child: SizedBox(height: heightScreen * 0.01)),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  buttonNumbers('0', buildContext1),
                                  SizedBox(width: widthScreen * 0.003),
                                  buttonNumbers('1', buildContext1),
                                  SizedBox(width: widthScreen * 0.003),
                                  buttonNumbers('2', buildContext1),
                                  SizedBox(width: widthScreen * 0.003),
                                  buttonNumbers('3', buildContext1),
                                  SizedBox(width: widthScreen * 0.003),
                                  buttonNumbers('4', buildContext1),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  buttonNumbers('5', buildContext1),
                                  SizedBox(width: widthScreen * 0.003),
                                  buttonNumbers('6', buildContext1),
                                  SizedBox(width: widthScreen * 0.003),
                                  buttonNumbers('7', buildContext1),
                                  SizedBox(width: widthScreen * 0.003),
                                  buttonNumbers('8', buildContext1),
                                  SizedBox(width: widthScreen * 0.003),
                                  buttonNumbers('9', buildContext1),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        });
  }

  ButtonTheme buttonNumbers(String number, BuildContext buildContext) {
    double widthScreen = MediaQuery.of(buildContext).size.width;
    double heightScreen = MediaQuery.of(buildContext).size.height;
    return ButtonTheme(
      minWidth: widthScreen * 0.05,
      height: heightScreen * 0.05,
      child: TextButton(
        child: Text(
          number,
          style: TextStyle(
            color: Colors.white,
            fontSize: widthScreen * 0.02,
          ),
        ),
        style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
            backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[400])),
        onPressed: () async {
          myPinCode += number;
          _pinPutController.text += '*';
          if (_pinPutController.text.length == 4) {
            if (myPinCode == pinCodeAccess) {
              Navigator.pop(buildContext);
              stateOfSleepAndReadingProcess = 2;
              createRoute(context, Settings());
            } else {
              myUvcToast.setToastDuration(3);
              myUvcToast.setToastMessage('Code Invalide !');
              myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
            }
            _pinPutController.text = '';
            myPinCode = '';
          }
        },
      ),
    );
  }

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: Colors.blue, width: 3),
      borderRadius: BorderRadius.circular(15),
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
