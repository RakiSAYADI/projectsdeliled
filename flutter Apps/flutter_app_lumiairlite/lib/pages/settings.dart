import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_bispectrum/pages/scan_ble_list.dart';
import 'package:flutter_app_bispectrum/services/DataVariables.dart';
import 'package:flutter_app_bispectrum/services/animation_between_pages.dart';
import 'package:flutter_app_bispectrum/services/languageDataBase.dart';
import 'package:flutter_app_bispectrum/services/uvcToast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  ToastyMessage myUvcToast;

  bool firstDisplayMainWidget = true;

  bool displayModems = false;

  List<bool> zoneStates;
  List<String> zonesNamesList = ['', '', '', ''];
  String zonesInHex;

  List<String> wifiModems = [];
  String wifiModemsData = '';
  String co2sensorStateMessage = 'OK';
  Color co2sensorStateMessageColor = Colors.green;
  int wifiModemsPosition = 0;

  final passwordEditor = TextEditingController();
  final myBleDeviceName = TextEditingController();
  final myOldCodePIN = TextEditingController();
  final myNewCodePIN = TextEditingController();

  bool ccSwitchValue = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myUvcToast = ToastyMessage(toastContext: context);
    zoneStates = [false, false, false, false];
    zonesInHex = ((boolToInt(zoneStates[0])) + (boolToInt(zoneStates[1]) * 2) + (boolToInt(zoneStates[2]) * 4) + (boolToInt(zoneStates[3]) * 8)).toRadixString(16);
  }

  void readDataMaestro() async {
    var parsedJson;
    try {
      myBleDeviceName.text = myDevice.device.name.substring(4);
      if (Platform.isAndroid) {
        parsedJson = json.decode(dataCharAndroid2);
      }
      if (Platform.isIOS) {
        parsedJson = json.decode(dataCharIOS2p2);
      }
      zonesNamesList[0] = parsedJson['ZN'][0];
      zonesNamesList[1] = parsedJson['ZN'][1];
      zonesNamesList[2] = parsedJson['ZN'][2];
      zonesNamesList[3] = parsedJson['ZN'][3];
      if (Platform.isIOS) {
        parsedJson = json.decode(dataCharIOS2p1);
      }
      ccSwitchValue = intToBool(int.parse(parsedJson['cc'][0].toString()));
      switch (co2sensorStateValue) {
        case 0:
          co2sensorStateMessage = "OK";
          co2sensorStateMessageColor = Colors.green;
          break;
        case 1:
          co2sensorStateMessage = "BUSY";
          co2sensorStateMessageColor = Colors.yellow;
          break;
        case 16:
          co2sensorStateMessage = "RUNIN";
          co2sensorStateMessageColor = Colors.blue;
          break;
        default:
          co2sensorStateMessage = "ERROR";
          co2sensorStateMessageColor = Colors.red;
          break;
      }
      await Future.delayed(Duration(seconds: 2));
      if (deviceWifiState) {
        myUvcToast.setToastDuration(5);
        myUvcToast.setToastMessage(internetToastTextLanguageArray[languageArrayIdentifier]);
        myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
      } else {
        myUvcToast.setToastDuration(5);
        myUvcToast.setToastMessage(noInternetToastTextLanguageArray[languageArrayIdentifier]);
        myUvcToast.showToast(Colors.red, Icons.info, Colors.white);
      }
    } catch (e) {
      print('erreur settings');
      ccSwitchValue = false;
      zonesNamesList = [
        firstZoneTextLanguageArray[languageArrayIdentifier],
        secondZoneTextLanguageArray[languageArrayIdentifier],
        thirdZoneTextLanguageArray[languageArrayIdentifier],
        fourthZoneTextLanguageArray[languageArrayIdentifier]
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (firstDisplayMainWidget) {
      readDataMaestro();
      firstDisplayMainWidget = false;
    }

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    print('width : $screenWidth and height : $screenHeight');
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            settingsTitleTextLanguageArray[languageArrayIdentifier],
            style: TextStyle(fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background-bispectrum.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(18.0),
                        border: Border.all(color: Color(0xFF3a66d7)),
                        color: Colors.white.withOpacity(0.5),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              deviceNameTextLanguageArray[languageArrayIdentifier],
                              style: TextStyle(fontSize: (screenWidth * 0.03)),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  myDevice.device.name.substring(0, 4),
                                  style: TextStyle(fontSize: (screenWidth * 0.03)),
                                ),
                                Flexible(
                                  child: TextField(
                                    textAlign: TextAlign.center,
                                    controller: myBleDeviceName,
                                    maxLines: 1,
                                    maxLength: 64,
                                    style: TextStyle(
                                      fontSize: (screenWidth * 0.03),
                                    ),
                                    decoration: InputDecoration(
                                        hintText: 'exp:Maestro1234',
                                        hintStyle: TextStyle(
                                          fontSize: (screenWidth * 0.03),
                                          color: Colors.grey,
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextButton(
                              onPressed: () async {
                                if (myDevice.getConnectionState()) {
                                  // write the new ble device name
                                  await characteristicData.write('{\"dname\":\"${myDevice.device.name.substring(0, 4)}${myBleDeviceName.text}\"}'.codeUnits);
                                  myUvcToast.setToastDuration(5);
                                  myUvcToast.setToastMessage(nameChangedToastTextLanguageArray[languageArrayIdentifier]);
                                  myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
                                }
                              },
                              child: Text(
                                changeNameButtonTextLanguageArray[languageArrayIdentifier],
                                style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.025),
                              ),
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0), side: BorderSide(color: Colors.black))),
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.green[400])),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(18.0),
                        border: Border.all(color: Color(0xFF3a66d7)),
                        color: Colors.white.withOpacity(0.5),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  cycleCTextLanguageArray[languageArrayIdentifier],
                                  style: TextStyle(fontSize: (screenWidth * 0.03)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: CupertinoSwitch(
                                  value: ccSwitchValue,
                                  activeColor: Colors.green,
                                  onChanged: (value) async {
                                    setState(() {
                                      ccSwitchValue = value;
                                    });
                                    if (myDevice.getConnectionState()) {
                                      // write the cc command
                                      await characteristicData.write('{\"cc\":${boolToInt(ccSwitchValue)}}'.codeUnits);
                                      await Future.delayed(Duration(milliseconds: 500));
                                      if (Platform.isAndroid) {
                                        dataCharAndroid2 = String.fromCharCodes(await characteristicData.read());
                                      }
                                      if (Platform.isIOS) {
                                        savingDataWidget(context, waitTextLanguageArray[languageArrayIdentifier]);
                                        dataCharIOS2p1 = await charDividedIOSRead(characteristicData);
                                        dataCharIOS2p2 = await charDividedIOSRead(characteristicData);
                                        dataCharIOS2p3 = await charDividedIOSRead(characteristicData);
                                        Navigator.of(context).pop();
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              cycleCInfoTextLanguageArray[languageArrayIdentifier],
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: (screenWidth * 0.015)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(18.0),
                        border: Border.all(color: Color(0xFF3a66d7)),
                        color: Colors.white.withOpacity(0.5),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              co2stateTextLanguageArray[languageArrayIdentifier],
                              style: TextStyle(fontSize: (screenWidth * 0.03)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              co2sensorStateMessage,
                              style: TextStyle(color: co2sensorStateMessageColor, fontSize: (screenWidth * 0.03)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(18.0),
                        border: Border.all(color: Color(0xFF3a66d7)),
                        color: Colors.white.withOpacity(0.5),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              zonesTextLanguageArray[languageArrayIdentifier],
                              style: TextStyle(fontSize: (screenWidth * 0.03)),
                            ),
                          ),
                          ToggleButtons(
                            borderRadius: BorderRadius.circular(18.0),
                            isSelected: zoneStates,
                            onPressed: (int index) async {
                              for (int buttonIndex = 0; buttonIndex < zoneStates.length; buttonIndex++) {
                                if (buttonIndex == index) {
                                  zoneStates[buttonIndex] = true;
                                } else {
                                  zoneStates[buttonIndex] = false;
                                }
                              }
                              setState(() {});
                              zonesInHex = ((boolToInt(zoneStates[0])) + (boolToInt(zoneStates[1]) * 2) + (boolToInt(zoneStates[2]) * 4) + (boolToInt(zoneStates[3]) * 8)).toRadixString(16);
                            },
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                                child: Text(zonesNamesList[0], style: TextStyle(fontSize: screenWidth * 0.02 + screenHeight * 0.02)),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                                child: Text(zonesNamesList[1], style: TextStyle(fontSize: screenWidth * 0.02 + screenHeight * 0.02)),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                                child: Text(zonesNamesList[2], style: TextStyle(fontSize: screenWidth * 0.02 + screenHeight * 0.02)),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                                child: Text(zonesNamesList[3], style: TextStyle(fontSize: screenWidth * 0.02 + screenHeight * 0.02)),
                              ),
                            ],
                            borderWidth: 2,
                            color: Colors.grey,
                            selectedBorderColor: Colors.black,
                            selectedColor: Colors.green,
                          ),
                          SizedBox(height: screenHeight * 0.05),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextButton(
                                  onPressed: () async {
                                    if (myDevice.getConnectionState()) {
                                      // write the associate command
                                      await characteristicData.write('{\"light\":[5,1,\"$zonesInHex\"]}'.codeUnits);
                                    }
                                  },
                                  child: Text(
                                    associateTextLanguageArray[languageArrayIdentifier],
                                    style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.025),
                                  ),
                                  style: ButtonStyle(
                                      shape:
                                          MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0), side: BorderSide(color: Colors.black))),
                                      backgroundColor: MaterialStateProperty.all<Color>(
                                        Colors.green[400],
                                      )),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextButton(
                                  onPressed: () async {
                                    if (myDevice.getConnectionState()) {
                                      // write the dissociate command
                                      await characteristicData.write('{\"light\":[5,0,\"$zonesInHex\"]}'.codeUnits);
                                    }
                                  },
                                  child: Text(
                                    dissociateTextLanguageArray[languageArrayIdentifier],
                                    style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.025),
                                  ),
                                  style: ButtonStyle(
                                      shape:
                                          MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0), side: BorderSide(color: Colors.black))),
                                      backgroundColor: MaterialStateProperty.all<Color>(Colors.green[400])),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextButton(
                              onPressed: () {
                                // write the new zone names
                                zoneNamesSettingsWidget(context);
                              },
                              child: Text(
                                renameTextLanguageArray[languageArrayIdentifier],
                                style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.025),
                              ),
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0), side: BorderSide(color: Colors.black))),
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.green[400])),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(18.0),
                        border: Border.all(color: Color(0xFF3a66d7)),
                        color: Colors.white.withOpacity(0.5),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              oldPINTextLanguageArray[languageArrayIdentifier],
                              style: TextStyle(fontSize: (screenWidth * 0.03)),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
                            child: TextField(
                              textAlign: TextAlign.center,
                              controller: myOldCodePIN,
                              maxLines: 1,
                              maxLength: 4,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                              style: TextStyle(
                                fontSize: (screenWidth * 0.03),
                              ),
                              decoration: InputDecoration(
                                  hintText: 'Exemple: 1234',
                                  hintStyle: TextStyle(
                                    fontSize: (screenWidth * 0.03),
                                    color: Colors.grey,
                                  )),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              newPINTextLanguageArray[languageArrayIdentifier],
                              style: TextStyle(fontSize: (screenWidth * 0.03)),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
                            child: TextField(
                              textAlign: TextAlign.center,
                              controller: myNewCodePIN,
                              maxLines: 1,
                              maxLength: 4,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                              style: TextStyle(
                                fontSize: (screenWidth * 0.03),
                              ),
                              decoration: InputDecoration(
                                  hintText: 'Exemple: 1234',
                                  hintStyle: TextStyle(
                                    fontSize: (screenWidth * 0.03),
                                    color: Colors.grey,
                                  )),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextButton(
                              onPressed: () async {
                                if (myDevice.getConnectionState()) {
                                  if (pinCodeAccess == myOldCodePIN.text) {
                                    if (myNewCodePIN.text.length == 4) {
                                      // write the new code PIN
                                      await characteristicData.write('{\"PP\":\"${myNewCodePIN.text}\"}'.codeUnits);
                                      myUvcToast.setToastDuration(5);
                                      myUvcToast.setToastMessage(pinCodeChangedToastTextLanguageArray[languageArrayIdentifier]);
                                      myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
                                      await Future.delayed(Duration(milliseconds: 500));
                                      pinCodeAccess = myNewCodePIN.text;
                                      if (Platform.isAndroid) {
                                        dataCharAndroid2 = String.fromCharCodes(await characteristicData.read());
                                      }
                                      if (Platform.isIOS) {
                                        savingDataWidget(context, waitTextLanguageArray[languageArrayIdentifier]);
                                        dataCharIOS2p1 = await charDividedIOSRead(characteristicData);
                                        dataCharIOS2p2 = await charDividedIOSRead(characteristicData);
                                        dataCharIOS2p3 = await charDividedIOSRead(characteristicData);
                                        Navigator.of(context).pop();
                                      }
                                    } else {
                                      myUvcToast.setToastDuration(5);
                                      myUvcToast.setToastMessage(pinCodeLargerToastTextLanguageArray[languageArrayIdentifier]);
                                      myUvcToast.showToast(Colors.red, Icons.thumb_down, Colors.white);
                                    }
                                  } else {
                                    myUvcToast.setToastDuration(5);
                                    myUvcToast.setToastMessage(pinCodeNotCorrectToastTextLanguageArray[languageArrayIdentifier]);
                                    myUvcToast.showToast(Colors.red, Icons.thumb_down, Colors.white);
                                  }
                                  myNewCodePIN.text = '';
                                  myOldCodePIN.text = '';
                                }
                              },
                              child: Text(
                                changeCodePINMessageLanguageArray[languageArrayIdentifier],
                                style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.025),
                              ),
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0), side: BorderSide(color: Colors.black))),
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.green[400])),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(18.0),
                        border: Border.all(color: Color(0xFF3a66d7)),
                        color: Colors.white.withOpacity(0.5),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              wifiConnexionTextLanguageArray[languageArrayIdentifier],
                              style: TextStyle(fontSize: (screenWidth * 0.03)),
                            ),
                          ),
                          Visibility(
                            visible: displayModems,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
                              child: DropdownButton<String>(
                                value: wifiModemsData,
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
                                    wifiModemsData = data;
                                    wifiModemsPosition = wifiModems.indexOf(data);
                                  });
                                },
                                items: wifiModems.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextButton(
                              onPressed: () async {
                                waitingWidget();
                                // write the scan command
                                if (myDevice.getConnectionState()) {
                                  try {
                                    await characteristicData.write('{\"SCAN\":1}'.codeUnits);
                                    await Future.delayed(Duration(milliseconds: 500));
                                    String wifiScanningState = String.fromCharCodes(await characteristicSensors.read());
                                    var parsedJson = json.decode(wifiScanningState);
                                    while (parsedJson['SCR'] == '0') {
                                      wifiScanningState = String.fromCharCodes(await characteristicSensors.read());
                                      parsedJson = json.decode(wifiScanningState);
                                      await Future.delayed(Duration(seconds: 1));
                                    }
                                    String wifiScanningResult = String.fromCharCodes(await characteristicData.read());
                                    parsedJson = json.decode(wifiScanningResult);
                                    List<dynamic> modems = parsedJson['AP_RECORDS'];
                                    wifiModems = List<String>.from(modems);
                                    wifiModemsData = wifiModems[0];
                                  } catch (e) {
                                    print('error in device Communication');
                                    myUvcToast.setToastDuration(5);
                                    myUvcToast.setToastMessage(wifiScanErrorToastTextLanguageArray[languageArrayIdentifier]);
                                    myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
                                  }
                                  Navigator.pop(context, false);
                                  displayModems = true;
                                  setState(() {});
                                }
                              },
                              child: Text(
                                scanTextLanguageArray[languageArrayIdentifier],
                                style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.025),
                              ),
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0), side: BorderSide(color: Colors.black))),
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.green[400])),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              passwordTextLanguageArray[languageArrayIdentifier],
                              style: TextStyle(fontSize: (screenWidth * 0.03)),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
                            child: TextField(
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              maxLength: 64,
                              controller: passwordEditor,
                              style: TextStyle(
                                fontSize: screenWidth * 0.025,
                                color: Colors.grey[800],
                              ),
                              decoration: InputDecoration(
                                  hintText: 'exemple : azerty123',
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  )),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextButton(
                              onPressed: () async {
                                if (myDevice.getConnectionState()) {
                                  // write the new access point and it's password
                                  await characteristicData.write('{\"wa\":\"$wifiModemsData\",\"wp\":\"${passwordEditor.text}\"}'.codeUnits);
                                  restartAlertWidget(context, restartAlertDialogTitleTextLanguageArray[languageArrayIdentifier]);
                                }
                              },
                              child: Text(
                                connectTextLanguageArray[languageArrayIdentifier],
                                style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.025),
                              ),
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0), side: BorderSide(color: Colors.black))),
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.green[400])),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(18.0),
                          border: Border.all(color: Color(0xFF3a66d7)),
                          color: Colors.white.withOpacity(0.5),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: restartAndResetWidget(context)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      onWillPop: () => returnButton(context),
    );
  }

  Future<bool> returnButton(BuildContext context) async {
    stateOfSleepAndReadingProcess = 0;
    Navigator.pop(context, true);
    return true;
  }

  Widget restartAndResetWidget(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 480.0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: TextButton(
              onPressed: () async {
                if (myDevice.getConnectionState()) {
                  // write the restart command
                  characteristicData.write('{\"system\":1}'.codeUnits);
                  await Future.delayed(Duration(milliseconds: 500));
                  homePageState = false;
                  myDevice.disconnect();
                  removeReplacementRouts(context, ScanListBle());
                }
              },
              child: Text(
                restartTextLanguageArray[languageArrayIdentifier],
                style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.025),
              ),
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0), side: BorderSide(color: Colors.black))),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.green[400])),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: TextButton(
              onPressed: () async {
                if (myDevice.getConnectionState()) {
                  // write the reset command
                  await characteristicData.write('{\"system\":0}'.codeUnits);
                  restartAlertWidget(context, restartAlertDialogTitleTextLanguageArray[languageArrayIdentifier]);
                }
              },
              child: Text(
                configDefaultTextLanguageArray[languageArrayIdentifier],
                style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.025),
              ),
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0), side: BorderSide(color: Colors.black))),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.green[400])),
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: TextButton(
              onPressed: () async {
                if (myDevice.getConnectionState()) {
                  // write the restart command
                  characteristicData.write('{\"system\":1}'.codeUnits);
                  await Future.delayed(Duration(milliseconds: 500));
                  homePageState = false;
                  myDevice.disconnect();
                  removeReplacementRouts(context, ScanListBle());
                }
              },
              child: Text(
                restartTextLanguageArray[languageArrayIdentifier],
                style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.025),
              ),
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0), side: BorderSide(color: Colors.black))),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.green[400])),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: TextButton(
              onPressed: () async {
                if (myDevice.getConnectionState()) {
                  // write the reset command
                  await characteristicData.write('{\"system\":0}'.codeUnits);
                  restartAlertWidget(context, restartAlertDialogTitleTextLanguageArray[languageArrayIdentifier]);
                }
              },
              child: Text(
                configDefaultTextLanguageArray[languageArrayIdentifier],
                style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.025),
              ),
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.black),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.green[400])),
            ),
          ),
        ],
      );
    }
  }

  Future<void> restartAlertWidget(BuildContext context, String widgetMessage) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(attentionTextLanguageArray[languageArrayIdentifier]),
          content: Text(wifiConnexionAlertDialogTextLanguageArray[languageArrayIdentifier]),
          actions: <Widget>[
            TextButton(
              child: Text(
                okTextLanguageArray[languageArrayIdentifier],
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () async {
                if (myDevice.getConnectionState()) {
                  characteristicData.write('{\"system\":1}'.codeUnits);
                  await Future.delayed(Duration(milliseconds: 500));
                  homePageState = false;
                  myDevice.disconnect();
                  Navigator.of(context).pop();
                  removeReplacementRouts(context, ScanListBle());
                }
              },
            ),
            TextButton(
              child: Text(
                cancelTextLanguageArray[languageArrayIdentifier],
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                await Future.delayed(Duration(milliseconds: 500));
                if (Platform.isAndroid) {
                  dataCharAndroid2 = String.fromCharCodes(await characteristicData.read());
                }
                if (Platform.isIOS) {
                  savingDataWidget(context, waitTextLanguageArray[languageArrayIdentifier]);
                  dataCharIOS2p1 = await charDividedIOSRead(characteristicData);
                  dataCharIOS2p2 = await charDividedIOSRead(characteristicData);
                  dataCharIOS2p3 = await charDividedIOSRead(characteristicData);
                  Navigator.of(context).pop();
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> waitingWidget() async {
    double screenHeight = MediaQuery.of(context).size.height;
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(searchWifiConnexionTextLanguageArray[languageArrayIdentifier]),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SpinKitCircle(
                  color: Colors.blue[600],
                  size: screenHeight * 0.1,
                ),
              ],
            ),
          );
        });
  }

  Future<void> zoneNamesSettingsWidget(BuildContext context) async {
    double screenWidth = MediaQuery.of(context).size.width;
    final zone1NameEditor = TextEditingController();
    final zone2NameEditor = TextEditingController();
    final zone3NameEditor = TextEditingController();
    final zone4NameEditor = TextEditingController();
    zone1NameEditor.text = zonesNamesList[0];
    zone2NameEditor.text = zonesNamesList[1];
    zone3NameEditor.text = zonesNamesList[2];
    zone4NameEditor.text = zonesNamesList[3];
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(changeZoneNamesTextLanguageArray[languageArrayIdentifier]),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(flex: 1, child: Text(firstZoneTextLanguageArray[languageArrayIdentifier], style: TextStyle(fontSize: screenWidth * 0.02))),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 3, 0, 3),
                        child: TextField(
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          maxLength: 10,
                          controller: zone1NameEditor,
                          style: TextStyle(
                            fontSize: screenWidth * 0.025,
                            color: Colors.grey[800],
                          ),
                          decoration: InputDecoration(
                              hintText: 'exp:chamb123',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(flex: 1, child: Text(secondZoneTextLanguageArray[languageArrayIdentifier], style: TextStyle(fontSize: screenWidth * 0.02))),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 3, 0, 3),
                        child: TextField(
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          maxLength: 10,
                          controller: zone2NameEditor,
                          style: TextStyle(
                            fontSize: screenWidth * 0.025,
                            color: Colors.grey[800],
                          ),
                          decoration: InputDecoration(
                              hintText: 'exp:chamb123',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(flex: 1, child: Text(thirdZoneTextLanguageArray[languageArrayIdentifier], style: TextStyle(fontSize: screenWidth * 0.02))),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 3, 0, 3),
                        child: TextField(
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          maxLength: 10,
                          controller: zone3NameEditor,
                          style: TextStyle(
                            fontSize: screenWidth * 0.025,
                            color: Colors.grey[800],
                          ),
                          decoration: InputDecoration(
                              hintText: 'exp:chamb123',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(flex: 1, child: Text(fourthZoneTextLanguageArray[languageArrayIdentifier], style: TextStyle(fontSize: screenWidth * 0.02))),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 3, 0, 3),
                        child: TextField(
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          maxLength: 10,
                          controller: zone4NameEditor,
                          style: TextStyle(
                            fontSize: screenWidth * 0.025,
                            color: Colors.grey[800],
                          ),
                          decoration: InputDecoration(
                              hintText: 'exp:chamb123',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                renameTextLanguageArray[languageArrayIdentifier],
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () async {
                if (myDevice.getConnectionState()) {
                  zonesNamesList[0] = zone1NameEditor.text;
                  zonesNamesList[1] = zone2NameEditor.text;
                  zonesNamesList[2] = zone3NameEditor.text;
                  zonesNamesList[3] = zone4NameEditor.text;
                  String zoneNames = "{\"zones\":[${zonesNamesList[0]},${zonesNamesList[1]},${zonesNamesList[2]},${zonesNamesList[3]}]}";
                  await characteristicData.write(zoneNames.codeUnits);
                  await Future.delayed(Duration(milliseconds: 500));
                  if (Platform.isAndroid) {
                    dataCharAndroid2 = String.fromCharCodes(await characteristicData.read());
                  }
                  if (Platform.isIOS) {
                    savingDataWidget(context, waitTextLanguageArray[languageArrayIdentifier]);
                    dataCharIOS2p1 = await charDividedIOSRead(characteristicData);
                    dataCharIOS2p2 = await charDividedIOSRead(characteristicData);
                    dataCharIOS2p3 = await charDividedIOSRead(characteristicData);
                    Navigator.of(context).pop();
                  }
                  setState(() {});
                  Navigator.of(context).pop();
                }
              },
            ),
            TextButton(
              child: Text(
                cancelTextLanguageArray[languageArrayIdentifier],
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
