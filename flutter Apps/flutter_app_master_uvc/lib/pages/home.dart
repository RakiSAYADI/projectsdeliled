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
  bool firstDisplayMainWidget = true;

  String dataRobotUVC = '';
  String durationUVC = '122 heures';
  String numberOfUVC = '1 fois';
  String typeOfDisinfectionMessage = '';
  String qrCodeScanMessage = 'QrCode de sécurité : activé';

  int variableUVCMode = 0;
  bool securityAccess = false;

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

  void deviceNotCompatible() {
    Future.delayed(const Duration(milliseconds: 500), () {
      myDevice.disconnect();
      Navigator.pushNamed(context, '/warning');
    });
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
      if ((data['FirmwareVersion'] != null) || (data['Version'] != null) || (data['Security'] != null)) {
        switch (data['FirmwareVersion']) {
          case '3.0.0':
            try {
              variableUVCMode = data['Version'];
              if (data['Security'] == 0) {
                securityAccess = false;
                qrCodeScanMessage = 'QrCode de sécurité : activé';
              } else {
                securityAccess = true;
                qrCodeScanMessage = 'QrCode de sécurité : désactivé';
              }

              String timeDataList = data['UVCTimeData'].toString();
              lifeCycleUVCList = _stringListAsciiToListInt(timeDataList.codeUnits);
              int lifeTimeCycle = lifeCycleUVCList[1];
              numberOfUVC = '${lifeCycleUVCList[2]} fois';
              if (lifeTimeCycle < 60) {
                durationUVC = '$lifeTimeCycle secondes';
              } else if (lifeTimeCycle < 3600) {
                lifeTimeCycle = (lifeTimeCycle / 60).round();
                durationUVC = '$lifeTimeCycle minutes';
              } else {
                lifeTimeCycle = (lifeTimeCycle / 3600).round();
                durationUVC = '$lifeTimeCycle heures';
              }
              switch (variableUVCMode) {
                case 0:
                  typeOfDisinfectionMessage = 'Type de pilotage : manuel';
                  break;
                case 1:
                  typeOfDisinfectionMessage = 'Type de pilotage : automatique';
                  break;
              }
            } catch (e) {
              deviceNotCompatible();
            }
            break;
          default:
            print('it\'s another version !');
            deviceNotCompatible();
            break;
        }
      } else {
        deviceNotCompatible();
      }

      firstDisplayMainWidget = false;
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Réglages dispositif'),
          centerTitle: true,
          backgroundColor: Color(0xFF554c9a),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            typeOfDisinfectionMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
                          child: FlatButton(
                            onPressed: () async {
                              changeFunctionMode(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Text(
                                'Changer',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            color: Color(0xFF554c9a),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            qrCodeScanMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
                          child: FlatButton(
                            onPressed: () async {
                              securityAccessPage(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Text(
                                'Changer',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            color: Color(0xFF554c9a),
                          ),
                        ),
                      ],
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
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        'Fonctionnement des tubes UV-C:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        durationUVC,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        'Nombre d\'allumages des tubes UV-C:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        numberOfUVC,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 30),
                      child: FlatButton(
                        onPressed: () async {
                          if (myDevice.getConnectionState()) {
                            if (Platform.isIOS) {
                              await myDevice.writeCharacteristic(0, 0, '(SetUVCLIFETIME : 0)');
                            } else {
                              await myDevice.writeCharacteristic(2, 0, '(SetUVCLIFETIME : 0)');
                            }
                            myUvcToast.setToastDuration(2);
                            myUvcToast.setToastMessage('Confuguration sauvegardée !');
                            myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
                            setState(() {
                              durationUVC = '0 secondes';
                              numberOfUVC = '0 fois';
                            });
                          } else {
                            myUvcToast.setToastDuration(5);
                            myUvcToast.setToastMessage('Le dispositif est trop loin ou étient, merci de vérifier ce dernier');
                            myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
                            myDevice.disconnect();
                            Navigator.pushNamedAndRemoveUntil(context, "/check_permissions", (r) => false);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Remettre à zéro la duré de vie des tubes UV-C',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.06),
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        color: Color(0xFF554c9a),
                      ),
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

  Future<void> changeFunctionMode(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Type de pilotage:'),
        content: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: screenWidth * 0.1),
              FlatButton.icon(
                color: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                onPressed: () async {
                  variableUVCMode = 1;
                  String modeMessageCommand = '{\"SetVersion\" :$variableUVCMode}';
                  if (myDevice.getConnectionState()) {
                    myUvcToast.setToastDuration(2);
                    myUvcToast.setToastMessage('Confuguration sauvegardée !');
                    myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
                    if (Platform.isIOS) {
                      await myDevice.writeCharacteristic(0, 0, modeMessageCommand);
                    } else {
                      await myDevice.writeCharacteristic(2, 0, modeMessageCommand);
                    }
                    Navigator.pop(c, false);
                    setState(() {
                      typeOfDisinfectionMessage = 'Type de pilotage automatique';
                    });
                  } else {
                    myUvcToast.setToastDuration(5);
                    myUvcToast.setToastMessage('Le dispositif est trop loin ou étient, merci de vérifier ce dernier');
                    myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
                    myDevice.disconnect();
                    Navigator.pushNamedAndRemoveUntil(context, "/check_permissions", (r) => false);
                  }
                },
                icon: Icon(
                  Icons.computer,
                  color: Colors.black,
                  size: screenHeight * 0.035,
                ),
                label: Text(
                  'Mode automatique',
                  style: TextStyle(color: Colors.black, fontSize: screenWidth * 0.045),
                ),
              ),
              SizedBox(width: screenWidth * 0.1),
              FlatButton.icon(
                color: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                onPressed: () async {
                  variableUVCMode = 0;
                  String modeMessageCommand = '{\"SetVersion\" :$variableUVCMode}';
                  if (myDevice.getConnectionState()) {
                    myUvcToast.setToastDuration(2);
                    myUvcToast.setToastMessage('Confuguration sauvegardée !');
                    myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
                    if (Platform.isIOS) {
                      await myDevice.writeCharacteristic(0, 0, modeMessageCommand);
                    } else {
                      await myDevice.writeCharacteristic(2, 0, modeMessageCommand);
                    }
                    Navigator.pop(c, false);
                    setState(() {
                      typeOfDisinfectionMessage = 'Type de pilotage manuel';
                    });
                  } else {
                    myUvcToast.setToastDuration(5);
                    myUvcToast.setToastMessage('Le dispositif est trop loin ou étient, merci de vérifier ce dernier');
                    myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
                    myDevice.disconnect();
                    Navigator.pushNamedAndRemoveUntil(context, "/check_permissions", (r) => false);
                  }
                },
                icon: Icon(
                  Icons.handyman,
                  color: Colors.black,
                  size: screenHeight * 0.035,
                ),
                label: Text(
                  'Mode manuel',
                  style: TextStyle(color: Colors.black, fontSize: screenWidth * 0.045),
                ),
              ),
              SizedBox(width: screenWidth * 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> securityAccessPage(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Scan QrCode Securité:'),
        content: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: screenWidth * 0.1),
              FlatButton.icon(
                color: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                onPressed: () async {
                  String modeMessageCommand = '{\"SetUVCLIFESecurity\" :0}';
                  securityAccess = false;
                  if (myDevice.getConnectionState()) {
                    myUvcToast.setToastDuration(2);
                    myUvcToast.setToastMessage('Confuguration sauvegardée !');
                    myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
                    if (Platform.isIOS) {
                      await myDevice.writeCharacteristic(0, 0, modeMessageCommand);
                    } else {
                      await myDevice.writeCharacteristic(2, 0, modeMessageCommand);
                    }
                    Navigator.pop(c, false);
                    setState(() {
                      qrCodeScanMessage = 'QrCode de sécurité : activé';
                    });
                  } else {
                    myUvcToast.setToastDuration(5);
                    myUvcToast.setToastMessage('Le dispositif est trop loin ou étient, merci de vérifier ce dernier');
                    myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
                    myDevice.disconnect();
                    Navigator.pushNamedAndRemoveUntil(context, "/check_permissions", (r) => false);
                  }
                },
                icon: Icon(
                  Icons.computer,
                  color: Colors.black,
                  size: screenHeight * 0.035,
                ),
                label: Text(
                  'Activée',
                  style: TextStyle(color: Colors.black, fontSize: screenWidth * 0.045),
                ),
              ),
              SizedBox(width: screenWidth * 0.1),
              FlatButton.icon(
                color: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                onPressed: () async {
                  String modeMessageCommand = '{\"SetUVCLIFESecurity\" :1}';
                  securityAccess = true;
                  if (myDevice.getConnectionState()) {
                    myUvcToast.setToastDuration(2);
                    myUvcToast.setToastMessage('Confuguration sauvegardée !');
                    myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
                    if (Platform.isIOS) {
                      await myDevice.writeCharacteristic(0, 0, modeMessageCommand);
                    } else {
                      await myDevice.writeCharacteristic(2, 0, modeMessageCommand);
                    }
                    Navigator.pop(c, false);
                    setState(() {
                      qrCodeScanMessage = 'QrCode de sécurité : désactivé';
                    });
                  } else {
                    myUvcToast.setToastDuration(5);
                    myUvcToast.setToastMessage('Le dispositif est trop loin ou étient, merci de vérifier ce dernier');
                    myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
                    myDevice.disconnect();
                    Navigator.pushNamedAndRemoveUntil(context, "/check_permissions", (r) => false);
                  }
                },
                icon: Icon(
                  Icons.handyman,
                  color: Colors.black,
                  size: screenHeight * 0.035,
                ),
                label: Text(
                  'Désctivée',
                  style: TextStyle(color: Colors.black, fontSize: screenWidth * 0.045),
                ),
              ),
              SizedBox(width: screenWidth * 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> disconnection(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Attention'),
        content: Text('Voulez-vous vraiment quitter la page Réglages dispositif ?'),
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
