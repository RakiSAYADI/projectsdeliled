import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gifimage/flutter_gifimage.dart';
import 'package:flutterappdentaluvc/services/CSVfileClass.dart';
import 'package:flutterappdentaluvc/services/LEDControl.dart';
import 'package:flutterappdentaluvc/services/bleDeviceClass.dart';
import 'package:flutterappdentaluvc/services/uvcClass.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class EndUVC extends StatefulWidget {
  @override
  _EndUVCState createState() => _EndUVCState();
}

class _EndUVCState extends State<EndUVC> with TickerProviderStateMixin {
  Device myDevice;
  bool isTreatmentCompleted;

  Map endUVCClassData = {};

  UVCDataFile uvcDataFile;

  UvcLight myUvcLight;

  List<List<String>> uvcData;

  bool firstDisplayMainWidget = true;
  LedControl ledControl;

  int activationTime;

  GifController gifController;

  Widget mainWidgetScreen;

  final int timeSleep = 120000;

  bool widgetIsInactive = false;

  int timeToSleep;

  @override
  void initState() {
    // TODO: implement initState
    gifController = GifController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    gifController.dispose();
    super.dispose();
  }

  void csvDataFile() async {
    uvcDataFile = UVCDataFile();
    if(Platform.isAndroid){
      ledControl = LedControl();
    }
    uvcData = await uvcDataFile.readUVCDATA();
    List<String> uvcOperationData = ['default'];
    uvcOperationData.length = 0;

    uvcOperationData.add(myUvcLight.getMachineName());
    uvcOperationData.add(myUvcLight.getOperatorName());
    uvcOperationData.add(myUvcLight.getCompanyName());
    uvcOperationData.add(myUvcLight.getRoomName());

    var dateTime = new DateTime.now();
    DateFormat dateFormat;
    DateFormat timeFormat;
    initializeDateFormatting();
    dateFormat = new DateFormat.yMd('fr');
    timeFormat = new DateFormat.Hm('fr');
    uvcOperationData.add(timeFormat.format(dateTime));
    uvcOperationData.add(dateFormat.format(dateTime));

    uvcOperationData.add(activationTime.toString());

    if(Platform.isAndroid){
      await ledControl.setLedColor('ON');
    }
    await Future.delayed(const Duration(milliseconds: 50));

    if (isTreatmentCompleted) {
      uvcOperationData.add('Valide');
      if(Platform.isAndroid){
        await ledControl.setLedColor('GREEN');
      }
    } else {
      uvcOperationData.add('Incident');
      if(Platform.isAndroid){
        await ledControl.setLedColor('RED');
      }
    }

    uvcData.add(uvcOperationData);

    await uvcDataFile.saveUVCDATA(uvcData);
  }

  Widget sleepWidget(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    // loop from 0 frame to 29 frame
    gifController.repeat(min: 0, max: 11, period: Duration(milliseconds: 1000));
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.blue[400],
        body: Center(
          child: GifImage(
            controller: gifController,
            fit: BoxFit.cover,
            height: heightScreen,
            width: widthScreen,
            image: AssetImage('assets/logo-delitech-animation.gif'),
          ),
        ),
      ),
    );
  }

  void screenSleep(BuildContext context) async {
    timeToSleep = timeSleep;
    do {
      timeToSleep -= 1000;
      if (timeToSleep == 0) {
        setState(() {
          mainWidgetScreen = sleepWidget(context);
        });
      }

      if (timeToSleep < 0) {
        timeToSleep = (-1000);
      }

      if (widgetIsInactive) {
        break;
      }
      await Future.delayed(Duration(seconds: 1));
    } while (true);
  }

  Widget appWidget(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;

    String title;
    String message;
    String imageGif;

    if (isTreatmentCompleted) {
      title = 'Désinfection terminée';
      message = 'Désinfection réalisée avec succès.';
      imageGif = 'assets/felicitation_animation.gif';
    } else {
      title = 'Désinfection annulée';
      message = 'Désinfection interrompue.';
      imageGif = 'assets/echec_logo.gif';
    }

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(color: Colors.grey[200]),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: widthScreen * 0.06,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: heightScreen * 0.05),
                  Image.asset(
                    imageGif,
                    height: heightScreen * 0.2,
                    width: widthScreen * 0.8,
                  ),
                  SizedBox(height: heightScreen * 0.05),
                  FlatButton(
                    onPressed: () {
                      myDevice.disconnect();
                      Navigator.pushNamedAndRemoveUntil(context, "/pin_access", (r) => false);
                    },
                    child: Text(
                      'Nouvelle désinfection',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: widthScreen * 0.05,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    color: Colors.blue[400],
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            widgetIsInactive = false;
            Navigator.pushNamed(context, '/DataCSVView', arguments: {
              'isTreatmentCompleted': isTreatmentCompleted,
              'uvclight': myUvcLight,
              'uvcData': uvcData,
            });
          },
          label: Text('Rapport'),
          icon: Icon(
            Icons.assignment,
            color: Colors.white,
          ),
          backgroundColor: Colors.blue[400],
        ),
      ),
      onWillPop: () => exitApp(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    endUVCClassData = endUVCClassData.isNotEmpty ? endUVCClassData : ModalRoute.of(context).settings.arguments;
    isTreatmentCompleted = endUVCClassData['treatmentCompleted'];
    activationTime = endUVCClassData['myactivationtime'];
    myDevice = endUVCClassData['myDevice'];
    myUvcLight = endUVCClassData['uvclight'];

    if (firstDisplayMainWidget) {
      firstDisplayMainWidget = false;
      myDevice.disconnect();
      csvDataFile();
      mainWidgetScreen = appWidget(context);
      screenSleep(context);
    }

    return GestureDetector(
      child: mainWidgetScreen,
      onTap: () {
        setState(() {
          timeToSleep = timeSleep;
          mainWidgetScreen = appWidget(context);
        });
      },
    );
  }

  Future<bool> exitApp(BuildContext context) async {
    widgetIsInactive = false;
    Navigator.pushNamedAndRemoveUntil(context, "/pin_access", (r) => false);
    return true;
  }
}
