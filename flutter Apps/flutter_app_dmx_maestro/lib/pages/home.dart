import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_app_dmx_maestro/services/bleDeviceClass.dart';
import 'package:hsl_colorpicker/HSLColorPicker.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map bleDeviceData = {};

  //BluetoothCharacteristic characteristicMaestro;
  //BluetoothDevice myDevice;

  List<bool> zoneStates;
  String zonesInHex;

  final myBleDeviceName = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    zoneStates = [false, false, false, false];
    zonesInHex = ((boolToInt(zoneStates[0])) + (boolToInt(zoneStates[1]) * 2) + (boolToInt(zoneStates[2]) * 4) + (boolToInt(zoneStates[3]) * 8))
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
    // bleDeviceData = bleDeviceData.isNotEmpty ? bleDeviceData : ModalRoute.of(context).settings.arguments;
    // myDevice = bleDeviceData['bleDevice'];
    // characteristicMaestro = bleDeviceData['bleCharacteristic'];

    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;

    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: BottomAppBar(
          color: color,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.alarm),
                onPressed: () {
                  Navigator.pushNamed(context, '/alarm_settings');
                },
              ),
              Text(
                'Télécommande',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            ],
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red, size: 35),
                    onPressed: () {
                      print('{\"light\": 1,0,\"F\"}');
                    },
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  IconButton(
                    icon: Icon(Icons.power_settings_new, color: Colors.green, size: 35),
                    onPressed: () {
                      print('{\"light\": 1,1,\"F\"}');
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              ToggleButtons(
                borderRadius: BorderRadius.circular(18.0),
                isSelected: zoneStates,
                onPressed: (int index) async {
                  setState(() {
                    zoneStates[index] = !zoneStates[index];
                  });
                  // Writes to a characteristic
                  int zoneState = boolToInt(zoneStates[index]);

                  zonesInHex =
                      ((boolToInt(zoneStates[0])) + (boolToInt(zoneStates[1]) * 2) + (boolToInt(zoneStates[2]) * 4) + (boolToInt(zoneStates[3]) * 8))
                          .toRadixString(16);

                  print(zonesInHex);

                  switch (index) {
                    case 0:
                      print('{\"light\": 1,$zoneState,\"1\"}');
                      //await characteristicMaestro.write('{\"light\": 1,$zoneState,\"1\"}'.codeUnits);
                      break;
                    case 1:
                      print('{\"light\": 1,$zoneState,\"2\"}');
                      //await characteristicMaestro.write('{\"light\": 1,$zoneState,\"2\"}'.codeUnits);
                      break;
                    case 2:
                      print('{\"light\": 1,$zoneState,\"3\"}');
                      //await characteristicMaestro.write('{\"light\": 1,$zoneState,\"4\"}'.codeUnits);
                      break;
                    case 3:
                      print('{\"light\": 1,$zoneState,\"4\"}');
                      //await characteristicMaestro.write('{\"light\": 1,$zoneState,\"8\"}'.codeUnits);
                      break;
                  }
                },
                children: [
                  Text('  Zone 1  ', style: TextStyle(fontSize: widthScreen * 0.02 + heightScreen * 0.02)),
                  Text('  Zone 2  ', style: TextStyle(fontSize: widthScreen * 0.02 + heightScreen * 0.02)),
                  Text('  Zone 3  ', style: TextStyle(fontSize: widthScreen * 0.02 + heightScreen * 0.02)),
                  Text('  Zone 4  ', style: TextStyle(fontSize: widthScreen * 0.02 + heightScreen * 0.02)),
                ],
                borderWidth: 2,
                color: Colors.grey,
                selectedBorderColor: Colors.black,
                selectedColor: Colors.green,
              ),
              SizedBox(
                height: 30,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  HSLColorPicker(
                    onChanged: (colorSelected) {
                      setState(() {
                        hslColor = colorSelected;
                        color = colorSelected.toColor();
                        print(
                            '{\"hue\":${color.toString().split("0x")[1].toUpperCase().replaceFirst("FF", "").replaceAll(")", "")},\"zone\":\"$zonesInHex\"}');
                        //characteristicMaestro.write(
                        //   '{\"hue\":${color.toString().split("0x")[1].toUpperCase().replaceFirst("FF", "").replaceAll(")", "")},\"zone\":\"$zonesInHex\"}'
                        //      .codeUnits);
                      });
                    },
                    size: widthScreen * 0.3 + heightScreen * 0.2,
                    strokeWidth: 5,
                    thumbSize: 9,
                    thumbStrokeSize: 3,
                    showCenterColorIndicator: true,
                    centerColorIndicatorSize: 80,
                    initialColor: Colors.blueAccent,
                  ),
                 // bigCircle(200.0, 200.0),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.timelapse, color: Colors.red, size: 35),
                    onPressed: () {
                      print('{\"light\": 4,0,\"$zonesInHex\"}');
                    },
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  FlatButton(
                    onPressed: () async {
                      print('{\"light\": 4,2,\"$zonesInHex\"}');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'Modes',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                    color: Colors.blue[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  IconButton(
                    icon: Icon(Icons.more_time, color: Colors.green, size: 35),
                    onPressed: () {
                      print('{\"light\": 4,1,\"$zonesInHex\"}');
                    },
                  ),
                ],
              ),
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
                onPressed: () {
                  //myDevice.disconnect();
                  Navigator.pop(c, true);
                  Navigator.pushNamedAndRemoveUntil(context, "/scan_ble_list", (r) => false);
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

  Widget bigCircle(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: new BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}
