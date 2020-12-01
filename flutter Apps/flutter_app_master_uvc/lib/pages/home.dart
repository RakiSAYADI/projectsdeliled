import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_master_uvc/services/bleDeviceClass.dart';
import 'package:flutter_app_master_uvc/services/uvcToast.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ToastyMessage myUvcToast;

  Map homeClassData = {};

  Device myDevice;

  String dataRobotUVC = '';

  bool firstDisplayMainWidget = true;

  String durationUVC = '122 heures';

  @override
  void initState() {
    // TODO: implement initState
    myUvcToast = ToastyMessage(toastContext: context);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    homeClassData = homeClassData.isNotEmpty ? homeClassData : ModalRoute.of(context).settings.arguments;
    myDevice = homeClassData['myDevice'];
    dataRobotUVC = homeClassData['dataRead'];

    if (dataRobotUVC == null) {
      dataRobotUVC = '{\"Company\":\"Votre entreprise\",\"UserName\":\"Utilisateur\",\"Detection\":0,\"RoomName\":\"Chambre 1\",\"TimeData\":[0,0]}';
    }

    if (dataRobotUVC.isNotEmpty && firstDisplayMainWidget) {
      Map<String, dynamic> data = jsonDecode(dataRobotUVC);
      print(data.toString());
      List<int> lifeCycleUVCList = [];
      String timeDataList = data['UVCTimeData'].toString();
      lifeCycleUVCList = _stringListAsciiToListInt(timeDataList.codeUnits);
      int lifeTimeCycle = lifeCycleUVCList[1];
      if (lifeTimeCycle < 60) {
        durationUVC = '$lifeTimeCycle secondes';
      } else if (lifeTimeCycle < 3600) {
        lifeTimeCycle = (lifeTimeCycle / 60).round();
        durationUVC = '$lifeTimeCycle minutes';
      } else {
        lifeTimeCycle = (lifeTimeCycle / 3600).round();
        durationUVC = '$lifeTimeCycle heures';
      }
      print(lifeCycleUVCList);

      firstDisplayMainWidget = false;
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Accueil'),
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
                    SizedBox(height: screenHeight * 0.02),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
                      child: Text(
                        'Fonctionnement des tubes UV-C:',
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
                      child: Text(
                        durationUVC,
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Divider(
                        thickness: 5.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    FlatButton(
                      onPressed: () async {
                        if (myDevice.getConnectionState()) {
                          if (Platform.isIOS) {
                            await myDevice.writeCharacteristic(0, 0, '{\"SetVersion\" :1}');
                          } else {
                            await myDevice.writeCharacteristic(2, 0, '{\"SetVersion\" :1}');
                          }
                          //startScan(context);
                        } else {
                          myUvcToast.setToastDuration(5);
                          myUvcToast.setToastMessage('Le dispositif est trop loin ou étient, merci de vérifier ce dernier');
                          myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
                          myDevice.disconnect();
                          Navigator.pushNamedAndRemoveUntil(context, "/check_permissions", (r) => false);
                        }
                      },
                      child: Text(
                        'Changer le type de pilotage automatique/manuel',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.06),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      color: Colors.blue[400],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    FlatButton(
                      onPressed: () async {
                        if (myDevice.getConnectionState()) {
                          if (Platform.isIOS) {
                            await myDevice.writeCharacteristic(0, 0, '(SetUVCLIFETIME : 0)');
                          } else {
                            await myDevice.writeCharacteristic(2, 0, '(SetUVCLIFETIME : 0)');
                          }
                        } else {
                          myUvcToast.setToastDuration(5);
                          myUvcToast.setToastMessage('Le dispositif est trop loin ou étient, merci de vérifier ce dernier');
                          myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
                          myDevice.disconnect();
                          Navigator.pushNamedAndRemoveUntil(context, "/check_permissions", (r) => false);
                        }
                      },
                      child: Text(
                        'Remettre à zéro la duré de vie des tubes UV-C',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.06),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      color: Colors.blue[400],
                    ),
                    SizedBox(height: screenHeight * 0.02),
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

  Future<void> settingsWidget(BuildContext context) {
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

  List<int> _stringListAsciiToListInt(List<int> listInt) {
    List<int> ourListInt = [0];
    int listIntLength = listInt.length;
    int intNumber = 1;
    for (int i = 0; i < listIntLength; i++) {
      if (listInt[i] == 44) {
        intNumber++;
      }
    }
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
}
