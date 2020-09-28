import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutteruvcapp/services/bleDeviceClass.dart';
import 'package:flutteruvcapp/services/uvcClass.dart';

class Profiles extends StatefulWidget {
  @override
  _ProfilesState createState() => _ProfilesState();
}

class _ProfilesState extends State<Profiles> {
  UvcLight myUvcLight;

  final myCompany = TextEditingController();
  final myName = TextEditingController();
  final myRoomName = TextEditingController();

  Map profilesClassData = {};

  Device myDevice;

  String dataRobotUVC = '';

  bool firstDisplayMainWidget = true;

  int myExtinctionTimeMinutePosition = 0;
  int myActivationTimeMinutePosition = 0;

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
    myCompany.dispose();
    myName.dispose();
    myRoomName.dispose();
    super.dispose();
  }

  List<int> _stringListAsciiToListInt(List<int> listInt) {
    List<int> ourListInt = [0];
    int listIntLength = listInt.length;
    int intNumber = (listIntLength / 4).round();
    ourListInt.length = intNumber;
    int listCounter;
    int listIntCounter = 0;
    String numberString = '';
    if (listInt.first == 91 && listInt.last == 93) {
      for (listCounter = 0; listCounter < listIntLength - 1; listCounter++) {
        if (!((listInt[listCounter] == 91) || (listInt[listCounter] == 93) || (listInt[listCounter] == 32) || (listInt[listCounter] == 44))) {
          numberString = '';
          do {
            numberString += String.fromCharCode(listInt[listCounter]);
            listCounter++;
          } while (!((listInt[listCounter] == 44) || (listInt[listCounter] == 93)));
          ourListInt[listIntCounter] = int.parse(numberString);
          listIntCounter++;
        }
      }
      return ourListInt;
    } else {
      return [0];
    }
  }

  IconButton settingsControl(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.settings,
        color: Colors.white,
      ),
      onPressed: () {
        settingsWidget(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    profilesClassData = profilesClassData.isNotEmpty ? profilesClassData : ModalRoute.of(context).settings.arguments;
    myDevice = profilesClassData['myDevice'];
    dataRobotUVC = profilesClassData['dataRead'];
    print(dataRobotUVC);
    if (dataRobotUVC == null) {
      dataRobotUVC = '{\"Company\":\"Votre entreprise\",\"UserName\":\"Utilisateur\",\"Detection\":0,\"RoomName\":\"Chambre 1\",\"TimeData\":[0,0]}';
    }

    Map<String, dynamic> user = jsonDecode(dataRobotUVC);

    print('company : ${user['Company']}!');
    print('username : ${user['UserName']}!');
    print('detection : ${user['Detection']}!');
    print('roomname : ${user['RoomName']}!');
    print('timedata : ${user['TimeData']}!');

    String timeDataList = user['TimeData'].toString();

    print(_stringListAsciiToListInt(timeDataList.codeUnits));

    if (dataRobotUVC.isNotEmpty && firstDisplayMainWidget) {
      firstDisplayMainWidget = false;
      myCompany.text = user['Company'];
      myName.text = user['UserName'];
      myRoomName.text = user['RoomName'];

      myExtinctionTimeMinutePosition = _stringListAsciiToListInt(timeDataList.codeUnits)[0];
      myActivationTimeMinutePosition = _stringListAsciiToListInt(timeDataList.codeUnits)[1];
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profil'),
          centerTitle: true,
          actions: [
            settingsControl(context),
          ],
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
                    SizedBox(height: screenHeight * 0.01),
                    Image.asset(
                      'assets/etablissement_logo.png',
                      height: screenHeight * 0.09,
                      width: screenWidth * 0.5,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.2)),
                      child: TextField(
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        controller: myCompany,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Colors.grey[800],
                        ),
                        decoration: InputDecoration(
                            hintText: 'Établissement',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            )),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Image.asset(
                      'assets/operateur_logo.png',
                      height: screenHeight * 0.09,
                      width: screenWidth* 0.5,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.2)),
                      child: TextField(
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        controller: myName,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Colors.grey[800],
                        ),
                        decoration: InputDecoration(
                            hintText: 'Opérateur',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            )),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Image.asset(
                      'assets/piece_logo.png',
                      height: screenHeight * 0.09,
                      width: screenWidth * 0.5,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.2)),
                      child: TextField(
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        controller: myRoomName,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                        ),
                        decoration: InputDecoration(
                            hintText: 'Pièce/local',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            )),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
                      child: Text(
                        'Merci de compléter ces informations pour garantir un suivi de désinfection optimal.',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    FlatButton(
                      onPressed: () {
                        myUvcLight = UvcLight(
                            machineName: myDevice.device.name,
                            machineMac: myDevice.device.id.toString(),
                            company: myCompany.text,
                            operatorName: myName.text,
                            roomName: myRoomName.text);
                        Navigator.pushNamed(context, '/settings', arguments: {
                          'myDevice': myDevice,
                          'myUvcLight': myUvcLight,
                          'disinfectionTime': myExtinctionTimeMinutePosition,
                          'activationTime': myActivationTimeMinutePosition,
                        });
                        //alertSecurity(context);
                      },
                      child: Text(
                        'SUIVANT',
                        style: TextStyle(color: Colors.white),
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
        ),
      ),
      onWillPop: () => disconnection(context),
    );
  }

  final myRobotName = TextEditingController();

  Future<void> settingsWidget(BuildContext context) {

    myRobotName.text = myDevice.device.name;

    double screenWidth = MediaQuery.of(context).size.width;
    //double screenHeight = MediaQuery.of(context).size.height;

    return showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Parametres'),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('static name'),
                SizedBox(width: screenWidth * 0.001),
                TextField(
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  controller: myRobotName,
                  decoration: InputDecoration(
                      hintText: '... nom du robot',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      )),
                ),
              ],
            ),
          ],
        ),
        actions: [
          FlatButton(
            child: Text('Sauvegarder et redemarrer'),
            onPressed: () {
              Navigator.pop(c, true);
              myDevice.disconnect();
              Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
            },
          ),
          FlatButton(
            child: Text('Annuler'),
            onPressed: () => Navigator.pop(c, false),
          ),
        ],
      ),
    );
  }

  Future<void> disconnection(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Attention'),
        content: Text('Voulez-vous vraiment quitter la page profil ?'),
        actions: [
          FlatButton(
            child: Text('Oui'),
            onPressed: () {
              Navigator.pop(c, true);
              myDevice.disconnect();
              Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
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
}
