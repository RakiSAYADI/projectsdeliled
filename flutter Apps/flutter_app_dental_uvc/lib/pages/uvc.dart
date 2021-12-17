import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterappdentaluvc/services/DataVariables.dart';
import 'package:flutterappdentaluvc/services/LEDControl.dart';
import 'package:flutterappdentaluvc/services/custom_timer_painter.dart';
import 'package:flutterappdentaluvc/services/languageDataBase.dart';
import 'package:slide_countdown_clock/slide_countdown_clock.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class UVC extends StatefulWidget {
  @override
  _UVCState createState() => _UVCState();
}

class _UVCState extends State<UVC> with TickerProviderStateMixin {
  AnimationController controllerAnimationTimeBackground;
  int durationInSeconds = 0;
  Color circleColor;

  Duration durationOfDisinfect;
  Duration durationOfActivate;

  double opacityLevelDisinfection = 0.0;
  double opacityLevelActivation = 1.0;

  bool treatmentIsStopped;
  bool treatmentIsOnProgress;
  bool treatmentIsSuccessful;

  String dataRobotUVC = '';

  bool firstDisplayMainWidget = true;

  bool alertOrUVC = false;

  LedControl ledControl;

  void _changeOpacityDisinfection() {
    setState(() {
      opacityLevelDisinfection = opacityLevelDisinfection == 0 ? 1.0 : 0.0;
    });
  }

  void _changeOpacityActivation() {
    setState(() {
      opacityLevelActivation = opacityLevelActivation == 0 ? 1.0 : 0.0;
    });
  }

  void _getNotification() async {
    var androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your channel id', 'your channel name', 'your channel description', importance: Importance.max, priority: Priority.high, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, congratulationMessageTextLanguageArray[languageArrayIdentifier], disinfectionGoodStateMessageTextLanguageArray[languageArrayIdentifier], platformChannelSpecifics, payload: 'item x');
  }

  @override
  void initState() {
    // TODO: implement initState
    treatmentIsStopped = false;
    treatmentIsOnProgress = true;
    treatmentIsSuccessful = false;
    durationInSeconds = 30;
    controllerAnimationTimeBackground = AnimationController(
      vsync: this,
    );
    circleColor = Colors.red;
    super.initState();
  }

  void alertLedRed() async {
    await ledControl.setLedColor('RED');
    do {
      await ledControl.setLedColor('ON');
      await Future.delayed(const Duration(milliseconds: 500));
      await ledControl.setLedColor('OFF');
      await Future.delayed(const Duration(milliseconds: 500));
      if (alertOrUVC) {
        break;
      }
    } while (true);
    await ledControl.setLedColor('ON');
    await Future.delayed(const Duration(milliseconds: 500));
    do {
      await ledControl.setLedColor('BLUE');
      await Future.delayed(const Duration(seconds: 2));
      await ledControl.setLedColor('RED');
      await Future.delayed(const Duration(seconds: 1));
      if (!alertOrUVC) {
        break;
      }
    } while (true);
  }

  void readingCharacteristic() async {
    print('the read methode !');
    Map<String, dynamic> dataRead;
    int detectionResult = 0;
    do {
      if (treatmentIsOnProgress) {
        if (myDevice.getConnectionState()) {
          if (Platform.isAndroid) {
            await myDevice.readCharacteristic(2, 0);
          }
          if (Platform.isIOS) {
            await myDevice.readCharacteristic(0, 0);
          }
          dataRobotUVC = myDevice.getReadCharMessage();
          dataRead = jsonDecode(dataRobotUVC);
          detectionResult = int.parse(dataRead['Detection'].toString());
        }
        if (detectionResult == 0) {
          print('No detection , KEEP THE TREATMENT PROCESS !');
        } else {
          print('detection captured , STOP EVERYTHING !');
          treatmentIsOnProgress = false;
          treatmentIsSuccessful = false;
          activationTime = (durationOfActivate.inSeconds - durationOfDisinfect.inSeconds);
          isTreatmentCompleted = treatmentIsSuccessful;
          sleepIsInactiveEndUVC = false;
          Navigator.pushNamed(context, '/end_uvc');
          break;
        }
      } else {
        break;
      }
      await Future.delayed(const Duration(seconds: 1));
    } while (true);
  }

