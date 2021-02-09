import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:hsl_colorpicker/HSLColorPicker.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map bleDeviceData = {};

  BluetoothCharacteristic characteristicMaestro;
  BluetoothDevice myDevice;

  final String zonesInHex = 'F';

  final myBleDeviceName = TextEditingController();

  HSLColor hslColor = HSLColor.fromColor(Colors.blue);
  Color color = Colors.blue;

  int boolToInt(bool a) => a == true ? 1 : 0;

  double _lowerValue = 50;

  Color trackBarColor = Colors.black;

  @override
  void initState() {
    // TODO: implement initState
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    myBleDeviceName.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bleDeviceData = bleDeviceData.isNotEmpty ? bleDeviceData : ModalRoute.of(context).settings.arguments;
    myDevice = bleDeviceData['bleDevice'];
    characteristicMaestro = bleDeviceData['bleCharacteristic'];

    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;

    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: BottomAppBar(
          notchMargin: 10.0,
          color: Colors.grey[200],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(
                  thickness: 1.0,
                  color: Colors.grey[600],
                ),
              ),
              IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    VerticalDivider(
                      thickness: 1.0,
                      color: Colors.grey[600],
                    ),
                    IconButton(
                      icon: Icon(Icons.alarm),
                      onPressed: () {
                        Navigator.pushNamed(context, '/alarm_settings', arguments: {
                          'bleCharacteristic': characteristicMaestro,
                          'bleDevice': myDevice,
                        });
                      },
                    ),
                    VerticalDivider(
                      thickness: 1.0,
                      color: Colors.grey[600],
                    ),
                    Text(
                      'Télécommande',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    VerticalDivider(
                      thickness: 1.0,
                      color: Colors.grey[600],
                    ),
                    IconButton(
                      icon: Icon(Icons.settings),
                      onPressed: () {
                        Navigator.pushNamed(context, '/settings', arguments: {
                          'bleCharacteristic': characteristicMaestro,
                          'bleDevice': myDevice,
                        });
                      },
                    ),
                    VerticalDivider(
                      thickness: 1.0,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(
                  thickness: 1.0,
                  color: Colors.grey[600],
                ),
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                    child: IconButton(
                      icon: Icon(Icons.power_settings_new, color: Colors.green, size: widthScreen * 0.03 + heightScreen * 0.02),
                      onPressed: () async {
                        print('{\"light\": 1,1,\"F\"}');
                        await characteristicMaestro.write('{\"light\": 1,1,\"$zonesInHex\"}'.codeUnits);
                      },
                    ),
                  ),
                  SizedBox(
                    width: widthScreen * 0.1,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.red, size: widthScreen * 0.03 + heightScreen * 0.02),
                      onPressed: () async {
                        print('{\"light\": 1,0,\"F\"}');
                        await characteristicMaestro.write('{\"light\": 1,0,\"$zonesInHex\"}'.codeUnits);
                      },
                    ),
                  ),
                ],
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
                        characteristicMaestro.write(
                            '{\"hue\":${color.toString().split("0x")[1].toUpperCase().replaceFirst("FF", "").replaceAll(")", "")},\"zone\":\"$zonesInHex\"}'
                                .codeUnits);
                      });
                    },
                    size: widthScreen * 0.4 + heightScreen * 0.1,
                    strokeWidth: widthScreen * 0.1,
                    thumbSize: 0.00001,
                    thumbStrokeSize: widthScreen * 0.005 + heightScreen * 0.005,
                    showCenterColorIndicator: true,
                    centerColorIndicatorSize: widthScreen * 0.005 + heightScreen * 0.005,
                    initialColor: Colors.blue[900],
                  ),
                  bigCircle(widthScreen * 0.4, heightScreen * 0.15),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0,0,16.0,0),
                child: FlutterSlider(
                  values: [_lowerValue],
                  max: 100,
                  min: 0,
                  centeredOrigin: true,
                  handlerAnimation:
                      FlutterSliderHandlerAnimation(curve: Curves.elasticOut, reverseCurve: null, duration: Duration(milliseconds: 700), scale: 1.4),
                  onDragging: (handlerIndex, lowerValue, upperValue) {
                    _lowerValue = lowerValue;
                    if (_lowerValue > (100 - 0) / 2) {
                      trackBarColor = Colors.yellowAccent;
                    } else {
                      trackBarColor = Colors.blueAccent;
                    }
                    characteristicMaestro.write('{\"light\":[8,${_lowerValue.toInt()},\"$zonesInHex\"]}'.codeUnits);
                  },
                  handler: FlutterSliderHandler(child: Icon(Icons.code)),
                  trackBar: FlutterSliderTrackBar(activeTrackBar: BoxDecoration(color: trackBarColor),activeTrackBarHeight: 20,inactiveTrackBarHeight: 20),
                  hatchMark: FlutterSliderHatchMark(
                    density: 0.5, // means 50 lines, from 0 to 100 percent
                    labels: [
                      FlutterSliderHatchMarkLabel(percent: 0, label: Icon(Icons.ac_unit,size: 40)),
                      FlutterSliderHatchMarkLabel(percent: 100, label: Icon(Icons.wb_sunny,size: 40)),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.more_time, color: Colors.green, size: widthScreen * 0.025 + heightScreen * 0.015),
                    onPressed: () async {
                      print('{\"light\": 4,1,\"$zonesInHex\"}');
                      await characteristicMaestro.write('{\"light\": 4,1,\"$zonesInHex\"}'.codeUnits);
                    },
                  ),
                  FlatButton(
                    onPressed: () async {
                      print('{\"light\": 4,2,\"$zonesInHex\"}');
                      await characteristicMaestro.write('{\"light\": 4,2,\"$zonesInHex\"}'.codeUnits);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'Mode',
                        style: TextStyle(color: Colors.white, fontSize: widthScreen * 0.01 + heightScreen * 0.015),
                      ),
                    ),
                    color: Colors.blue[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.timelapse, color: Colors.red, size: widthScreen * 0.025 + heightScreen * 0.015),
                    onPressed: () async {
                      print('{\"light\": 4,0,\"$zonesInHex\"}');
                      await characteristicMaestro.write('{\"light\": 4,0,\"$zonesInHex\"}'.codeUnits);
                    },
                  ),
                ],
              ),
              IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    verticalDivider(),
                    zoneOnOff(context, 'Zone 1', '1'),
                    verticalDivider(),
                    zoneOnOff(context, 'Zone 2', '2'),
                    verticalDivider(),
                    zoneOnOff(context, 'Zone 3', '4'),
                    verticalDivider(),
                    zoneOnOff(context, 'Zone 4', '8'),
                    verticalDivider(),
                  ],
                ),
              ),
