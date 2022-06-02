import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:wifiglobalapp/services/custom_timer_painter.dart';
import 'package:wifiglobalapp/services/data_variables.dart';
import 'package:wifiglobalapp/services/language_database.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class UVC extends StatefulWidget {
  @override
  _UVCState createState() => _UVCState();
}

class _UVCState extends State<UVC> with TickerProviderStateMixin {
  late AnimationController controllerAnimationTimeBackground;
  int durationInSeconds = 0;
  Color circleColor = Colors.red;

  Duration durationOfDisinfect = Duration();
  Duration durationOfActivate = Duration();

  double opacityLevelDisinfection = 0.0;
  double opacityLevelActivation = 1.0;

  bool treatmentIsStopped = false;
  bool treatmentIsOnProgress = true;
  bool treatmentIsSuccessful = false;

  String dataRobotUVC = '';

  bool firstDisplayMainWidget = true;

  bool alertOrUVC = false;

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
    controllerAnimationTimeBackground = AnimationController(vsync: this);
    durationOfDisinfect = Duration(seconds: myDevice.disinfectionTime);
    durationOfActivate = Duration(seconds: myDevice.disinfectionTime + myDevice.activationTime);
    controllerAnimationTimeBackground.duration = Duration(seconds: myDevice.disinfectionTime);
    controllerAnimationTimeBackground.reverse(from: controllerAnimationTimeBackground.value == 0.0 ? 1.0 : controllerAnimationTimeBackground.value);
    _readingCharacteristic();
    super.initState();
  }

  void _readingCharacteristic() async {
    debugPrint('the read methode !');
    Map<String, dynamic> dataRead;
    int detectionResult = 0;
    bool result = false;
    do {
      if (treatmentIsOnProgress) {
        try {
          result = await myDevice.getDeviceData();
          if (result) {
            dataRead = myDevice.getData();
            detectionResult = int.parse(dataRead['detect'].toString());
          }
          if (detectionResult == 0) {
            debugPrint('No detection , KEEP THE TREATMENT PROCESS !');
          } else {
            debugPrint('detection captured , STOP EVERYTHING !');
            treatmentIsOnProgress = false;
            treatmentIsSuccessful = false;
            activationTime = (durationOfActivate.inSeconds - durationOfDisinfect.inSeconds);
            isTreatmentCompleted = treatmentIsSuccessful;
            sleepIsInactiveEndUVC = false;
            Navigator.pushNamed(context, '/end_uvc');
            break;
          }
        } catch (e) {
          debugPrint('uvc data : ${e.toString()}');
        }
      } else {
        break;
      }
      await Future.delayed(const Duration(seconds: 3));
    } while (true);
  }

  @override
  Widget build(BuildContext context) {
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
                                    duration: const Duration(seconds: 5),
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
                                          child: SlideCountdownSeparated(
                                            duration: durationOfDisinfect,
                                            slideDirection: SlideDirection.down,
                                            separator: ":",
                                            textStyle: TextStyle(
                                              fontSize: widthScreen * 0.02 + heightScreen * 0.02,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[300],
                                            ),
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                            onDone: () async {
                                              _changeOpacityDisinfection();
                                              _changeOpacityActivation();
                                              alertOrUVC = true;
                                              debugPrint('alert is completed');
                                              setState(() {
                                                circleColor = Colors.green;
                                                controllerAnimationTimeBackground.duration = Duration(seconds: (durationOfActivate.inSeconds - durationOfDisinfect.inSeconds));
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
                                    onTap: () => _stopSecurity(context),
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
                                    duration: const Duration(seconds: 5),
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
                                          child: SlideCountdownSeparated(
                                            duration: durationOfActivate,
                                            slideDirection: SlideDirection.down,
                                            separator: ":",
                                            textStyle: TextStyle(
                                              fontSize: widthScreen * 0.02 + heightScreen * 0.02,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[300],
                                            ),
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                                            onDone: () async {
                                              treatmentIsSuccessful = true;
                                              alertOrUVC = false;
                                              if ((!treatmentIsStopped) && treatmentIsOnProgress) {
                                                debugPrint('finished activation');
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
      onWillPop: () => _stopSecurity(context),
    );
  }

  Future<bool> _stopSecurity(BuildContext context) async {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return (await showDialog<bool>(
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
                  myDevice.setDeviceToStop();
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
        ) ??
        false);
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
