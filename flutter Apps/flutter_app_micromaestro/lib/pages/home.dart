import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutterappmicromaestro/services/bleDeviceClass.dart';
import 'package:hsl_colorpicker/HSLColorPicker.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map bleDeviceData = {};
  BluetoothCharacteristic characteristicMaestro;
  BluetoothDevice myDevice;

  List<bool> zoneStates;
  String zonesInHex;

  Device hello;

  final myBleDeviceName = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    zoneStates = [false, false, false, false];
    zonesInHex = ((boolToInt(zoneStates[0])) +
            (boolToInt(zoneStates[1]) * 2) +
            (boolToInt(zoneStates[2]) * 4) +
            (boolToInt(zoneStates[3]) * 8))
        .toRadixString(16);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    myBleDeviceName.dispose();
  }

  HSLColor hslColor = HSLColor.fromColor(Colors.blue);
  Color color = Colors.blue;

  int boolToInt(bool a) => a == true ? 1 : 0;

  @override
  Widget build(BuildContext context) {
    bleDeviceData = bleDeviceData.isNotEmpty
        ? bleDeviceData
        : ModalRoute.of(context).settings.arguments;
    myDevice = bleDeviceData['bleDevice'];
    characteristicMaestro = bleDeviceData['bleCharacteristic'];

    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: color,
          title: Stack(
            children: <Widget>[
              Text(
                "HSL COLOR PICKER: ${"#" + color.toString().split("0x")[1].toUpperCase().replaceFirst("FF", "").replaceAll(")", "")}",
                style: TextStyle(
                  fontSize: 16,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 1
                    ..color = Colors.grey,
                ),
              ),
              Text(
                "HSL COLOR PICKER: ${"#" + color.toString().split("0x")[1].toUpperCase().replaceFirst("FF", "").replaceAll(")", "")}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ToggleButtons(
                    isSelected: zoneStates,
                    onPressed: (int index) async {
                      setState(() {
                        zoneStates[index] = !zoneStates[index];
                      });
                      // Writes to a characteristic
                      int zoneState = boolToInt(zoneStates[index]);

                      zonesInHex = ((boolToInt(zoneStates[0])) +
                              (boolToInt(zoneStates[1]) * 2) +
                              (boolToInt(zoneStates[2]) * 4) +
                              (boolToInt(zoneStates[3]) * 8))
                          .toRadixString(16);

                      print(zonesInHex);

                      switch (index) {
                        case 0:
                          await characteristicMaestro.write(
                              '{\"light\": 1,$zoneState,\"1\"}'.codeUnits);
                          break;
                        case 1:
                          await characteristicMaestro.write(
                              '{\"light\": 1,$zoneState,\"2\"}'.codeUnits);
                          break;
                        case 2:
                          await characteristicMaestro.write(
                              '{\"light\": 1,$zoneState,\"4\"}'.codeUnits);
                          break;
                        case 3:
                          await characteristicMaestro.write(
                              '{\"light\": 1,$zoneState,\"8\"}'.codeUnits);
                          break;
                      }
                    },
                    children: [
                      Text('  Zone 1  '),
                      Text('  Zone 2  '),
                      Text('  Zone 3  '),
                      Text('  Zone 4  '),
                    ],
                    borderWidth: 2,
                    color: Colors.grey,
                    selectedBorderColor: Colors.black,
                    selectedColor: Colors.green,
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              HSLColorPicker(
                onChanged: (colorSelected) {
                  setState(() {
                    hslColor = colorSelected;
                    color = colorSelected.toColor();
                    characteristicMaestro.write(
                        '{\"hue\":${color.toString().split("0x")[1].toUpperCase().replaceFirst("FF", "").replaceAll(")", "")},\"zone\":\"$zonesInHex\"}'
                            .codeUnits);
                  });
                },
                size: 200,
                strokeWidth: 5,
                thumbSize: 9,
                thumbStrokeSize: 3,
                showCenterColorIndicator: true,
                centerColorIndicatorSize: 80,
                initialColor: Colors.blueAccent,
              ),
              SizedBox(
                height: 30,
              ),
              FlatButton.icon(
                  color: Colors.grey,
                  onPressed: () {
                    //settingsWidget(context);
                    normalWidget(context);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  icon: Icon(Icons.settings),
                  label: Text(
                    'Settings',
                    style: TextStyle(color: Colors.black),
                  )),
            ],
          ),
        ),
      ),
      onWillPop: () => showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('Attention'),
          content: Text('Voulez-vous rescanner votre qrcode ?'),
          actions: [
            FlatButton(
                child: Text('Oui'),
                onPressed: () async{
                  await myDevice.disconnect();
                  Navigator.pop(c, true);
                  Navigator.pushNamedAndRemoveUntil(
                      context, "/scan_ble_list", (r) => false);
                }),
            FlatButton(
              child: Text('Non'),
              onPressed: () => Navigator.pop(c, false),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> normalWidget(BuildContext context) {
    myBleDeviceName.text = myDevice.name;
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
        title: Text("My title"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'nom de HuBBox Maestro :',
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(
              height: 30,
            ),
            TextField(
              maxLines: 1,
              controller: myBleDeviceName,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[800],
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                focusColor: Colors.black,
                hintText: 'Enter a search term',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Retour',
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text(
              'Confirmer',
            ),
            onPressed: () {
              // write the new ble device name
              characteristicMaestro
                  .write('{\"dname\":\"${myBleDeviceName.text}\"}'.codeUnits);
            },
          ),
        ]);
    // show the dialog
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> settingsWidget(BuildContext context) {
    myBleDeviceName.text = myDevice.name;
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
              title: Text('Reglages'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'nom de HuBBox Maestro :',
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Expanded(
                    child: TextField(
                      maxLines: 1,
                      controller: myBleDeviceName,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[800],
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter a search term',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    'Retour',
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text(
                    'Confirmer',
                  ),
                  onPressed: () {
                    // write the new ble device name
                    characteristicMaestro.write(
                        '{\"dname\":\"${myBleDeviceName.text}\"}'.codeUnits);
                  },
                ),
              ]);
        });
      },
    );
  }
}
