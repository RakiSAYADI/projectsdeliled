import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_dmx_maestro/services/DataVariables.dart';
import 'package:flutter_app_dmx_maestro/services/app_mode_service.dart';
import 'package:flutter_app_dmx_maestro/services/custom_container.dart';
import 'package:flutter_app_dmx_maestro/services/elavated_button.dart';
import 'package:flutter_app_dmx_maestro/services/uvcToast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  ToastyMessage myUvcToast;

  bool firstDisplayMainWidget = true;

  bool displayModems = false;

  List<String> zonesNamesList = ['', '', '', ''];
  String zonesInHex;

  List<String> wifiModems = [];
  String wifiModemsData = '';
  int wifiModemsPosition = 0;

  final passwordEditor = TextEditingController();
  final myBleDeviceName = TextEditingController();

  int boolToInt(bool a) => a == true ? 1 : 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myUvcToast = ToastyMessage(toastContext: context);
  }

  void readDataMaestro() async {
    try {
      var parsedJson;
      if (Platform.isIOS) {
        parsedJson = json.decode(dataMaestroIOS);
      }
      if (Platform.isAndroid) {
        parsedJson = json.decode(dataMaestro);
      }
      zonesNamesList[0] = parsedJson['zone'][0];
      zonesNamesList[1] = parsedJson['zone'][1];
      zonesNamesList[2] = parsedJson['zone'][2];
      zonesNamesList[3] = parsedJson['zone'][3];
      if (firstDisplayMainWidget) {
        myBleDeviceName.text = myDevice.device.name.substring(4);
        await Future.delayed(Duration(seconds: 2));
        if (parsedJson['wifiSt'] == 0) {
          myUvcToast.setToastDuration(5);
          myUvcToast.setToastMessage('Votre carte n\'est pas connectée avec votre modem !');
          myUvcToast.showToast(Colors.red, Icons.info, Colors.white);
        } else {
          myUvcToast.setToastDuration(5);
          myUvcToast.setToastMessage('Votre carte est bien connectée avec votre modem !');
          myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
        }
        firstDisplayMainWidget = false;
      }
    } catch (e) {
      print('error');
      zonesNamesList = ['Zone 1', 'Zone 2', 'Zone 3', 'Zone 4'];
    }
  }

  @override
  Widget build(BuildContext context) {
    readDataMaestro();
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    if (appMode) {
      backGroundColorSelect = 0;
    } else {
      backGroundColorSelect = 1;
    }
    print('width : $screenWidth and height : $screenHeight');
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: modeColor[backGroundColorSelect]),
          ),
        ),
        iconTheme: IconThemeData(
          color: textColor[backGroundColorSelect],
        ),
        title: Text(
          'Réglages',
          style: TextStyle(fontSize: 18, color: textColor[backGroundColorSelect]),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(color: backGroundColor[backGroundColorSelect]),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyCustomContainer(
                    shape: BoxShape.rectangle,
                    radius: 25,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 8.0),
                          child: Text(
                            'Nom du HuBBoX:',
                            style: TextStyle(fontSize: (screenWidth * 0.05), color: textColor[backGroundColorSelect]),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                myDevice.device.name.substring(0, 4),
                                style: TextStyle(fontSize: (screenWidth * 0.03), color: textColor[backGroundColorSelect]),
                              ),
                              Flexible(
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  controller: myBleDeviceName,
                                  maxLines: 1,
                                  maxLength: 64,
                                  cursorColor: textColor[backGroundColorSelect],
                                  style: TextStyle(fontSize: screenWidth * 0.02 + screenHeight * 0.02, color: textColor[backGroundColorSelect]),
                                  decoration: InputDecoration(
                                      counterStyle: TextStyle(color: textColor[backGroundColorSelect]),
                                      hintText: 'exp:Maestro1234',
                                      hintStyle: TextStyle(
                                        fontSize: screenWidth * 0.02 + screenHeight * 0.02,
                                        color: textColor[backGroundColorSelect],
                                      )),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 16.0),
                          child: MyElevatedButton(
                            onPressed: () {
                              if (myDevice.getConnectionState()) {
                                deviceNameAlertWidget(context, '${myDevice.device.name.substring(0, 4)}${myBleDeviceName.text}');
                              }
                            },
                            child: Text(
                              'Changer le nom',
                              style: TextStyle(color: textColor[backGroundColorSelect], fontSize: screenWidth * 0.04),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyCustomContainer(
                    shape: BoxShape.rectangle,
                    radius: 25,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 0),
                          child: Text(
                            'Réglages des zones:',
                            style: TextStyle(fontSize: (screenWidth * 0.05), color: textColor[backGroundColorSelect]),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              zoneButton(context, zonesNamesList[0], '1'),
                              zoneButton(context, zonesNamesList[1], '2'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              zoneButton(context, zonesNamesList[2], '4'),
                              zoneButton(context, zonesNamesList[3], '8'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyCustomContainer(
                    shape: BoxShape.rectangle,
                    radius: 25,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Connexion WiFi :',
                            style: TextStyle(fontSize: (screenWidth * 0.05), color: textColor[backGroundColorSelect]),
                          ),
                        ),
                        Visibility(
                          visible: displayModems,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
                              child: DropdownButton<String>(
                                value: wifiModemsData,
                                icon: Icon(Icons.arrow_drop_down),
                                iconSize: screenWidth * 0.04 + screenHeight * 0.01,
                                elevation: 16,
                                style: TextStyle(color: Colors.black, fontSize: 18),
                                underline: Container(
                                  height: 2,
                                  color: Colors.black,
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
                                    child: Text(
                                      value,
                                      style: TextStyle(fontSize: screenWidth * 0.02 + screenHeight * 0.01),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: MyElevatedButton(
                            onPressed: () async {
                              displayAlert(
                                  context,
                                  'Recherche des réseaux WiFi disponibles',
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SpinKitCircle(
                                        color: Colors.blue[600],
                                        size: screenHeight * 0.1,
                                      ),
                                    ],
                                  ),
                                  null);
                              // write the scan command
                              if (myDevice.getConnectionState()) {
                                try {
                                  await characteristicWifi.write('{\"SCAN\":1}'.codeUnits);
                                  await Future.delayed(Duration(milliseconds: 500));
                                  String wifiScanningState = String.fromCharCodes(await characteristicMaestro.read());
                                  var parsedJson = json.decode(wifiScanningState);
                                  while (parsedJson['SCR'] == '0') {
                                    wifiScanningState = String.fromCharCodes(await characteristicMaestro.read());
                                    parsedJson = json.decode(wifiScanningState);
                                    await Future.delayed(Duration(seconds: 1));
                                  }
                                  String wifiScanningResult = String.fromCharCodes(await characteristicWifi.read());
                                  parsedJson = json.decode(wifiScanningResult);
                                  List<dynamic> modems = parsedJson['AP_RECORDS'];
                                  wifiModems = List<String>.from(modems);
                                  wifiModemsData = wifiModems[0];
                                } catch (e) {
                                  print('error in esp32 Communication');
                                  myUvcToast.setToastDuration(5);
                                  myUvcToast.setToastMessage('Erreur de communication !');
                                  myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
                                }
                                Navigator.pop(context, false);
                                displayModems = true;
                                setState(() {});
                              }
                            },
                            child: Text(
                              'Scanner',
                              style: TextStyle(color: textColor[backGroundColorSelect], fontSize: screenWidth * 0.04),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Mot de passe :',
                            style: TextStyle(fontSize: (screenWidth * 0.05), color: textColor[backGroundColorSelect]),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
                          child: TextField(
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            maxLength: 64,
                            controller: passwordEditor,
                            cursorColor: textColor[backGroundColorSelect],
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: textColor[backGroundColorSelect],
                            ),
                            decoration: InputDecoration(
                                counterStyle: TextStyle(color: textColor[backGroundColorSelect]),
                                hintText: 'exemple : 123',
                                hintStyle: TextStyle(
                                  color: textColor[backGroundColorSelect],
                                )),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 16.0),
                          child: MyElevatedButton(
                            onPressed: () async {
                              if (myDevice.getConnectionState()) {
                                // write the new access point and it's password
                                await characteristicMaestro.write('{\"wa\":\"$wifiModemsData\",\"wp\":\"${passwordEditor.text}\"}'.codeUnits);
                                restartAlertWidget(context, 'Voulez vous redemarrer la carte pour assurer la connection avec votre modem ?');
                              }
                            },
                            child: Text(
                              'Connecter',
                              style: TextStyle(color: textColor[backGroundColorSelect], fontSize: screenWidth * 0.04),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Mode sombre :',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: (screenWidth * 0.05),
                          color: textColor[backGroundColorSelect],
                        ),
                      ),
                      Switch(
                        value: appMode,
                        onChanged: (value) async {
                          appMode = value;
                          AppMode appModeClass = AppMode();
                          await appModeClass.saveAppModeDATA(appMode);
                          setState(() {});
                        },
                        activeTrackColor: Colors.grey,
                        activeColor: Colors.white,
                        inactiveThumbColor: Colors.black,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: restartAndResetWidget(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget zoneButton(BuildContext context, String zoneName, String zoneID) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MyElevatedButton(
        onPressed: () {
          zoneAssociateOrDissociate(context, zoneID);
        },
        child: Text(
          zoneName,
          style: TextStyle(color: textColor[backGroundColorSelect], fontSize: screenWidth * 0.02 + screenHeight * 0.02),
        ),
      ),
    );
  }

  Widget restartAndResetWidget(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 480.0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: MyElevatedButton(
              onPressed: () async {
                if (myDevice.getConnectionState()) {
                  // write the restart command
                  characteristicMaestro.write('{\"system\":1}'.codeUnits);
                  await Future.delayed(Duration(milliseconds: 500));
                  myDevice.disconnect();
                  Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
                }
              },
              child: Text(
                'Redémarrage',
                style: TextStyle(color: textColor[backGroundColorSelect], fontSize: screenWidth * 0.04),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: MyElevatedButton(
              onPressed: () async {
                if (myDevice.getConnectionState()) {
                  // write the reset command
                  await characteristicMaestro.write('{\"system\":0}'.codeUnits);
                  restartAlertWidget(context, 'Voulez vous redemarrer la carte pour assurer ces modifications?');
                }
              },
              child: Text(
                'Configuration par défault',
                style: TextStyle(color: textColor[backGroundColorSelect], fontSize: screenWidth * 0.04),
              ),
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
            child: MyElevatedButton(
              onPressed: () async {
                if (myDevice.getConnectionState()) {
                  // write the restart command
                  characteristicMaestro.write('{\"system\":1}'.codeUnits);
                  await Future.delayed(Duration(milliseconds: 500));
                  myDevice.disconnect();
                  Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
                }
              },
              child: Text(
                'Redémarrage',
                style: TextStyle(color: textColor[backGroundColorSelect], fontSize: screenWidth * 0.04),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: MyElevatedButton(
              onPressed: () async {
                if (myDevice.getConnectionState()) {
                  // write the reset command
                  await characteristicMaestro.write('{\"system\":0}'.codeUnits);
                  restartAlertWidget(context, 'Voulez vous redemarrer la carte pour assurer ces modifications?');
                }
              },
              child: Text(
                'Configuration par défault',
                style: TextStyle(color: textColor[backGroundColorSelect], fontSize: screenWidth * 0.04),
              ),
            ),
          ),
        ],
      );
    }
  }

  Future<void> restartAlertWidget(BuildContext context, String widgetMessage) {
    return displayAlert(
      context,
      'Attention',
      Text(widgetMessage, style: TextStyle(color: textColor[backGroundColorSelect])),
      [
        TextButton(
          child: Text(
            'OK',
            style: TextStyle(color: Colors.green),
          ),
          onPressed: () async {
            if (myDevice.getConnectionState()) {
              characteristicMaestro.write('{\"system\":1}'.codeUnits);
              myDevice.disconnect();
              Navigator.of(context).pop();
              Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
            }
          },
        ),
        TextButton(
          child: Text(
            'Annuler',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () async {
            await readBLEData();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Future<void> deviceNameAlertWidget(BuildContext context, String deviceName) async {
    displayAlert(
      context,
      'Nouveau nom de HuBBoX',
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(deviceName, style: TextStyle(color: textColor[backGroundColorSelect])),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.warning, size: 15),
              ),
              Flexible(
                child: Text(
                  'Attention: La validation  le redémarrage de l\'application et l\'HuBBoX.',
                  style: TextStyle(color: textColor[backGroundColorSelect], fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
      [
        TextButton(
          child: Text(
            'Valider',
            style: TextStyle(color: positiveButton[backGroundColorSelect]),
          ),
          onPressed: () async {
            if (myDevice.getConnectionState()) {
              // write the new ble device name
              await characteristicMaestro.write('{\"dname\":\"$deviceName\"}'.codeUnits);
              await Future.delayed(Duration(milliseconds: 300));
              characteristicMaestro.write('{\"system\":1}'.codeUnits);
              myDevice.disconnect();
              Navigator.of(context).pop();
              Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
            }
          },
        ),
        TextButton(
          child: Text(
            'Annuler',
            style: TextStyle(color: negativeButton[backGroundColorSelect]),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            FocusManager.instance.primaryFocus?.unfocus();
          },
        ),
      ],
    );
  }

  void zoneAssociateOrDissociate(BuildContext context, String zoneID) {
    double screenWidth = MediaQuery.of(context).size.width;
    int zoneIdentifier;
    switch (zoneID) {
      case '1':
        zoneIdentifier = 0;
        break;
      case '2':
        zoneIdentifier = 1;
        break;
      case '4':
        zoneIdentifier = 2;
        break;
      case '8':
        zoneIdentifier = 3;
        break;
    }
    final zoneNameEditor = TextEditingController();
    zoneNameEditor.text = zonesNamesList[zoneIdentifier];
    displayAlert(
        context,
        'Zone ${zoneIdentifier + 1}',
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 3, 0, 3),
              child: TextField(
                textAlign: TextAlign.center,
                maxLines: 1,
                maxLength: 6,
                controller: zoneNameEditor,
                cursorColor: textColor[backGroundColorSelect],
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: textColor[backGroundColorSelect],
                ),
                decoration: InputDecoration(
                    counterStyle: TextStyle(
                      color: textColor[backGroundColorSelect],
                    ),
                    hintText: 'exp:chamb123',
                    hintStyle: TextStyle(
                      color: textColor[backGroundColorSelect],
                    )),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyElevatedButton(
                    onPressed: () async {
                      if (myDevice.getConnectionState()) {
                        // write the associate command
                        await characteristicMaestro.write('{\"light\":[5,1,\"$zoneID\"]}'.codeUnits);
                        myUvcToast.setToastDuration(5);
                        myUvcToast.setToastMessage('Votre carte n\'est pas connectée avec votre modem !');
                        myUvcToast.showToast(Colors.red, Icons.info, Colors.white);
                      }
                    },
                    child: Text(
                      'Associer',
                      style: TextStyle(color: Colors.green, fontSize: screenWidth * 0.04),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyElevatedButton(
                    onPressed: () async {
                      if (myDevice.getConnectionState()) {
                        // write the dissociate command
                        await characteristicMaestro.write('{\"light\":[5,0,\"$zoneID\"]}'.codeUnits);
                      }
                    },
                    child: Text(
                      'Dissocier',
                      style: TextStyle(color: Colors.red, fontSize: screenWidth * 0.04),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        [
          TextButton(
            child: Text(
              'Terminer',
              style: TextStyle(color: positiveButton[backGroundColorSelect]),
            ),
            onPressed: () async {
              if (myDevice.getConnectionState()) {
                zonesNamesList[zoneIdentifier] = zoneNameEditor.text;
                String zoneNames = "{\"zones\":[${zonesNamesList[0]},${zonesNamesList[1]},${zonesNamesList[2]},${zonesNamesList[3]}]}";
                await characteristicMaestro.write(zoneNames.codeUnits);
                Navigator.of(context).pop();
                await readBLEData();
                setState(() {});
              }
            },
          ),
        ]);
  }
}
