import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_bispectrum/pages/LED_control.dart';
import 'package:flutter_app_bispectrum/pages/settings.dart';
import 'package:flutter_app_bispectrum/services/DataVariables.dart';
import 'package:flutter_app_bispectrum/services/animation_between_pages.dart';
import 'package:flutter_app_bispectrum/services/languageDataBase.dart';
import 'package:flutter_app_bispectrum/services/uvcToast.dart';
import 'package:intl/intl.dart';
import 'package:pinput/pin_put/pin_put.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  AnimationController controllerWifiAnimation;

  int timeToSleep;
  final int dataReadDuration = 1;

  bool firstDisplayMainWidget = true;

  String carbonStateOnSleepGif = "assets/fond-vert-veille.gif";
  String carbonStateOnHome = "assets/personnage-vert.png";
  String carbonStateOnHomeMessage = "Bon";
  String myWifiState = 'assets/red-wifi.png';
  String pinCode;
  String myPinCode = '';

  final TextEditingController _pinPutController = TextEditingController();
  final int sensorsTabPadding = 60;

  Animation<double> _animation;

  DateTime deviceDate;
  DateTime dateTime = DateTime.now();
  ToastyMessage myUvcToast;

  @override
  void initState() {
    // TODO: implement initState
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    controllerWifiAnimation = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: controllerWifiAnimation,
      curve: Curves.fastOutSlowIn,
    );
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
        carbonStateOnHomeMessage = badAirQualityMessageLanguageArray[languageArrayIdentifier];
      }
      if ((co2Value >= 800) & (co2Value <= 1500)) {
        carbonStateOnSleepGif = "assets/fond-orange-veille.gif";
        carbonStateOnHome = "assets/personnage-orange.png";
        carbonStateOnHomeMessage = averageAirQualityMessageLanguageArray[languageArrayIdentifier];
      }
      if (co2Value < 800) {
        carbonStateOnSleepGif = "assets/fond-vert-veille.gif";
        carbonStateOnHome = "assets/personnage-vert.png";
        carbonStateOnHomeMessage = goodAirQualityMessageLanguageArray[languageArrayIdentifier];
      }
      if (deviceWifiState) {
        myWifiState = 'assets/green-wifi.png';
      } else {
        myWifiState = 'assets/red-wifi.png';
      }
      if (stateOfSleepAndReadingProcess == 0) {
        try {
          if (myDevice.getConnectionState()) {
            if (Platform.isAndroid) {
              dataCharAndroid1 = String.fromCharCodes(await characteristicSensors.read());
              sensorsData = jsonDecode(dataCharAndroid1);
            }
            if (Platform.isIOS) {
              dataCharIOS1p1 = String.fromCharCodes(await characteristicSensors.read());
              sensorsData = jsonDecode(dataCharIOS1p1);
            }
            String sensorsDataList = sensorsData['EnvData'].toString();
            deviceTimeValue = stringListAsciiToListInt(sensorsDataList.codeUnits)[0];
            detectionTimeValue = stringListAsciiToListInt(sensorsDataList.codeUnits)[1];
            temperatureValue = stringListAsciiToListInt(sensorsDataList.codeUnits)[2];
            humidityValue = stringListAsciiToListInt(sensorsDataList.codeUnits)[3];
            lightValue = stringListAsciiToListInt(sensorsDataList.codeUnits)[4];
            co2Value = stringListAsciiToListInt(sensorsDataList.codeUnits)[5];
            tvocValue = stringListAsciiToListInt(sensorsDataList.codeUnits)[6];
            deviceWifiState = intToBool(stringListAsciiToListInt(sensorsDataList.codeUnits)[7]);
            co2sensorStateValue = stringListAsciiToListInt(sensorsDataList.codeUnits)[8];
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
          print('setState erreur');
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
    controllerWifiAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (firstDisplayMainWidget) {
      try {
        stateOfSleepAndReadingProcess = 0;
        appRefreshData(context);
      } catch (e) {
        print('erreur home');
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
          title: Text(attentionTextLanguageArray[languageArrayIdentifier]),
          content: Text(backAlertDialogTitleLanguageArray[languageArrayIdentifier]),
          actions: [
            TextButton(
                child: Text(yesTextLanguageArray[languageArrayIdentifier]),
                onPressed: () async {
                  if (myDevice != null) {
                    await myDevice.disconnect();
                  }
                  stateOfSleepAndReadingProcess = 1;
                  homePageState = false;
                  Navigator.pop(c, true);
                }),
            TextButton(
              child: Text(noTextLanguageArray[languageArrayIdentifier]),
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
                  padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 10.0),
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
                          width: (widthScreen - sensorsTabPadding) / 5,
                          height: (heightScreen - sensorsTabPadding) / 5,
                          child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                            new SizedBox(width: 4.0),
                            new Text("${temperatureLanguageArray[languageArrayIdentifier]}\n$temperatureValue °C",
                                style: TextStyle(fontSize: widthScreen * 0.025, color: Color(0xFF264eb6), fontWeight: FontWeight.bold), textAlign: TextAlign.center)
                          ])),
                      Container(
                          width: (widthScreen - sensorsTabPadding) / 5,
                          height: (heightScreen - sensorsTabPadding) / 5,
                          child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                            new SizedBox(width: 4.0),
                            new Text(
                              "${humidityLanguageArray[languageArrayIdentifier]}\n$humidityValue %",
                              style: TextStyle(fontSize: widthScreen * 0.025, color: Color(0xFF264eb6), fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            )
                          ])),
                      Container(
                          width: (widthScreen - sensorsTabPadding) / 5,
                          height: (heightScreen - sensorsTabPadding) / 5,
                          child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                            new SizedBox(width: 4.0),
                            new Text(
                              "${brightnessLanguageArray[languageArrayIdentifier]}\n$lightValue lux",
                              style: TextStyle(fontSize: widthScreen * 0.025, color: Color(0xFF264eb6), fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            )
                          ])),
                      Container(
                          width: (widthScreen - sensorsTabPadding) / 5,
                          height: (heightScreen - sensorsTabPadding) / 5,
                          child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                            new SizedBox(width: 4.0),
                            new Text(
                              "${co2LanguageArray[languageArrayIdentifier]}\n$co2Value ppm",
                              style: TextStyle(fontSize: widthScreen * 0.025, color: Color(0xFF264eb6), fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            )
                          ])),
                      Container(
                          width: (widthScreen - sensorsTabPadding) / 5,
                          height: (heightScreen - sensorsTabPadding) / 5,
                          child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                            new SizedBox(width: 4.0),
                            new Text(
                              "${tvocLanguageArray[languageArrayIdentifier]}\n$tvocValue mg/m3",
                              style: TextStyle(fontSize: widthScreen * 0.025, color: Color(0xFF264eb6), fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            )
                          ])),
                    ],
                    selectedColor: Colors.white,
                    selectedBorderColor: Colors.white,
                    fillColor: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.0),
                        color: Color(0xFFFFFFF0),
                        shape: BoxShape.rectangle,
                      ),
                      height: heightScreen * 0.3,
                      width: widthScreen * 0.95,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                airQualityTextLanguageArray[languageArrayIdentifier],
                                style: TextStyle(
                                  color: Color(0xFF264eb6),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  fontSize: widthScreen * 0.04,
                                ),
                              ),
                              Text(
                                carbonStateOnHomeMessage,
                                style: TextStyle(
                                  color: Color(0xFF264eb6),
                                  fontWeight: FontWeight.bold,
                                  fontSize: widthScreen * 0.07,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Image.asset(
                          carbonStateOnHome,
                          height: heightScreen * 0.4,
                          width: widthScreen * 0.4,
                        ),
                        ScaleTransition(
                          scale: _animation,
                          child: Image.asset(
                            myWifiState,
                            height: heightScreen * 0.2,
                            width: widthScreen * 0.07,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18.0),
                              border: Border.all(color: Colors.white),
                              color: Colors.white.withOpacity(0.5),
                              shape: BoxShape.rectangle,
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              appTime,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF264eb6),
                                fontWeight: FontWeight.bold,
                                fontSize: widthScreen * 0.02 + heightScreen * 0.1,
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
                              border: Border.all(color: Colors.white),
                              color: Color(0xFF3a66d7),
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: TextButton(
                              onPressed: () {
                                alertDialogAnimated(context, LEDPage());
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    flex: 2,
                                    child: Image.asset(
                                      'assets/controlelumiere.png',
                                      height: heightScreen * 0.2,
                                      width: widthScreen * 0.2,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      lightControlTextLanguageArray[languageArrayIdentifier],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: widthScreen * 0.01 + heightScreen * 0.01,
                                      ),
                                    ),
                                  ),
                                ],
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
                              border: Border.all(color: Colors.white),
                              color: Color(0xFF3a66d7),
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: TextButton(
                              onPressed: () {
                                alertDialogAnimated(context, Settings());
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    flex: 2,
                                    child: Image.asset(
                                      'assets/reglages.png',
                                      height: heightScreen * 0.2,
                                      width: widthScreen * 0.2,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      settingsDeviceTextLanguageArray[languageArrayIdentifier],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: widthScreen * 0.01 + heightScreen * 0.01,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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

  Future<void> alertDialogAnimated(BuildContext buildContext, Object object) {
    double widthScreen = MediaQuery.of(buildContext).size.width;
    double heightScreen = MediaQuery.of(buildContext).size.height;
    var parsedJson;
    try {
      if (Platform.isAndroid) {
        parsedJson = json.decode(dataCharAndroid2);
      }
      if (Platform.isIOS) {
        parsedJson = json.decode(dataCharIOS2p3);
      }
      pinCodeAccess = parsedJson['PP'].toString();
    } catch (e) {
      print('erreur pin');
      pinCodeAccess = '1234';
    }
    return showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              shape: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    securityPINTextLanguageArray[languageArrayIdentifier],
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
                          buttonNumbers('0', buildContext, object),
                          SizedBox(width: widthScreen * 0.003),
                          buttonNumbers('1', buildContext, object),
                          SizedBox(width: widthScreen * 0.003),
                          buttonNumbers('2', buildContext, object),
                          SizedBox(width: widthScreen * 0.003),
                          buttonNumbers('3', buildContext, object),
                          SizedBox(width: widthScreen * 0.003),
                          buttonNumbers('4', buildContext, object),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buttonNumbers('5', buildContext, object),
                          SizedBox(width: widthScreen * 0.003),
                          buttonNumbers('6', buildContext, object),
                          SizedBox(width: widthScreen * 0.003),
                          buttonNumbers('7', buildContext, object),
                          SizedBox(width: widthScreen * 0.003),
                          buttonNumbers('8', buildContext, object),
                          SizedBox(width: widthScreen * 0.003),
                          buttonNumbers('9', buildContext, object),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) => null,
    );
  }

  ButtonTheme buttonNumbers(String number, BuildContext buildContext, Object object) {
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
            Navigator.pop(buildContext);
            if (myPinCode == pinCodeAccess) {
              stateOfSleepAndReadingProcess = 2;
              createRoute(context, object);
            } else {
              myUvcToast.setToastDuration(3);
              myUvcToast.setToastMessage(invalidPINCodeToastTextLanguageArray[languageArrayIdentifier]);
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
