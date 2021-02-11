import 'package:flutter/material.dart';
import 'package:flutterappdentaluvc/services/bleDeviceClass.dart';
import 'package:flutterappdentaluvc/services/uvcClass.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Map settingsClassData = {};
  Device myDevice;

  UvcLight myUvcLight;

  bool nextButtonPressedOnce = false;

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

    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: heightScreen * 0.04),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/delais_logo.png',
                          height: heightScreen * 0.09,
                          width: widthScreen * 0.5,
                        ),
                        SizedBox(height: heightScreen * 0.03),
                        Text(
                          'Délais avant allumage :',
                          style: TextStyle(
                            fontSize: widthScreen * 0.03,
                            color: Colors.black,
                          ),
                        ),
                        DropdownButton<String>(
                          value: myActivationTimeMinuteData,
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(color: Colors.grey[800], fontSize: 18),
                          onChanged: (String data) {
                            setState(() {
                              myActivationTimeMinuteData = data;
                              myActivationTimeMinutePosition = myActivationTimeMinute.indexOf(data);
                              print(myActivationTimeMinutePosition);
                            });
                          },
                          items: myActivationTimeMinute.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontSize: widthScreen * 0.03,
                                  color: Colors.grey[600],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Image.asset(
                          'assets/duree_logo.png',
                          height: heightScreen * 0.09,
                          width: widthScreen * 0.5,
                        ),
                        SizedBox(height: heightScreen * 0.03),
                        Text(
                          'Durée de la désinfection :',
                          style: TextStyle(
                            fontSize: widthScreen * 0.03,
                            color: Colors.black,
                          ),
                        ),
                        DropdownButton<String>(
                          value: myExtinctionTimeMinuteData,
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(color: Colors.grey[800], fontSize: widthScreen * 0.04),
                          onChanged: (String data) {
                            setState(() {
                              myExtinctionTimeMinuteData = data;
                              myExtinctionTimeMinutePosition = myExtinctionTimeMinute.indexOf(data);
                              print(myExtinctionTimeMinutePosition);
                            });
                          },
                          items: myExtinctionTimeMinute.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontSize: widthScreen * 0.03,
                                  color: Colors.grey[600],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: heightScreen * 0.1),
                FlatButton(
                  onPressed: () {
                    if (!nextButtonPressedOnce) {
                      nextButtonPressedOnce = true;
                      alertSecurity(context);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'DÉMARRER',
                      style: TextStyle(color: Colors.white, fontSize: widthScreen * 0.02),
                    ),
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
    );
  }

  Future<void> alertSecurity(BuildContext context) async {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    myUvcLight.setInfectionTime(myExtinctionTimeMinuteData);
    myUvcLight.setActivationTime(myActivationTimeMinuteData);
    print(myExtinctionTimeMinutePosition);
    print(myActivationTimeMinutePosition);
    await myDevice.writeCharacteristic(2, 0,
        '{\"data\":[\"${myUvcLight.getCompanyName()}\",\"${myUvcLight.getOperatorName()}\",\"${myUvcLight.getRoomName()}\",$myExtinctionTimeMinutePosition,$myActivationTimeMinutePosition]}');
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
                'Confirmer ces informations :',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: widthScreen * 0.03),
              ),
              SizedBox(height: heightScreen * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Image.asset(
                      'assets/etablissement_logo.png',
                      height: heightScreen * 0.05,
                      width: widthScreen * 0.15,
                    ),
                  ),
                  Expanded(
                      flex: 3,
                      child: Text(
                        '${myUvcLight.getCompanyName()}',
                        style: TextStyle(fontSize: widthScreen * 0.03),
                      )),
                ],
              ),
              SizedBox(height: heightScreen * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Image.asset(
                      'assets/operateur_logo.png',
                      height: heightScreen * 0.05,
                      width: widthScreen * 0.15,
                    ),
                  ),
                  Expanded(
                      flex: 3,
                      child: Text(
                        '${myUvcLight.getOperatorName()}',
                        style: TextStyle(fontSize: widthScreen * 0.03),
                      )),
                ],
              ),
              SizedBox(height: heightScreen * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Image.asset(
                      'assets/piece_logo.png',
                      height: heightScreen * 0.05,
                      width: widthScreen * 0.15,
                    ),
                  ),
                  Expanded(
                      flex: 3,
                      child: Text(
                        '${myUvcLight.getRoomName()}',
                        style: TextStyle(fontSize: widthScreen * 0.03),
                      )),
                ],
              ),
              SizedBox(height: heightScreen * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Image.asset(
                      'assets/delais_logo.png',
                      height: heightScreen * 0.05,
                      width: widthScreen * 0.15,
                    ),
                  ),
                  Expanded(
                      flex: 3,
                      child: Text(
                        '${myUvcLight.getActivationTimeOnString().replaceAll(new RegExp(r"\s+"), "")}',
                        style: TextStyle(fontSize: widthScreen * 0.03),
                      )),
                ],
              ),
              SizedBox(height: heightScreen * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Image.asset(
                      'assets/duree_logo.png',
                      height: heightScreen * 0.05,
                      width: widthScreen * 0.15,
                    ),
                  ),
                  Expanded(
                      flex: 3,
                      child: Text(
                        '${myUvcLight.getInfectionTimeOnString().replaceAll(new RegExp(r"\s+"), "")}',
                        style: TextStyle(fontSize: widthScreen * 0.03),
                      )),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'OK',
                style: TextStyle(color: Colors.green, fontSize: widthScreen * 0.02),
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
                style: TextStyle(color: Colors.green, fontSize: widthScreen * 0.02),
              ),
              onPressed: () {
                nextButtonPressedOnce = false;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
