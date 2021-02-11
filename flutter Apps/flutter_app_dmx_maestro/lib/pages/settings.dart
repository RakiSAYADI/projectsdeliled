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

  List<bool> zoneStates;
  String zonesInHex;

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

  @override
  Widget build(BuildContext context) {
    bleDeviceData = bleDeviceData.isNotEmpty ? bleDeviceData : ModalRoute.of(context).settings.arguments;
    myDevice = bleDeviceData['bleDevice'];
    characteristicMaestro = bleDeviceData['bleCharacteristic'];

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
                    Text(
                      'Nom de HuBBox Maestro :',
                      style: TextStyle(fontSize: (screenWidth * 0.05)),
                    ),
                    SizedBox(height: screenHeight * 0.05),
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
                    SizedBox(height: screenHeight * 0.05),
                    Text(
                      'Vos Zones :',
                      style: TextStyle(fontSize: (screenWidth * 0.05)),
                    ),
                    SizedBox(height: screenHeight * 0.05),
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
                        Text('  Zone 1  ', style: TextStyle(fontSize: screenWidth * 0.02 + screenHeight * 0.02)),
                        Text('  Zone 2  ', style: TextStyle(fontSize: screenWidth * 0.02 + screenHeight * 0.02)),
                        Text('  Zone 3  ', style: TextStyle(fontSize: screenWidth * 0.02 + screenHeight * 0.02)),
                        Text('  Zone 4  ', style: TextStyle(fontSize: screenWidth * 0.02 + screenHeight * 0.02)),
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
                        FlatButton(
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
                        SizedBox(width: screenWidth * 0.03),
                        FlatButton(
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
                      ],
                    ),
                    SizedBox(width: screenHeight * 0.03),
                    FlatButton(
                      onPressed: () async {
                        // write the new zone names
                        //String zoneNames = "{\"zones\":[" + Zone_1 + "," + Zone_2 + "," + Zone_3 + "," + Zone_4 + "]}";
                        //await characteristicMaestro.write(zoneNames.codeUnits);
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
                    SizedBox(height: screenHeight * 0.04),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Divider(
                        thickness: 1.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    FlatButton(
                      onPressed: () async {
                        // write the new ble device name
                        print('{\"dname\":\"${myBleDeviceName.text}\"}');
                        await characteristicMaestro.write('{\"dname\":\"${myBleDeviceName.text}\"}'.codeUnits);
                        myUvcToast.setToastDuration(5);
                        myUvcToast.setToastMessage('Nom de carte modifié !');
                        myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
                      },
                      child: Text(
                        'Appliquer',
                        style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      color: Colors.blue[400],
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
}
