import 'package:flutter/material.dart';
import 'package:wifiglobalapp/services/data_variables.dart';
import 'package:wifiglobalapp/services/language_database.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String myExtinctionTimeMinuteData = ' 10 sec';
  String myActivationTimeMinuteData = ' 30 sec';

  @override
  Widget build(BuildContext context) {
    myExtinctionTimeMinuteData = myExtinctionTimeMinute.elementAt(timeToDisinfectionArrayPosition(myDevice.disinfectionTime));
    myActivationTimeMinuteData = myActivationTimeMinute.elementAt(timeToActivationArrayPosition(myDevice.activationTime));

    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(parametersTextLanguageArray[languageArrayIdentifier]),
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
                          ignitionTimeMessageTextLanguageArray[languageArrayIdentifier],
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
                          onChanged: (String? data) {
                            setState(() {
                              myExtinctionTimeMinuteData = data!;
                              myDevice.disinfectionTime = disinfectionArrayPositionToTime(myExtinctionTimeMinute.indexOf(myExtinctionTimeMinuteData));
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
                    Column(
                      children: [
                        Image.asset(
                          'assets/duree_logo.png',
                          height: heightScreen * 0.09,
                          width: widthScreen * 0.5,
                        ),
                        SizedBox(height: heightScreen * 0.03),
                        Text(
                          disinfectionTimeMessageTextLanguageArray[languageArrayIdentifier],
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
                          onChanged: (String? data) {
                            setState(() {
                              myActivationTimeMinuteData = data!;
                              myDevice.activationTime = activationArrayPositionToTime(myActivationTimeMinute.indexOf(myActivationTimeMinuteData));
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
                  ],
                ),
                SizedBox(height: heightScreen * 0.1),
                TextButton(
                  onPressed: () {
                    alertSecurity(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      startTextLanguageArray[languageArrayIdentifier],
                      style: TextStyle(color: Colors.white, fontSize: widthScreen * 0.02),
                    ),
                  ),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
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
    return showDialog<void>(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext buildContext) {
        return AlertDialog(
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                confirmInfoTextLanguageArray[languageArrayIdentifier],
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
                        myDevice.deviceCompanyName,
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
                        myDevice.deviceOperatorName,
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
                        myDevice.deviceRoomName,
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
                        myExtinctionTimeMinute.elementAt(timeToDisinfectionArrayPosition(myDevice.disinfectionTime)),
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
                        myActivationTimeMinute.elementAt(timeToActivationArrayPosition(myDevice.activationTime)),
                        style: TextStyle(fontSize: widthScreen * 0.03),
                      )),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                okTextLanguageArray[languageArrayIdentifier],
                style: TextStyle(color: Colors.green, fontSize: widthScreen * 0.02),
              ),
              onPressed: () async {
                Navigator.of(buildContext).pop();
                myDevice.setDisinfectionProcess();
                Navigator.pushNamed(context, '/warnings');
              },
            ),
            TextButton(
              child: Text(
                cancelTextLanguageArray[languageArrayIdentifier],
                style: TextStyle(color: Colors.green, fontSize: widthScreen * 0.02),
              ),
              onPressed: () {
                Navigator.of(buildContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
