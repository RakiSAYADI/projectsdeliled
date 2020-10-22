import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutteruvcapp/services/bleDeviceClass.dart';
import 'package:flutteruvcapp/services/uvcClass.dart';
import 'package:flutteruvcapp/services/uvcToast.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Map settingsClassData = {};
  Device myDevice;

  UvcLight myUvcLight;

  ToastyMessage myUvcToast;

  String myExtinctionTimeMinuteData = ' 30 sec';
  String myActivationTimeMinuteData = ' 10 sec';

  bool firstDisplayMainWidget = true;

  int myExtinctionTimeMinutePosition = 0;
  int myActivationTimeMinutePosition = 0;

  List<String> myExtinctionTimeMinute = [
    ' 30 sec',
    '  1 min',
    '  2 min',
    '  5 min',
    ' 10 min',
    ' 15 min',
    ' 20 min',
    ' 25 min',
    ' 30 min',
    ' 35 min',
    ' 40 min',
    ' 45 min',
    ' 50 min',
    ' 55 min',
    ' 60 min',
    ' 65 min',
    ' 70 min',
    ' 75 min',
    ' 80 min',
    ' 85 min',
    ' 90 min',
    ' 95 min',
    '100 min',
    '105 min',
    '110 min',
    '115 min',
    '120 min',
  ];

  List<String> myActivationTimeMinute = [
    ' 10 sec',
    ' 20 sec',
    ' 30 sec',
    ' 40 sec',
    ' 50 sec',
    ' 60 sec',
    ' 70 sec',
    ' 80 sec',
    ' 90 sec',
    '100 sec',
    '110 sec',
    '120 sec',
  ];

  @override
  Widget build(BuildContext context) {
    settingsClassData = settingsClassData.isNotEmpty ? settingsClassData : ModalRoute.of(context).settings.arguments;
    myDevice = settingsClassData['myDevice'];
    myUvcLight = settingsClassData['myUvcLight'];
    if (firstDisplayMainWidget) {
      myExtinctionTimeMinutePosition = settingsClassData['disinfectionTime'];
      myActivationTimeMinutePosition = settingsClassData['activationTime'];
      firstDisplayMainWidget = false;
      myExtinctionTimeMinuteData = myExtinctionTimeMinute.elementAt(myExtinctionTimeMinutePosition);
      myActivationTimeMinuteData = myActivationTimeMinute.elementAt(myActivationTimeMinutePosition);
    }
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Container(
          width: screenWidth,
          height: screenHeight,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: screenHeight * 0.04),
                  Image.asset(
                    'assets/delais_logo.png',
                    height: screenHeight * 0.09,
                    width: screenWidth * 0.5,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Text(
                    'Délais avant allumage :',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.black,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
                    child: DropdownButton<String>(
                      value: myActivationTimeMinuteData,
                      icon: Icon(Icons.arrow_drop_down),
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(color: Colors.grey[800], fontSize: 18),
                      underline: Container(
                        height: 2,
                        color: Colors.blue[300],
                      ),
                      onChanged: (String data) {
                        setState(() {
                          myActivationTimeMinuteData = data;
                          myActivationTimeMinutePosition = myActivationTimeMinute.indexOf(data);
                        });
                      },
                      items: myActivationTimeMinute.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Image.asset(
                    'assets/duree_logo.png',
                    height: screenHeight * 0.09,
                    width: screenWidth * 0.5,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Text(
                    'Durée de la désinfection :',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.black,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
                    child: DropdownButton<String>(
                      value: myExtinctionTimeMinuteData,
                      icon: Icon(Icons.arrow_drop_down),
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(color: Colors.grey[800], fontSize: 18),
                      underline: Container(
                        height: 2,
                        color: Colors.blue[300],
                      ),
                      onChanged: (String data) {
                        setState(() {
                          myExtinctionTimeMinuteData = data;
                          myExtinctionTimeMinutePosition = myExtinctionTimeMinute.indexOf(data);
                        });
                      },
                      items: myExtinctionTimeMinute.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  FlatButton(
                    onPressed: () {
                      if (myDevice.getConnectionState()) {
                        alertSecurity(context);
                      } else {
                        myUvcToast = ToastyMessage(toastContext: context);
                        myUvcToast.setToastDuration(5);
                        myUvcToast.setToastMessage('Connexion perdue avec le robot !');
                        myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
                        myDevice.disconnect();
                        Navigator.pushNamedAndRemoveUntil(context, "/check_permissions", (r) => false);
                      }
                    },
                    child: Text(
                      'DÉMARRER',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.blue[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> alertSecurity(BuildContext context) async {
    myUvcLight.setInfectionTime(myExtinctionTimeMinuteData);
    myUvcLight.setActivationTime(myActivationTimeMinuteData);
    if (Platform.isIOS) {
      await myDevice.writeCharacteristic(0, 0,
          '{\"data\":[\"${myUvcLight.getCompanyName()}\",\"${myUvcLight.getOperatorName()}\",\"${myUvcLight.getRoomName()}\",$myExtinctionTimeMinutePosition,$myActivationTimeMinutePosition]}');
    } else {
      await myDevice.writeCharacteristic(2, 0,
          '{\"data\":[\"${myUvcLight.getCompanyName()}\",\"${myUvcLight.getOperatorName()}\",\"${myUvcLight.getRoomName()}\",$myExtinctionTimeMinutePosition,$myActivationTimeMinutePosition]}');
    }
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Vérifiez vos informations :',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
              SizedBox(height: screenHeight * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Image.asset(
                      'assets/etablissement_logo.png',
                      height: screenHeight * 0.06,
                      width: screenWidth * 0.3,
                    ),
                  ),
                  Expanded(
                      flex: 3,
                      child: Text(
                        '${myUvcLight.getCompanyName()}',
                        style: TextStyle(fontSize: screenWidth * 0.04),
                      )),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Image.asset(
                      'assets/operateur_logo.png',
                      height: screenHeight * 0.06,
                      width: screenWidth * 0.3,
                    ),
                  ),
                  Expanded(
                      flex: 3,
                      child: Text(
                        '${myUvcLight.getOperatorName()}',
                        style: TextStyle(fontSize: screenWidth * 0.04),
                      )),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Image.asset(
                      'assets/piece_logo.png',
                      height: screenHeight * 0.06,
                      width: screenWidth * 0.3,
                    ),
                  ),
                  Expanded(
                      flex: 3,
                      child: Text(
                        '${myUvcLight.getRoomName()}',
                        style: TextStyle(fontSize: screenWidth * 0.04),
                      )),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Image.asset(
                      'assets/delais_logo.png',
                      height: screenHeight * 0.06,
                      width: screenWidth * 0.3,
                    ),
                  ),
                  Expanded(
                      flex: 3,
                      child: Text(
                        '${myUvcLight.getActivationTimeOnString().replaceAll(new RegExp(r"\s+"), "")}',
                        style: TextStyle(fontSize: screenWidth * 0.04),
                      )),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Image.asset(
                      'assets/duree_logo.png',
                      height: screenHeight * 0.06,
                      width: screenWidth * 0.3,
                    ),
                  ),
                  Expanded(
                      flex: 3,
                      child: Text(
                        '${myUvcLight.getInfectionTimeOnString().replaceAll(new RegExp(r"\s+"), "")}',
                        style: TextStyle(fontSize: screenWidth * 0.04),
                      )),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'OK',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/warnings', arguments: {
                  'myDevice': myDevice,
                  'myUvcLight': myUvcLight,
                });
              },
            ),
            FlatButton(
              child: Text(
                'Annuler',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
