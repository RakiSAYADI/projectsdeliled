import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app_dmx_maestro/services/DataVariables.dart';
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

  List<bool> zoneStates;
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
    zoneStates = [false, false, false, false];
    zonesInHex = ((boolToInt(zoneStates[0])) + (boolToInt(zoneStates[1]) * 2) + (boolToInt(zoneStates[2]) * 4) + (boolToInt(zoneStates[3]) * 8))
        .toRadixString(16);
  }

  void readDataMaestro() async {
    try {
      myBleDeviceName.text = myDevice.device.name;
      var parsedJson = json.decode(dataMaestro);
      zonesNamesList[0] = parsedJson['zone'][0];
      zonesNamesList[1] = parsedJson['zone'][1];
      zonesNamesList[2] = parsedJson['zone'][2];
      zonesNamesList[3] = parsedJson['zone'][3];
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
    } catch (e) {
      print('erreur');
      zonesNamesList = ['Zone 1', 'Zone 2', 'Zone 3', 'Zone 4'];
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Réglages',style: TextStyle(fontSize: 18),),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Nom du convertisseur DMX :',
                        style: TextStyle(fontSize: (screenWidth * 0.05)),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: myBleDeviceName,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: (screenWidth * 0.05),
                        ),
                        decoration: InputDecoration(
                            hintText: 'exp:Maestro1234',
                            hintStyle: TextStyle(
                              fontSize: (screenWidth * 0.05),
                              color: Colors.grey,
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: FlatButton(
                        onPressed: () async {
                          // write the new ble device name
                          await characteristicMaestro.write('{\"dname\":\"${myBleDeviceName.text}\"}'.codeUnits);
                          myUvcToast.setToastDuration(5);
                          myUvcToast.setToastMessage('Nom de carte modifié , faudrais redémarrer la carte pour appliquer cette modification !');
                          myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
                        },
                        child: Text(
                          'Changer le nom',
                          style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        color: Colors.blue[400],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(
                        thickness: 3.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Vos Zones :',
                        style: TextStyle(fontSize: (screenWidth * 0.05)),
                      ),
                    ),
                    ToggleButtons(
                      borderRadius: BorderRadius.circular(18.0),
                      isSelected: zoneStates,
                      onPressed: (int index) async {
                        setState(() {
                          zoneStates[index] = !zoneStates[index];
                        });
                        zonesInHex = ((boolToInt(zoneStates[0])) +
                            (boolToInt(zoneStates[1]) * 2) +
                            (boolToInt(zoneStates[2]) * 4) +
                            (boolToInt(zoneStates[3]) * 8))
                            .toRadixString(16);
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
                          child: FlatButton(
                            onPressed: () async {
                              // write the associate command
                              await characteristicMaestro.write('{\"light\":[5,1,\"$zonesInHex \"]}'.codeUnits);
                              myUvcToast.setToastDuration(5);
                              myUvcToast.setToastMessage('Votre carte n\'est pas connectée avec votre modem !');
                              myUvcToast.showToast(Colors.red, Icons.info, Colors.white);
                            },
                            child: Text(
                              'Associer',
                              style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            color: Colors.green[400],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FlatButton(
                            onPressed: () async {
                              // write the dissociate command
                              await characteristicMaestro.write('{\"light\":[5,0,\"$zonesInHex \"]}'.codeUnits);
                            },
                            child: Text(
                              'Dissocier',
                              style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            color: Colors.red[400],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FlatButton(
                        onPressed: () {
                          // write the new zone names
                          zoneNamesSettingsWidget(context);
                        },
                        child: Text(
                          'Renommer',
                          style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        color: Colors.grey[400],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(
                        thickness: 3.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Connexion WiFi :',
                        style: TextStyle(fontSize: (screenWidth * 0.05)),
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
                      child: FlatButton(
                        onPressed: () async {
                          waitingWidget();
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
                          style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        color: Colors.grey[400],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Mot de passe :',
                        style: TextStyle(fontSize: (screenWidth * 0.05)),
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
                          fontSize: screenWidth * 0.04,
                          color: Colors.grey[800],
                        ),
                        decoration: InputDecoration(
                            hintText: 'exemple : 123',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FlatButton(
                        onPressed: () async {
                          // write the new access point and it's password
                          await characteristicMaestro.write('{\"wa\":\"$wifiModemsData\",\"wp\":\"${passwordEditor.text}\"}'.codeUnits);
                          restartAlertWidget(context, 'Voulez vous redemarrer la carte pour assurer la connection avec votre modem ?');
                        },
                        child: Text(
                          'Connecter',
                          style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        color: Colors.grey[400],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(
                        thickness: 3.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    restartAndResetWidget(context),
                  ],
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
            child: FlatButton(
              onPressed: () async {
                // write the restart command
                characteristicMaestro.write('{\"system\":1}'.codeUnits);
                myDevice.disconnect();
                Navigator.pushNamedAndRemoveUntil(context, "/scan_ble_list", (r) => false);
              },
              child: Text(
                'Redémarrage',
                style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
              color: Colors.blue[400],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: FlatButton(
              onPressed: () async {
                // write the reset command
                await characteristicMaestro.write('{\"system\":0}'.codeUnits);
                restartAlertWidget(context, 'Voulez vous redemarrer la carte pour assurer ces modifications?');
              },
              child: Text(
                'Configuration par défault',
                style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
              color: Colors.blue[400],
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
            child: FlatButton(
              onPressed: () async {
                // write the restart command
                characteristicMaestro.write('{\"system\":1}'.codeUnits);
                myDevice.disconnect();
                Navigator.pushNamedAndRemoveUntil(context, "/scan_ble_list", (r) => false);
              },
              child: Text(
                'Redémarrage',
                style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
              color: Colors.blue[400],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: FlatButton(
              onPressed: () async {
                // write the reset command
                await characteristicMaestro.write('{\"system\":0}'.codeUnits);
                restartAlertWidget(context, 'Voulez vous redemarrer la carte pour assurer ces modifications?');
              },
              child: Text(
                'Configuration par défault',
                style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
              color: Colors.blue[400],
            ),
          ),
        ],
      );
    }
  }

/*  void connectingToAccessPoint() async {
    await Future.delayed(Duration(seconds: 1));
    try {
      String wifiState = String.fromCharCodes(await characteristicMaestro.read());
      var parsedJson = json.decode(wifiState);
      while (parsedJson['wifiSt'] == '0') {
        wifiState = String.fromCharCodes(await characteristicMaestro.read());
        parsedJson = json.decode(wifiState);
        await Future.delayed(Duration(seconds: 1));
      }
      myUvcToast.setToastDuration(5);
      myUvcToast.setToastMessage('Connection à $wifiModemsData est établi avec succès !');
      myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
    } catch (e) {
      print('error in esp32 Communication');
      myUvcToast.setToastDuration(5);
      myUvcToast.setToastMessage('Erreur de communication !');
      myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
    }
  }*/

  Future<void> restartAlertWidget(BuildContext context, String widgetMessage) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Attention'),
          content: Text('La carte DMX va redémarrer afin de finaliser la connexion au WiFi'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () async {
                characteristicMaestro.write('{\"system\":1}'.codeUnits);
                myDevice.disconnect();
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(context, "/scan_ble_list", (r) => false);
              },
            ),
            TextButton(
              child: Text(
                'Annuler',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                await Future.delayed(Duration(milliseconds: 500));
                dataMaestro = String.fromCharCodes(await characteristicMaestro.read());
                await Future.delayed(Duration(milliseconds: 500));
                dataMaestro2 = String.fromCharCodes(await characteristicMaestro.read());
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> waitingWidget() async {
    //double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Recherche des réseaux WiFi disponibles'),
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
    //double screenHeight = MediaQuery.of(context).size.height;
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
          title: Text('Changer les noms de vos zones:'),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(flex: 1, child: Text('Zone 1 :', style: TextStyle(fontSize: 14))),
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
                            fontSize: screenWidth * 0.04,
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
                    Expanded(flex: 1, child: Text('Zone 2 :', style: TextStyle(fontSize: 14))),
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
                            fontSize: screenWidth * 0.04,
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
                    Expanded(flex: 1, child: Text('Zone 3 :', style: TextStyle(fontSize: 14))),
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
                            fontSize: screenWidth * 0.04,
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
                    Expanded(flex: 1, child: Text('Zone 4 :', style: TextStyle(fontSize: 14))),
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
                            fontSize: screenWidth * 0.04,
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
                'Renommer',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () async {
                zonesNamesList[0] = zone1NameEditor.text;
                zonesNamesList[1] = zone2NameEditor.text;
                zonesNamesList[2] = zone3NameEditor.text;
                zonesNamesList[3] = zone4NameEditor.text;
                String zoneNames = "{\"zones\":[${zonesNamesList[0]},${zonesNamesList[1]},${zonesNamesList[2]},${zonesNamesList[3]}]}";
                await characteristicMaestro.write(zoneNames.codeUnits);
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
            TextButton(
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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
