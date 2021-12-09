import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_master_uvc/services/DataVariables.dart';
import 'package:flutter_app_master_uvc/services/bleDeviceClass.dart';
import 'package:flutter_app_master_uvc/services/languageDataBase.dart';
import 'package:flutter_app_master_uvc/services/uvcToast.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ToastyMessage myUvcToast;

  bool firstDisplayMainWidget = true;
  bool securityAccess = false;

  String durationUVC = '122 ${hoursTextLanguageArray[languageArrayIdentifier]}';
  String numberOfUVC = '1 ${timesTextLanguageArray[languageArrayIdentifier]}';
  String typeOfDisinfectionMessage = '';
  String qrCodeScanMessage = '';

  int variableUVCMode = 0;

  final Color hardPink = Color(0xFF554c9a);
  final Color softPink = Color(0xFF784886);

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
    Future.delayed(const Duration(milliseconds: 200), () {
      myDevice.disconnect();
      Navigator.pushNamed(context, '/warning');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (dataRobotUVC == null) {
      dataRobotUVC = dataRobotUVCDefault;
    }

    if (dataRobotUVC.isNotEmpty && firstDisplayMainWidget) {
      Map<String, dynamic> data = jsonDecode(dataRobotUVC);
      print(data.toString());
      List<int> lifeCycleUVCList = [];
      if ((data['FirmwareVersion'] != null) || (data['Version'] != null) || (data['security'] != null)) {
        switch (data['FirmwareVersion']) {
          case '3.0.0':
            try {
              variableUVCMode = data['Version'];
              if (data['security'] == 0) {
                securityAccess = false;
                qrCodeScanMessage = activatedTextLanguageArray[languageArrayIdentifier];
              } else {
                securityAccess = true;
                qrCodeScanMessage = deactivatedTextLanguageArray[languageArrayIdentifier];
              }

              String timeDataList = data['UVCTimeData'].toString();
              lifeCycleUVCList = _stringListAsciiToListInt(timeDataList.codeUnits);
              int lifeTimeCycle = lifeCycleUVCList[1];
              numberOfUVC = '${lifeCycleUVCList[2]} ${timesTextLanguageArray[languageArrayIdentifier]}';
              if (lifeTimeCycle < 60) {
                durationUVC = '$lifeTimeCycle ${secondsTextLanguageArray[languageArrayIdentifier]}';
              } else if (lifeTimeCycle < 3600) {
                lifeTimeCycle = (lifeTimeCycle / 60).round();
                durationUVC = '$lifeTimeCycle ${minutesTextLanguageArray[languageArrayIdentifier]}';
              } else {
                lifeTimeCycle = (lifeTimeCycle / 3600).round();
                durationUVC = '$lifeTimeCycle ${hoursTextLanguageArray[languageArrayIdentifier]}';
              }
              switch (variableUVCMode) {
                case 0:
                  typeOfDisinfectionMessage = manualTextLanguageArray[languageArrayIdentifier];
                  break;
                case 1:
                  typeOfDisinfectionMessage = automaticTextLanguageArray[languageArrayIdentifier];
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
          title: Text(masterUVCTitleTextLanguageArray[languageArrayIdentifier]),
          centerTitle: true,
          backgroundColor: hardPink,
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
                    Card(
                      margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                      shape: RoundedRectangleBorder(side: new BorderSide(color: hardPink, width: 2.0), borderRadius: BorderRadius.circular(4.0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            color: hardPink,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                parametersUVCTextLanguageArray[languageArrayIdentifier],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.05,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text(
                                        pilotTypeTextLanguageArray[languageArrayIdentifier],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.05,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text(
                                        typeOfDisinfectionMessage,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: screenWidth * 0.05,
                                          color: Colors.black,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: screenHeight * 0.01),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
                                      child: IconButton(
                                        onPressed: () => infoMode(context, 'type de pilotage'),
                                        icon: Padding(
                                          padding: const EdgeInsets.all(1.0),
                                          child: Icon(
                                            Icons.info_outline,
                                            color: hardPink,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 5),
                                      child: TextButton(
                                        onPressed: () async {
                                          changeFunctionMode(context);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(1.0),
                                          child: Text(
                                            changeTextLanguageArray[languageArrayIdentifier],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
                                          ),
                                        ),
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
                                          backgroundColor: MaterialStateProperty.all<Color>(hardPink),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Divider(
                              thickness: 2.0,
                              color: hardPink,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text(
                                        qrCodeSecurityTextLanguageArray[languageArrayIdentifier],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.05,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text(
                                        qrCodeScanMessage,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.05,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 5),
                                      child: IconButton(
                                        onPressed: () => infoMode(context, 'qr code de security'),
                                        icon: Padding(
                                          padding: const EdgeInsets.all(1.0),
                                          child: Icon(
                                            Icons.info_outline,
                                            color: hardPink,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 5),
                                      child: TextButton(
                                        onPressed: () async {
                                          securityAccessPage(context);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(1.0),
                                          child: Text(
                                            changeTextLanguageArray[languageArrayIdentifier],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
                                          ),
                                        ),
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
                                          backgroundColor: MaterialStateProperty.all<Color>(hardPink),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Card(
                      margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                      shape: RoundedRectangleBorder(side: new BorderSide(color: hardPink, width: 2.0), borderRadius: BorderRadius.circular(4.0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            color: hardPink,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                maintenanceUVCTextLanguageArray[languageArrayIdentifier],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.05,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Container(
                              color: hardPink,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      durationOfUseTextLanguageArray[languageArrayIdentifier],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.05,
                                        color: Colors.white,
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
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Container(
                              color: hardPink,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      numberIgnitionsTextLanguageArray[languageArrayIdentifier],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.05,
                                        color: Colors.white,
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
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 30),
                      child: TextButton(
                        onPressed: () => resetRobot(context),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            resetButtonTextLanguageArray[languageArrayIdentifier],
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.06),
                          ),
                        ),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
                          backgroundColor: MaterialStateProperty.all<Color>(hardPink),
                        ),
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

  Future<void> resetRobot(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(
          attentionTextLanguageArray[languageArrayIdentifier],
          style: TextStyle(
            color: hardPink,
          ),
        ),
        content: Text(resetAlertDialogMessageTextLanguageArray[languageArrayIdentifier]),
        actions: [
          TextButton(
            child: Text(yesTextLanguageArray[languageArrayIdentifier]),
            onPressed: () async {
              Navigator.pop(c, false);
              if (myDevice.getConnectionState()) {
                if (Platform.isIOS) {
                  await myDevice.writeCharacteristic(0, 0, '(SetUVCLIFETIME : 0)');
                } else {
                  await myDevice.writeCharacteristic(2, 0, '(SetUVCLIFETIME : 0)');
                }
                myUvcToast.setToastDuration(2);
                myUvcToast.setToastMessage(configSavedToastTextLanguageArray[languageArrayIdentifier]);
                myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
                setState(() {
                  durationUVC = '0 ${secondsTextLanguageArray[languageArrayIdentifier]}';
                  numberOfUVC = '0 ${timesTextLanguageArray[languageArrayIdentifier]}';
                });
              } else {
                lostConnection(context, myDevice);
              }
            },
          ),
          TextButton(
            child: Text(noTextLanguageArray[languageArrayIdentifier]),
            onPressed: () => Navigator.pop(c, false),
          ),
        ],
      ),
    );
  }

  Future<void> infoMode(BuildContext context, String infoType) {
    double screenWidth = MediaQuery.of(context).size.width;

    String popUpMessage;

    switch (infoType) {
      case 'type de pilotage':
        popUpMessage = pilotModeAlertDialogMessageTextLanguageArray[languageArrayIdentifier];
        break;
      case 'qr code de security':
        popUpMessage = securityQrCodeAlertDialogMessageTextLanguageArray[languageArrayIdentifier];
        break;
    }

    return showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(
          informationAlertDialogTitleTextLanguageArray[languageArrayIdentifier],
          style: TextStyle(
            color: hardPink,
          ),
        ),
        content: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: screenWidth * 0.1),
              Text(
                popUpMessage,
                textAlign: TextAlign.justify,
                style: TextStyle(color: Colors.black, fontSize: screenWidth * 0.035),
              ),
              SizedBox(width: screenWidth * 0.1),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text(okTextLanguageArray[languageArrayIdentifier]),
            onPressed: () => Navigator.pop(c, true),
          ),
        ],
      ),
    );
  }

  Future<void> changeFunctionMode(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(
          pilotAlertDialogTitleTextLanguageArray[languageArrayIdentifier],
          style: TextStyle(
            color: hardPink,
          ),
        ),
        content: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: screenWidth * 0.1),
              TextButton.icon(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[200]),
                ),
                onPressed: () async {
                  variableUVCMode = 1;
                  String modeMessageCommand = '{\"SetVersion\" :$variableUVCMode}';
                  if (myDevice.getConnectionState()) {
                    myUvcToast.setToastDuration(2);
                    myUvcToast.setToastMessage(configSavedToastTextLanguageArray[languageArrayIdentifier]);
                    myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
                    if (Platform.isIOS) {
                      await myDevice.writeCharacteristic(0, 0, modeMessageCommand);
                    } else {
                      await myDevice.writeCharacteristic(2, 0, modeMessageCommand);
                    }
                    Navigator.pop(c, false);
                    setState(() {
                      typeOfDisinfectionMessage = automaticTextLanguageArray[languageArrayIdentifier];
                    });
                  } else {
                    lostConnection(context, myDevice);
                  }
                },
                icon: Icon(
                  Icons.computer,
                  color: Colors.black,
                  size: screenHeight * 0.035,
                ),
                label: Text(
                  modeAutomaticTextLanguageArray[languageArrayIdentifier],
                  style: TextStyle(color: Colors.black, fontSize: screenWidth * 0.045),
                ),
              ),
              SizedBox(width: screenWidth * 0.1),
              TextButton.icon(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[200]),
                ),
                onPressed: () async {
                  variableUVCMode = 0;
                  String modeMessageCommand = '{\"SetVersion\" :$variableUVCMode}';
                  if (myDevice.getConnectionState()) {
                    myUvcToast.setToastDuration(2);
                    myUvcToast.setToastMessage(configSavedToastTextLanguageArray[languageArrayIdentifier]);
                    myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
                    if (Platform.isIOS) {
                      await myDevice.writeCharacteristic(0, 0, modeMessageCommand);
                    } else {
                      await myDevice.writeCharacteristic(2, 0, modeMessageCommand);
                    }
                    Navigator.pop(c, false);
                    setState(() {
                      typeOfDisinfectionMessage = manualTextLanguageArray[languageArrayIdentifier];
                    });
                  } else {
                    lostConnection(context, myDevice);
                  }
                },
                icon: Icon(
                  Icons.handyman,
                  color: Colors.black,
                  size: screenHeight * 0.035,
                ),
                label: Text(
                  modeManualTextLanguageArray[languageArrayIdentifier],
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
        title: Text(
          scanQrCodeTitleAlertDialogTextLanguageArray[languageArrayIdentifier],
          style: TextStyle(
            color: hardPink,
          ),
        ),
        content: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: screenWidth * 0.1),
              Text(
                deactivationScanQrCodeMessageAlertDialogTextLanguageArray[languageArrayIdentifier],
                textAlign: TextAlign.justify,
                style: TextStyle(color: Colors.black, fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: screenWidth * 0.05),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Divider(
                  thickness: 2.0,
                  color: hardPink,
                ),
              ),
              SizedBox(width: screenWidth * 0.05),
              TextButton.icon(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[200]),
                ),
                onPressed: () async {
                  String modeMessageCommand = '{\"SetUVCLIFESecurity\" :0}';
                  securityAccess = false;
                  if (myDevice.getConnectionState()) {
                    myUvcToast.setToastDuration(2);
                    myUvcToast.setToastMessage(configSavedToastTextLanguageArray[languageArrayIdentifier]);
                    myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
                    if (Platform.isIOS) {
                      await myDevice.writeCharacteristic(0, 0, modeMessageCommand);
                    } else {
                      await myDevice.writeCharacteristic(2, 0, modeMessageCommand);
                    }
                    Navigator.pop(c, false);
                    setState(() {
                      qrCodeScanMessage = activatedTextLanguageArray[languageArrayIdentifier];
                    });
                  } else {
                    lostConnection(context, myDevice);
                  }
                },
                icon: Icon(
                  Icons.computer,
                  color: Colors.black,
                  size: screenHeight * 0.035,
                ),
                label: Text(
                  activatedButtonTextLanguageArray[languageArrayIdentifier],
                  style: TextStyle(color: Colors.black, fontSize: screenWidth * 0.045),
                ),
              ),
              SizedBox(width: screenWidth * 0.1),
              TextButton.icon(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[200]),
                ),
                onPressed: () async {
                  String modeMessageCommand = '{\"SetUVCLIFESecurity\" :1}';
                  securityAccess = true;
                  if (myDevice.getConnectionState()) {
                    myUvcToast.setToastDuration(2);
                    myUvcToast.setToastMessage(configSavedToastTextLanguageArray[languageArrayIdentifier]);
                    myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
                    if (Platform.isIOS) {
                      await myDevice.writeCharacteristic(0, 0, modeMessageCommand);
                    } else {
                      await myDevice.writeCharacteristic(2, 0, modeMessageCommand);
                    }
                    Navigator.pop(c, false);
                    setState(() {
                      qrCodeScanMessage = deactivatedTextLanguageArray[languageArrayIdentifier];
                    });
                  } else {
                    lostConnection(context, myDevice);
                  }
                },
                icon: Icon(
                  Icons.handyman,
                  color: Colors.black,
                  size: screenHeight * 0.035,
                ),
                label: Text(
                  deactivatedButtonTextLanguageArray[languageArrayIdentifier],
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

  void lostConnection(BuildContext context, Device device) {
    myUvcToast.setToastDuration(5);
    myUvcToast.setToastMessage(checkConnectionToastMessageTextLanguageArray[languageArrayIdentifier]);
    myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
    device.disconnect();
    Navigator.pushNamedAndRemoveUntil(context, "/check_permissions", (r) => false);
  }

  Future<void> disconnection(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(
          attentionTextLanguageArray[languageArrayIdentifier],
          style: TextStyle(
            color: hardPink,
          ),
        ),
        content: Text(exitAlertDialogMessageTextLanguageArray[languageArrayIdentifier]),
        actions: [
          TextButton(
            child: Text(yesTextLanguageArray[languageArrayIdentifier]),
            onPressed: () {
              Navigator.pop(c, true);
              myDevice.disconnect();
              Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
            },
          ),
          TextButton(
            child: Text(noTextLanguageArray[languageArrayIdentifier]),
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
