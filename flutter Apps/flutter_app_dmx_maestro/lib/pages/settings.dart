import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_dmx_maestro/services/DataVariables.dart';
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
      myBleDeviceName.text = myDevice.device.name.substring(4);
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
      await Future.delayed(Duration(seconds: 2));
      if (firstDisplayMainWidget) {
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
      print('erreur');
      zonesNamesList = ['Zone 1', 'Zone 2', 'Zone 3', 'Zone 4'];
    }
  }

  @override
  Widget build(BuildContext context) {
    readDataMaestro();
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    print('width : $screenWidth and height : $screenHeight');
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: modeColor[backGroundColorSelect]),
          ),
        ),
        title: Text(
          'Réglages',
          style: TextStyle(fontSize: 18,color: textColor[backGroundColorSelect]),
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
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Nom du convertisseur DMX :',
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
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: MyElevatedButton(
                            onPressed: () async {
                              if (myDevice.getConnectionState()) {
                                // write the new ble device name
                                await characteristicMaestro.write('{\"dname\":\"${myDevice.device.name.substring(0, 4)}${myBleDeviceName.text}\"}'.codeUnits);
                                myUvcToast.setToastDuration(5);
                                myUvcToast.setToastMessage('Nom de carte modifié , faudrais redémarrer la carte pour appliquer cette modification !');
                                myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
                              }
                            },
                            child: Text(
                              'Changer le nom',
                              style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
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
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Vos Zones :',
                            style: TextStyle(fontSize: (screenWidth * 0.05), color: textColor[backGroundColorSelect]),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: MyElevatedButton(
                                onPressed: () async {
                                  zoneAssociateOrDissociate(context, zonesNamesList[0], '1');
                                },
                                child: Text(
                                  zonesNamesList[0],
                                  style: TextStyle(color: textColor[backGroundColorSelect], fontSize: screenWidth * 0.02 + screenHeight * 0.02),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: MyElevatedButton(
                                onPressed: () {
                                  zoneAssociateOrDissociate(context, zonesNamesList[1], '2');
                                },
                                child: Text(
                                  zonesNamesList[1],
                                  style: TextStyle(color: textColor[backGroundColorSelect], fontSize: screenWidth * 0.02 + screenHeight * 0.02),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: MyElevatedButton(
                                onPressed: () {
                                  zoneAssociateOrDissociate(context, zonesNamesList[2], '4');
                                },
                                child: Text(
                                  zonesNamesList[2],
                                  style: TextStyle(color: textColor[backGroundColorSelect], fontSize: screenWidth * 0.02 + screenHeight * 0.02),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: MyElevatedButton(
                                onPressed: () {
                                  zoneAssociateOrDissociate(context, zonesNamesList[3], '8');
                                },
                                child: Text(
                                  zonesNamesList[3],
                                  style: TextStyle(color: textColor[backGroundColorSelect], fontSize: screenWidth * 0.02 + screenHeight * 0.02),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: MyElevatedButton(
                            onPressed: () {
                              // write the new zone names
                              zoneNamesSettingsWidget(context);
                            },
                            child: Text(
                              'Renommer',
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
                          padding: const EdgeInsets.all(8.0),
                          child: MyElevatedButton(
                            onPressed: () async {
                              // write the new access point and it's password
                              await characteristicMaestro.write('{\"wa\":\"$wifiModemsData\",\"wp\":\"${passwordEditor.text}\"}'.codeUnits);
                              restartAlertWidget(context, 'Voulez vous redemarrer la carte pour assurer la connection avec votre modem ?');
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
                  child: restartAndResetWidget(context),
                ),
              ],
            ),
          ),
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
                // write the restart command
                characteristicMaestro.write('{\"system\":1}'.codeUnits);
                await Future.delayed(Duration(milliseconds: 500));
                myDevice.disconnect();
                Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
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
                // write the reset command
                await characteristicMaestro.write('{\"system\":0}'.codeUnits);
                restartAlertWidget(context, 'Voulez vous redemarrer la carte pour assurer ces modifications?');
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
                // write the restart command
                characteristicMaestro.write('{\"system\":1}'.codeUnits);
                await Future.delayed(Duration(milliseconds: 500));
                myDevice.disconnect();
                Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
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
                // write the reset command
                await characteristicMaestro.write('{\"system\":0}'.codeUnits);
                restartAlertWidget(context, 'Voulez vous redemarrer la carte pour assurer ces modifications?');
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
      Text('La carte DMX va redémarrer afin de finaliser la connexion au WiFi'),
      [
        TextButton(
          child: Text(
            'OK',
            style: TextStyle(color: Colors.green),
          ),
          onPressed: () async {
            characteristicMaestro.write('{\"system\":1}'.codeUnits);
            myDevice.disconnect();
            Navigator.of(context).pop();
            Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
          },
        ),
        TextButton(
          child: Text(
            'Annuler',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () async {
            if (Platform.isIOS) {
              await Future.delayed(Duration(milliseconds: 500));
              dataMaestroIOS = String.fromCharCodes(await characteristicWifi.read());
              await Future.delayed(Duration(milliseconds: 500));
              dataMaestroIOS2 = String.fromCharCodes(await characteristicWifi.read());
              await Future.delayed(Duration(milliseconds: 500));
              dataMaestroIOS3 = String.fromCharCodes(await characteristicWifi.read());
              await Future.delayed(Duration(milliseconds: 500));
              dataMaestroIOS4 = String.fromCharCodes(await characteristicWifi.read());
              await Future.delayed(Duration(milliseconds: 500));
              dataMaestroIOS5 = String.fromCharCodes(await characteristicWifi.read());
              await Future.delayed(Duration(milliseconds: 500));
              dataMaestroIOS6 = String.fromCharCodes(await characteristicWifi.read());
            }
            if (Platform.isAndroid) {
              await Future.delayed(Duration(milliseconds: 500));
              dataMaestro = String.fromCharCodes(await characteristicWifi.read());
              await Future.delayed(Duration(milliseconds: 500));
              dataMaestro2 = String.fromCharCodes(await characteristicWifi.read());
              await Future.delayed(Duration(milliseconds: 500));
              dataMaestro3 = String.fromCharCodes(await characteristicWifi.read());
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Future<void> zoneNamesSettingsWidget(BuildContext context) async {
    double screenWidth = MediaQuery.of(context).size.width;
    //double screenHeight = MediaQuery.of(context).size.height;
    final zone1NameEditor = TextEditingController();
    final zone2NameEditor = TextEditingController();
    final zone3NameEditor = TextEditingController();
    final zone4NameEditor = TextEditingController();
    zone1NameEditor.text = zonesNamesList[0];
    zone2NameEditor.text = zonesNamesList[1];
    zone3NameEditor.text = zonesNamesList[2];
    zone4NameEditor.text = zonesNamesList[3];
    displayAlert(
        context,
        'Changer les noms de vos zones:',
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                child: MyCustomContainer(
                  shape: BoxShape.rectangle,
                  radius: 20,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Text('Zone 1 :',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor[backGroundColorSelect],
                                ))),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 3, 0, 3),
                            child: TextField(
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              maxLength: 10,
                              controller: zone1NameEditor,
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                child: MyCustomContainer(
                  shape: BoxShape.rectangle,
                  radius: 20,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Text('Zone 2 :',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor[backGroundColorSelect],
                                ))),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 3, 0, 3),
                            child: TextField(
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              maxLength: 10,
                              controller: zone2NameEditor,
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                child: MyCustomContainer(
                  shape: BoxShape.rectangle,
                  radius: 20,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(flex: 1, child: Text('Zone 3 :', style: TextStyle(fontSize: 14, color: textColor[backGroundColorSelect]))),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 3, 0, 3),
                            child: TextField(
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              maxLength: 10,
                              controller: zone3NameEditor,
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                child: MyCustomContainer(
                  shape: BoxShape.rectangle,
                  radius: 20,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(flex: 1, child: Text('Zone 4 :', style: TextStyle(fontSize: 14, color: textColor[backGroundColorSelect]))),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 3, 0, 3),
                            child: TextField(
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              maxLength: 10,
                              controller: zone4NameEditor,
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        [
          TextButton(
            child: Text(
              'Renommer',
              style: TextStyle(color: positiveButton[backGroundColorSelect]),
            ),
            onPressed: () async {
              zonesNamesList[0] = zone1NameEditor.text;
              zonesNamesList[1] = zone2NameEditor.text;
              zonesNamesList[2] = zone3NameEditor.text;
              zonesNamesList[3] = zone4NameEditor.text;
              String zoneNames = "{\"zones\":[${zonesNamesList[0]},${zonesNamesList[1]},${zonesNamesList[2]},${zonesNamesList[3]}]}";
              await characteristicMaestro.write(zoneNames.codeUnits);
              Navigator.of(context).pop();
              if (Platform.isIOS) {
                await Future.delayed(Duration(milliseconds: 500));
                dataMaestroIOS = String.fromCharCodes(await characteristicWifi.read());
                await Future.delayed(Duration(milliseconds: 500));
                dataMaestroIOS2 = String.fromCharCodes(await characteristicWifi.read());
                await Future.delayed(Duration(milliseconds: 500));
                dataMaestroIOS3 = String.fromCharCodes(await characteristicWifi.read());
                await Future.delayed(Duration(milliseconds: 500));
                dataMaestroIOS4 = String.fromCharCodes(await characteristicWifi.read());
                await Future.delayed(Duration(milliseconds: 500));
                dataMaestroIOS5 = String.fromCharCodes(await characteristicWifi.read());
                await Future.delayed(Duration(milliseconds: 500));
                dataMaestroIOS6 = String.fromCharCodes(await characteristicWifi.read());
              }
              if (Platform.isAndroid) {
                await Future.delayed(Duration(milliseconds: 500));
                dataMaestro = String.fromCharCodes(await characteristicWifi.read());
                await Future.delayed(Duration(milliseconds: 500));
                dataMaestro2 = String.fromCharCodes(await characteristicWifi.read());
                await Future.delayed(Duration(milliseconds: 500));
                dataMaestro3 = String.fromCharCodes(await characteristicWifi.read());
              }
              setState(() {});
            },
          ),
          TextButton(
            child: Text(
              'Annuler',
              style: TextStyle(color: negativeButton[backGroundColorSelect]),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ]);
  }

  void zoneAssociateOrDissociate(BuildContext context, String zoneName, String zoneID) {
    double screenWidth = MediaQuery.of(context).size.width;
    displayAlert(
        context,
        zoneName,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MyElevatedButton(
                onPressed: () async {
                  // write the associate command
                  await characteristicMaestro.write('{\"light\":[5,1,\"$zoneID\"]}'.codeUnits);
                  myUvcToast.setToastDuration(5);
                  myUvcToast.setToastMessage('Votre carte n\'est pas connectée avec votre modem !');
                  myUvcToast.showToast(Colors.red, Icons.info, Colors.white);
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
                  // write the dissociate command
                  await characteristicMaestro.write('{\"light\":[5,0,\"$zoneID\"]}'.codeUnits);
                },
                child: Text(
                  'Dissocier',
                  style: TextStyle(color: Colors.red, fontSize: screenWidth * 0.04),
                ),
              ),
            ),
          ],
        ),
        [
          TextButton(
            child: Text(
              'Terminer',
              style: TextStyle(color: positiveButton[backGroundColorSelect]),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ]);
  }
}
