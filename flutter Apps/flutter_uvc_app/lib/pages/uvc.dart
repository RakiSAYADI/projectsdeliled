import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutteruvcapp/services/bleDeviceClass.dart';
import 'package:flutteruvcapp/services/custum_timer_painter.dart';
import 'package:flutteruvcapp/services/uvcClass.dart';
import 'package:flutteruvcapp/services/uvcToast.dart';
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

  Map uvcClassData = {};
  UvcLight myUvcLight;

  ToastyMessage myUvcToast;

  Device myDevice;

  double opacityLevelDisinfection = 0.0;
  double opacityLevelActivation = 1.0;

  bool treatmentIsStopped;
  bool treatmentIsOnProgress;
  bool treatmentIsSuccessful;

  String dataRobotUVC = '';

  bool firstDisplayMainWidget = true;

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
    var androidPlatformChannelSpecifics = AndroidNotificationDetails('your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true, badgeNumber: 1);
    var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, 'Félicitation', 'La désinfection de la pièce a été réalisée avec succés !', platformChannelSpecifics, payload: 'item x');
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

  void readingCharacteristic() async {
    print('the read methode !');
    Map<String, dynamic> dataRead;
    int detectionResult = 0;
    do {
      if (!myDevice.getConnectionState()) {
        myUvcToast = ToastyMessage(toastContext: context);
        myUvcToast.setToastDuration(5);
        myUvcToast.setToastMessage('Connexion perdue avec le robot !');
        myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
        myDevice.disconnect();
        Navigator.pushNamedAndRemoveUntil(context, "/bluetooth_activation", (r) => false);
      }
      if (treatmentIsOnProgress) {
        if (Platform.isIOS) {
          await myDevice.readCharacteristic(0, 0);
        } else {
          await myDevice.readCharacteristic(2, 0);
        }
        dataRobotUVC = myDevice.getReadCharMessage();
        dataRead = jsonDecode(dataRobotUVC);
        detectionResult = int.parse(dataRead['Detection'].toString());
        // detectionResult = 0 ;
        if (detectionResult == 0) {
          print('No detection , KEEP THE TREATMENT PROCESS !');
        } else {
          print('detection captured , STOP EVERYTHING !');
          treatmentIsOnProgress = false;
          treatmentIsSuccessful = false;
          Navigator.pushNamed(context, '/end_uvc', arguments: {
            'treatmentCompleted': treatmentIsSuccessful,
            'myDevice': myDevice,
          });
          break;
        }
        await Future.delayed(const Duration(seconds: 1));
      } else {
        break;
      }
    } while (true);
  }

  @override
  Widget build(BuildContext context) {
    uvcClassData = uvcClassData.isNotEmpty ? uvcClassData : ModalRoute.of(context).settings.arguments;
    myUvcLight = uvcClassData['uvclight'];
    myDevice = uvcClassData['myDevice'];

    readingCharacteristic();

    durationOfDisinfect = Duration(seconds: myUvcLight.getActivationTime());
    if (myUvcLight.infectionTime.contains('sec')) {
      durationOfActivate = Duration(seconds: myUvcLight.getActivationTime() + myUvcLight.getInfectionTime());
    } else {
      durationOfActivate = Duration(minutes: myUvcLight.getInfectionTime(), seconds: myUvcLight.getActivationTime());
    }

    if (firstDisplayMainWidget) {
      firstDisplayMainWidget = false;
      controllerAnimationTimeBackground.duration = Duration(seconds: myUvcLight.getActivationTime());

      controllerAnimationTimeBackground.reverse(from: controllerAnimationTimeBackground.value == 0.0 ? 1.0 : controllerAnimationTimeBackground.value);
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Désinfection en cours'),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.05),
              Image.asset(
                'assets/logo_deeplight.png',
                height: screenHeight * 0.05,
                width: screenWidth * 0.5,
              ),
              AnimatedBuilder(
                animation: controllerAnimationTimeBackground,
                builder: (context, child) {
                  return Expanded(
                    child: Align(
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
                                            'La désinfection débutera dans :',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                              fontSize: screenWidth * 0.04,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(10),
                                            child: SlideCountdownClock(
                                              duration: durationOfDisinfect,
                                              slideDirection: SlideDirection.Up,
                                              separator: ":",
                                              textStyle: TextStyle(
                                                fontSize: screenWidth * 0.04,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[300],
                                              ),
                                              separatorTextStyle: TextStyle(
                                                fontSize: screenWidth * 0.04,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red,
                                              ),
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                              onDone: () async {
                                                _changeOpacityDisinfection();
                                                _changeOpacityActivation();
                                                setState(() {
                                                  circleColor = Colors.green;
                                                  controllerAnimationTimeBackground.duration =
                                                      Duration(seconds: (durationOfActivate.inSeconds - durationOfDisinfect.inSeconds));
                                                  print(durationOfActivate.inSeconds);
                                                  print(myUvcLight.getInfectionTime());
                                                  controllerAnimationTimeBackground.reverse(
                                                      from: controllerAnimationTimeBackground.value == 0.0
                                                          ? 1.0
                                                          : controllerAnimationTimeBackground.value);
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    GestureDetector(
                                      onTap: () => stopSecurity(context),
                                      child: ClipOval(
                                        child: Container(
                                          color: Colors.red,
                                          height: screenHeight * 0.1,
                                          width: screenWidth * 0.2,
                                          child: Center(
                                            child: Text(
                                              'STOP',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[300],
                                                fontSize: screenWidth * 0.04,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
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
                                            'La désinfection finira dans :',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                              fontSize: screenWidth * 0.04,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(10),
                                            child: SlideCountdownClock(
                                              duration: durationOfActivate,
                                              slideDirection: SlideDirection.Up,
                                              separator: ":",
                                              textStyle: TextStyle(
                                                fontSize: screenWidth * 0.04,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[300],
                                              ),
                                              separatorTextStyle: TextStyle(
                                                fontSize: screenWidth * 0.04,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                                              onDone: () async {
                                                treatmentIsSuccessful = true;
                                                if ((!treatmentIsStopped) && treatmentIsOnProgress) {
                                                  print('finished activation');
                                                  treatmentIsOnProgress = false;
                                                  _getNotification();
                                                  Navigator.pushNamed(context, '/end_uvc', arguments: {
                                                    'myDevice': myDevice,
                                                    'treatmentCompleted': treatmentIsSuccessful,
                                                  });
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
                    ),
                  );
                },
              ),
              Image.asset(
                'assets/logodelitechblanc.png',
                height: screenHeight * 0.05,
                width: screenWidth * 0.7,
              ),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
      onWillPop: () => stopSecurity(context),
    );
  }

  Future<void> stopSecurity(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Attention'),
        content: Text('Voulez-vous vraiment annuler le traitement UVC ?'),
        actions: [
          FlatButton(
            child: Text('Oui'),
            onPressed: () async {
              //Stop UVC processing
              treatmentIsStopped = true;
              treatmentIsOnProgress = false;
              treatmentIsSuccessful = false;
              String message = 'STOP : ON';
              if (Platform.isIOS) {
                await myDevice.writeCharacteristic(0, 0, message);
              } else {
                await myDevice.writeCharacteristic(2, 0, message);
              }
              Navigator.pop(c, true);
              Navigator.pushNamed(context, '/end_uvc', arguments: {
                'myDevice': myDevice,
                'treatmentCompleted': treatmentIsSuccessful,
              });
            },
          ),
          FlatButton(
            child: Text('Non'),
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
}