/*              IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    verticalDivider(),
                    zoneOnOff(context, 'Zone 5', '10'),
                    verticalDivider(),
                    zoneOnOff(context, 'Zone 6', '20'),
                    verticalDivider(),
                    zoneOnOff(context, 'Zone 7', '40'),
                    verticalDivider(),
                    zoneOnOff(context, 'Zone 8', '80'),
                    verticalDivider(),
                  ],
                ),
              ),*/
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
                  myDevice.disconnect();
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

  Widget verticalDivider() {
    return VerticalDivider(
      thickness: 1.0,
      color: Colors.grey[600],
    );
  }

  Widget zoneOnOff(BuildContext context, String zoneName, String zoneNumber) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.power_settings_new, color: Colors.green, size: widthScreen * 0.025 + heightScreen * 0.015),
          onPressed: () async {
            await characteristicMaestro.write('{\"light\": 1,1,\"$zoneNumber\"}'.codeUnits);
          },
        ),
        Text(zoneName, style: TextStyle(fontSize: widthScreen * 0.012 + heightScreen * 0.009)),
        IconButton(
          icon: Icon(Icons.close, color: Colors.red, size: widthScreen * 0.025 + heightScreen * 0.015),
          onPressed: () async {
            await characteristicMaestro.write('{\"light\": 1,0,\"$zoneNumber\"}'.codeUnits);
          },
        ),
      ],
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
