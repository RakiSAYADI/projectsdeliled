import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterdmxapp/services/bleDeviceClass.dart';
import 'package:flutterdmxapp/services/uvcClass.dart';
import 'package:slide_countdown_clock/slide_countdown_clock.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class UVC extends StatefulWidget {
  @override
  _UVCState createState() => _UVCState();
}

class _UVCState extends State<UVC> {
  Duration durationOfDisinfect;
  Duration durationOfActivate;

  Map uvcClassData = {};
  UvcLight myUvcLight;

  Device myDevice;

  double opacityLevelDisinfection = 0.0;
  double opacityLevelActivation = 1.0;

  bool stopTreatment;

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
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0,
        'Félicitation',
        'La désinfection de la pièce a été réalisée avec succés !',
        platformChannelSpecifics,
        payload: 'item x');
  }

  @override
  void initState() {
    // TODO: implement initState
    stopTreatment=false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    uvcClassData = uvcClassData.isNotEmpty
        ? uvcClassData
        : ModalRoute.of(context).settings.arguments;
    myUvcLight = uvcClassData['uvclight'];
    myDevice = uvcClassData['myDevice'];

    durationOfDisinfect = Duration(seconds: myUvcLight.getActivationTime());
    if (myUvcLight.infectionTime.contains('sec')) {
      durationOfActivate = Duration(
          seconds:
              myUvcLight.getActivationTime() + myUvcLight.getInfectionTime());
    } else {
      durationOfActivate = Duration(
          minutes: myUvcLight.getInfectionTime(),
          seconds: myUvcLight.getActivationTime());
    }

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('UVC'),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/fondapplication.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'La désinfection débutera dans :',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                AnimatedOpacity(
                  curve: Curves.linear,
                  opacity: opacityLevelActivation,
                  duration: Duration(seconds: myUvcLight.getActivationTime()),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: SlideCountdownClock(
                      duration: durationOfDisinfect,
                      slideDirection: SlideDirection.Up,
                      separator: ":",
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      separatorTextStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                      onDone: () async{
                        String message = 'UVCTreatement : ON';
                        await myDevice.writeCharacteristic(2, 0, message);
                        message = 'safetyTime : OFF';
                        await myDevice.writeCharacteristic(2, 0, message);
                        _changeOpacityDisinfection();
                        _changeOpacityActivation();
                      },
                    ),
                  ),
                ),
                _buildSpace(),
                Text(
                  'La désinfection finira dans :',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                AnimatedOpacity(
                  curve: Curves.linear,
                  opacity: opacityLevelDisinfection,
                  duration: Duration(seconds: myUvcLight.getActivationTime()),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: SlideCountdownClock(
                      duration: durationOfActivate,
                      slideDirection: SlideDirection.Up,
                      separator: ":",
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      separatorTextStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.green, shape: BoxShape.circle),
                      onDone: () async{
                        if(!stopTreatment){
                          print('finished activation');
                          String message = 'UVCTreatement : OFF';
                          await myDevice.writeCharacteristic(2, 0, message);
                          _getNotification();
                          myDevice.disconnect();
                          Navigator.pushNamedAndRemoveUntil(
                              context, "/access_pin", (r) => false);
                          return showDialog<void>(
                            context: context,
                            builder: (BuildContext contextAlertWidget) {
                              return AlertDialog(
                                title: Text('Félicitation'),
                                content: Text(
                                    'La désinfection de la pièce a été réalisée avec succés'),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text(
                                      'Terminer',
                                      style: TextStyle(color: Colors.green),
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(contextAlertWidget, true),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ),
                _buildSpace(),
                FlatButton(
                  color: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.red)),
                  child: Text(
                    'STOP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () => stopSecurity(context),
                ),
              ],
            ),
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
            onPressed: () async{
              //Stop UVC processing
              stopTreatment=true;
              String message = 'STOP : ON';
              await myDevice.writeCharacteristic(2, 0, message);
              myDevice.disconnect();
              Navigator.pop(c, true);
              Navigator.pushNamedAndRemoveUntil(
                  context, "/access_pin", (r) => false);
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

  Widget _buildSpace() {
    return SizedBox(height: MediaQuery.of(context).size.height * 0.1);
  }
}