  @override
  Widget build(BuildContext context) {
    durationOfDisinfect = Duration(seconds: myUvcLight.getActivationTime());
    if (myUvcLight.infectionTime.contains('sec')) {
      durationOfActivate = Duration(seconds: myUvcLight.getActivationTime() + myUvcLight.getInfectionTime());
    } else {
      durationOfActivate = Duration(minutes: myUvcLight.getInfectionTime(), seconds: myUvcLight.getActivationTime());
    }

    if (firstDisplayMainWidget) {
      firstDisplayMainWidget = false;

      if (Platform.isAndroid) {
        alertOrUVC = false;
        ledControl = LedControl();
        alertLedRed();
      }

      readingCharacteristic();

      controllerAnimationTimeBackground.duration = Duration(seconds: myUvcLight.getActivationTime());

      controllerAnimationTimeBackground.reverse(from: controllerAnimationTimeBackground.value == 0.0 ? 1.0 : controllerAnimationTimeBackground.value);
    }

    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(disinfectionOnProgressTextLanguageArray[languageArrayIdentifier], style: TextStyle(fontSize: widthScreen * 0.02 + heightScreen * 0.02)),
          centerTitle: true,
        ),
        body: Container(
          //decoration: BoxDecoration(color: Colors.grey[300]),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/fondapplication.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            child: Center(
              child: AnimatedBuilder(
                animation: controllerAnimationTimeBackground,
                builder: (context, child) {
                  return Align(
                    alignment: FractionalOffset.center,
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Positioned.fill(
                            child: CustomPaint(
                              painter: CustomTimerPainter(
                                animation: controllerAnimationTimeBackground,
                                backgroundColor: Colors.white,
                                color: circleColor,
                              ),
                            ),
                          ),
                          Container(
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  AnimatedOpacity(
                                    curve: Curves.linear,
                                    opacity: opacityLevelActivation,
                                    duration: Duration(seconds: myUvcLight.getActivationTime()),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          disinfectionStartOnTextLanguageArray[languageArrayIdentifier],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                            fontSize: widthScreen * 0.015 + heightScreen * 0.015,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(10),
                                          child: SlideCountdownClock(
                                            duration: durationOfDisinfect,
                                            slideDirection: SlideDirection.Up,
                                            separator: ":",
                                            textStyle: TextStyle(
                                              fontSize: widthScreen * 0.02 + heightScreen * 0.02,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[300],
                                            ),
                                            separatorTextStyle: TextStyle(
                                              fontSize: widthScreen * 0.02 + heightScreen * 0.02,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                            onDone: () async {
                                              _changeOpacityDisinfection();
                                              _changeOpacityActivation();
                                              alertOrUVC = true;
                                              print('alert is completed');
                                              setState(() {
                                                circleColor = Colors.green;
                                                controllerAnimationTimeBackground.duration = Duration(seconds: (durationOfActivate.inSeconds - durationOfDisinfect.inSeconds));
                                                print(durationOfActivate.inSeconds);
                                                print(myUvcLight.getInfectionTime());
                                                controllerAnimationTimeBackground.reverse(from: controllerAnimationTimeBackground.value == 0.0 ? 1.0 : controllerAnimationTimeBackground.value);
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildSpace(),
                                  GestureDetector(
                                    onTap: () => stopSecurity(context),
                                    child: ClipOval(
                                      child: Container(
                                        color: Colors.red,
                                        height: heightScreen * 0.1,
                                        width: widthScreen * 0.1,
                                        child: Center(
                                          child: Text(
                                            stopTextLanguageArray[languageArrayIdentifier],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[300],
                                              fontSize: widthScreen * 0.01 + heightScreen * 0.01,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  _buildSpace(),
                                  AnimatedOpacity(
                                    curve: Curves.linear,
                                    opacity: opacityLevelDisinfection,
                                    duration: Duration(seconds: myUvcLight.getActivationTime()),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          disinfectionStopOnTextLanguageArray[languageArrayIdentifier],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                            fontSize: widthScreen * 0.015 + heightScreen * 0.015,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(10),
                                          child: SlideCountdownClock(
                                            duration: durationOfActivate,
                                            slideDirection: SlideDirection.Up,
                                            separator: ":",
                                            textStyle: TextStyle(
                                              fontSize: widthScreen * 0.02 + heightScreen * 0.02,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[300],
                                            ),
                                            separatorTextStyle: TextStyle(
                                              fontSize: widthScreen * 0.02 + heightScreen * 0.02,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                                            onDone: () async {
                                              treatmentIsSuccessful = true;
                                              alertOrUVC = false;
                                              if ((!treatmentIsStopped) && treatmentIsOnProgress) {
                                                print('finished activation');
                                                treatmentIsOnProgress = false;
                                                _getNotification();
                                                activationTime = (durationOfActivate.inSeconds - durationOfDisinfect.inSeconds);
                                                isTreatmentCompleted = treatmentIsSuccessful;
                                                sleepIsInactiveEndUVC = false;
                                                Navigator.pushNamed(context, '/end_uvc');
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      onWillPop: () => stopSecurity(context),
    );
  }

  Future<void> stopSecurity(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(attentionTextLanguageArray[languageArrayIdentifier]),
        content: Text(
          disinfectionStopMessageTextLanguageArray[languageArrayIdentifier],
          style: TextStyle(
            fontSize: widthScreen * 0.01 + heightScreen * 0.01,
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              yesTextLanguageArray[languageArrayIdentifier],
              style: TextStyle(
                fontSize: widthScreen * 0.005 + heightScreen * 0.005,
              ),
            ),
            onPressed: () async {
              //Stop UVC processing
              alertOrUVC = !alertOrUVC;
              treatmentIsStopped = true;
              treatmentIsOnProgress = false;
              treatmentIsSuccessful = false;
              String message = 'STOP : ON';
              if (Platform.isAndroid) {
                await myDevice.writeCharacteristic(2, 0, message);
              }
              if (Platform.isIOS) {
                await myDevice.writeCharacteristic(0, 0, message);
              }
              Navigator.pop(c, true);
              activationTime = (durationOfActivate.inSeconds - durationOfDisinfect.inSeconds);
              isTreatmentCompleted = treatmentIsSuccessful;
              sleepIsInactiveEndUVC = false;
              Navigator.pushNamed(context, '/end_uvc');
            },
          ),
          TextButton(
            child: Text(
              noTextLanguageArray[languageArrayIdentifier],
              style: TextStyle(
                fontSize: widthScreen * 0.005 + heightScreen * 0.005,
              ),
            ),
            onPressed: () => Navigator.pop(c, false),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controllerAnimationTimeBackground.dispose();
    super.dispose();
  }

  Widget _buildSpace() {
    double heightScreen = MediaQuery.of(context).size.height;
    return SizedBox(height: heightScreen * 0.02);
  }
}
