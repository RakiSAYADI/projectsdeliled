import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_dmx_maestro/services/uvcToast.dart';
import 'package:flutter_blue/flutter_blue.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  ToastyMessage myUvcToast;

  Map bleDeviceData = {};

  BluetoothCharacteristic characteristicMaestro;
  BluetoothDevice myDevice;

  bool firstDisplayMainWidget = true;

  List<bool> zoneStates;
  List<String> zonesNamesList;
  String zonesInHex;

  final myBleDeviceName = TextEditingController();

  int boolToInt(bool a) => a == true ? 1 : 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    zonesNamesList = ['  Zone 1  ', '  Zone 2  ', '  Zone 3  ', '  Zone 4  '];
    myUvcToast = ToastyMessage(toastContext: context);
    zoneStates = [false, false, false, false];
    zonesInHex = ((boolToInt(zoneStates[0])) + (boolToInt(zoneStates[1]) * 2) + (boolToInt(zoneStates[2]) * 4) + (boolToInt(zoneStates[3]) * 8))
        .toRadixString(16);
  }

  @override
  Widget build(BuildContext context) {
    bleDeviceData = bleDeviceData.isNotEmpty ? bleDeviceData : ModalRoute.of(context).settings.arguments;
    myDevice = bleDeviceData['bleDevice'];
    characteristicMaestro = bleDeviceData['bleCharacteristic'];

    if (firstDisplayMainWidget) {
      myBleDeviceName.text = myDevice.name;
      firstDisplayMainWidget = false;
    }

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('Réglages'),
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
                        'Nom de HuBBox Maestro :',
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
                      padding: const EdgeInsets.all(8.0),
                      child: FlatButton(
                        onPressed: () async {
                          // write the new ble device name
                          print('{\"dname\":\"${myBleDeviceName.text}\"}');
                          await characteristicMaestro.write('{\"dname\":\"${myBleDeviceName.text}\"}'.codeUnits);
                          myUvcToast.setToastDuration(5);
                          myUvcToast.setToastMessage('Nom de carte modifié !');
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
                      padding: const EdgeInsets.symmetric(horizontal: 30),
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

                        print(zonesInHex);
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
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> zoneNamesSettingsWidget(BuildContext context) async {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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
            FlatButton(
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
            FlatButton(
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
