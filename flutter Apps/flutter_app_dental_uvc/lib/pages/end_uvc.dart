import 'package:flutter/material.dart';
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

class _EndUVCState extends State<EndUVC> {
  Device myDevice;
  bool isTreatmentCompleted;

  Map endUVCClassData = {};

  UVCDataFile uvcDataFile;

  UvcLight myUvcLight;

  List<List<String>> uvcData;

  bool firstDisplayMainWidget = true;
  LedControl ledControl;

  int activationTime;

  void csvDataFile() async {
    uvcDataFile = UVCDataFile();
    ledControl = LedControl();
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

    await ledControl.setLedColor('ON');
    await Future.delayed(const Duration(milliseconds: 50));

    if (isTreatmentCompleted) {
      uvcOperationData.add('Valide');
      await ledControl.setLedColor('GREEN');
    } else {
      uvcOperationData.add('Incident');
      await ledControl.setLedColor('RED');
    }

    uvcData.add(uvcOperationData);

    await uvcDataFile.saveUVCDATA(uvcData);
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
    }

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

  Future<bool> exitApp(BuildContext context) async {
    Navigator.pushNamedAndRemoveUntil(context, "/pin_access", (r) => false);
    return true;
  }
}
