import 'dart:convert';

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
  BluetoothCharacteristic characteristicWifi;
  BluetoothDevice myDevice;

  final String zonesInHex = 'F';

  final myBleDeviceName = TextEditingController();

  HSLColor hslColor = HSLColor.fromColor(Colors.blue);

  int boolToInt(bool a) => a == true ? 1 : 0;

  double _lowerValue = 50;

  Color trackBarColor = Colors.black;

  String bottomBarTitle = 'Télécommande';
  bool bottomBarTitleState = false;

  bool firstDisplayMainWidget = true;

  double opacityLevelRemoteControl = 1.0;
  double opacityLevelAmbiances = 0.0;

  List<String> ambiance1, ambiance2, ambiance3, ambiance4, ambiance5, ambiance6;

  String dataMaestro;

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
    characteristicMaestro = bleDeviceData['characteristicMaestro'];
    characteristicWifi = bleDeviceData['characteristicWifi'];
    dataMaestro = bleDeviceData['dataMaestro'];

    if (firstDisplayMainWidget) {
      try {
        var parsedJson = json.decode(dataMaestro);
        ambiance1 = List<String>.from(parsedJson['Amb1']);
        ambiance2 = List<String>.from(parsedJson['Amb2']);
        ambiance3 = List<String>.from(parsedJson['Amb3']);
        ambiance4 = List<String>.from(parsedJson['Amb4']);
        ambiance5 = List<String>.from(parsedJson['Amb5']);
        ambiance6 = List<String>.from(parsedJson['Amb6']);
      } catch (e) {
        print('erreur');
        ambiance1 = ['Ambiance 1', 'FF0000'];
        ambiance2 = ['Ambiance 2', '000000'];
        ambiance3 = ['Ambiance 3', '00FF00'];
        ambiance4 = ['Ambiance 4', '0000FF'];
        ambiance5 = ['Ambiance 5', 'FFFF00'];
        ambiance6 = ['Ambiance 6', '00FFFF'];
      }
      firstDisplayMainWidget = false;
    }

    return WillPopScope(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        VerticalDivider(
                          thickness: 1.0,
                          color: Colors.grey[600],
                        ),
                        IconButton(
                          icon: Icon(Icons.alarm),
                          onPressed: () {
                            Navigator.pushNamed(context, '/alarm_settings', arguments: {
                              'characteristicMaestro': characteristicMaestro,
                              'characteristicWifi': characteristicWifi,
                              'dataMaestro': dataMaestro,
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
                    FlatButton(
                      onPressed: () {
                        setState(() {
                          if (bottomBarTitleState) {
                            bottomBarTitle = 'Télécommande';
                          } else {
                            bottomBarTitle = 'Ambiances';
                          }
                          bottomBarTitleState = !bottomBarTitleState;
                          opacityLevelAmbiances = opacityLevelAmbiances == 0 ? 1.0 : 0.0;
                          opacityLevelRemoteControl = opacityLevelRemoteControl == 0 ? 1.0 : 0.0;
                        });
                        print(bottomBarTitle);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          bottomBarTitle,
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      color: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        VerticalDivider(
                          thickness: 1.0,
                          color: Colors.grey[600],
                        ),
                        IconButton(
                          icon: Icon(Icons.settings),
                          onPressed: () {
                            Navigator.pushNamed(context, '/settings', arguments: {
                              'characteristicMaestro': characteristicMaestro,
                              'characteristicWifi': characteristicWifi,
                              'dataMaestro': dataMaestro,
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
          child: Stack(
            children: [
              AnimatedOpacity(
                duration: Duration(seconds: 10),
                curve: Curves.linear,
                opacity: opacityLevelRemoteControl,
                child: remoteControlWidget(context),
              ),
              AnimatedOpacity(
                duration: Duration(seconds: 10),
                curve: Curves.linear,
                opacity: opacityLevelAmbiances,
                child: ambianceWidget(context),
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

  Widget ambianceWidget(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Center(
      child: IntrinsicHeight(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                  child: ambianceDisplayWidget(context, ambiance1, 1),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                  child: ambianceDisplayWidget(context, ambiance2, 2),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                  child: ambianceDisplayWidget(context, ambiance3, 3),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                  child: ambianceDisplayWidget(context, ambiance4, 4),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                  child: ambianceDisplayWidget(context, ambiance5, 5),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                  child: ambianceDisplayWidget(context, ambiance6, 6),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget ambianceDisplayWidget(BuildContext context, List<String> ambiance, int ambianceID) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            ambiance[0],
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          IconButton(
            onPressed: () async {
              if (bottomBarTitleState) {
                ambianceSettingWidget(context, ambiance, ambianceID);
              }
            },
            icon: Icon(Icons.settings),
            color: Colors.blue[400],
          ),
          ambianceCircleDisplay(context, ambiance[1], ambianceID),
        ],
      ),
    );
  }

  Widget remoteControlWidget(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Column(
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
                  if (!bottomBarTitleState) {
                    await characteristicMaestro.write('{\"light\": 1,1,\"$zonesInHex\"}'.codeUnits);
                  }
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
                  if (!bottomBarTitleState) {
                    await characteristicMaestro.write('{\"light\": 1,0,\"$zonesInHex\"}'.codeUnits);
                  }
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
                hslColor = colorSelected;
                if (!bottomBarTitleState) {
                  characteristicMaestro.write(
                      '{\"hue\":${colorSelected.toColor().toString().split("0x")[1].toUpperCase().replaceFirst("FF", "").replaceAll(")", "")},\"zone\":\"$zonesInHex\"}'
                          .codeUnits);
                }
              },
              size: widthScreen * 0.4 + heightScreen * 0.1,
              strokeWidth: widthScreen * 0.04,
              thumbSize: 0.00001,
              thumbStrokeSize: widthScreen * 0.005 + heightScreen * 0.005,
              showCenterColorIndicator: true,
              centerColorIndicatorSize: widthScreen * 0.005 + heightScreen * 0.005,
              initialColor: Colors.blue[900],
            ),
            bigCircle(widthScreen * 0.2, heightScreen * 0.1),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
          child: FlutterSlider(
            values: [_lowerValue],
            max: 100,
            min: 0,
            centeredOrigin: true,
            disabled: bottomBarTitleState,
            handlerAnimation:
                FlutterSliderHandlerAnimation(curve: Curves.elasticOut, reverseCurve: null, duration: Duration(milliseconds: 700), scale: 1.4),
            onDragging: (handlerIndex, lowerValue, upperValue) {
              _lowerValue = lowerValue;
              if (_lowerValue > 50) {
                trackBarColor = Colors.yellowAccent;
              } else {
                trackBarColor = Colors.blueAccent;
              }
              setState(() {});
              if (!bottomBarTitleState) {
                characteristicMaestro.write('{\"light\":[8,${_lowerValue.toInt()},\"$zonesInHex\"]}'.codeUnits);
              }
            },
            handler: FlutterSliderHandler(child: Icon(Icons.code)),
            trackBar:
                FlutterSliderTrackBar(activeTrackBar: BoxDecoration(color: trackBarColor), activeTrackBarHeight: 12, inactiveTrackBarHeight: 12),
            hatchMark: FlutterSliderHatchMark(
              density: 0.5, // means 50 lines, from 0 to 100 percent
              labels: [
                FlutterSliderHatchMarkLabel(percent: 0, label: Icon(Icons.ac_unit, size: 30)),
                FlutterSliderHatchMarkLabel(percent: 100, label: Icon(Icons.wb_sunny, size: 30)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 16.0, 0),
                child: IconButton(
                  icon: Icon(Icons.more_time, color: Colors.green, size: widthScreen * 0.025 + heightScreen * 0.015),
                  onPressed: () async {
                    if (!bottomBarTitleState) {
                      await characteristicMaestro.write('{\"light\": 4,1,\"$zonesInHex\"}'.codeUnits);
                    }
                  },
                ),
              ),
              FlatButton(
                onPressed: () async {
                  if (!bottomBarTitleState) {
                    await characteristicMaestro.write('{\"light\": 4,2,\"$zonesInHex\"}'.codeUnits);
                  }
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                child: IconButton(
                  icon: Icon(Icons.timelapse, color: Colors.red, size: widthScreen * 0.025 + heightScreen * 0.015),
                  onPressed: () async {
                    if (!bottomBarTitleState) {
                      await characteristicMaestro.write('{\"light\": 4,0,\"$zonesInHex\"}'.codeUnits);
                    }
                  },
                ),
              ),
            ],
          ),
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
    );
  }

  Future<void> ambianceSettingWidget(BuildContext context, List<String> ambiance, int ambianceID) async {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final ambianceNameEditor = TextEditingController();
    final color = StringBuffer();
    if (ambiance[1].length == 6 || ambiance[1].length == 7) color.write('ff');
    color.write(ambiance[1].replaceFirst('#', ''));
    ambianceNameEditor.text = ambiance[0];
    String colorHue = ambiance[1];
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Changer votre Ambiance'),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Nom de votre ambiance:'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    maxLength: 10,
                    controller: ambianceNameEditor,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey[800],
                    ),
                    decoration: InputDecoration(
                        hintText: 'exp:amb123',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        )),
                  ),
                ),
                Text('Couleur de votre ambiance:'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: HSLColorPicker(
                    onChanged: (colorSelected) {
                      hslColor = colorSelected;
                      colorHue = colorSelected.toColor().toString().split("0x")[1].toUpperCase().replaceFirst("FF", "").replaceAll(")", "");
                      print(colorHue);
                    },
                    size: screenWidth * 0.4 + screenHeight * 0.1,
                    strokeWidth: screenWidth * 0.04,
                    thumbSize: 0.00001,
                    thumbStrokeSize: screenWidth * 0.005 + screenHeight * 0.005,
                    showCenterColorIndicator: true,
                    centerColorIndicatorSize: screenWidth * 0.05 + screenHeight * 0.05,
                    initialColor: Color(int.parse(color.toString(), radix: 16)),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Sauvgarder',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () async {
                setState(() {
                  ambiance[0] = ambianceNameEditor.text;
                  ambiance[1] = colorHue;
                });
                if (bottomBarTitleState) {
                  await characteristicMaestro.write('{\"couleur$ambianceID\":[${ambiance[0]},${ambiance[1]}]}'.codeUnits);
                }
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

  Widget zoneOnOff(BuildContext context, String zoneName, String zoneNumber) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.power_settings_new, color: Colors.green, size: widthScreen * 0.025 + heightScreen * 0.015),
          onPressed: () async {
            if (!bottomBarTitleState) {
              await characteristicMaestro.write('{\"light\": 1,1,\"$zoneNumber\"}'.codeUnits);
            }
          },
        ),
        Text(zoneName, style: TextStyle(fontSize: widthScreen * 0.012 + heightScreen * 0.009)),
        IconButton(
          icon: Icon(Icons.close, color: Colors.red, size: widthScreen * 0.025 + heightScreen * 0.015),
          onPressed: () async {
            if (!bottomBarTitleState) {
              await characteristicMaestro.write('{\"light\": 1,0,\"$zoneNumber\"}'.codeUnits);
            }
          },
        ),
      ],
    );
  }

  Widget ambianceCircleDisplay(BuildContext context, String ambianceColor, int ambianceID) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    final color = StringBuffer();
    if (ambianceColor.length == 6 || ambianceColor.length == 7) color.write('ff');
    color.write(ambianceColor.replaceFirst('#', ''));
    return GestureDetector(
      onTap: () async {
        if (bottomBarTitleState) {
          await characteristicMaestro.write('{\"Favoris\":\"Ambiance $ambianceID\"}'.codeUnits);
        }
      },
      child: Container(
        width: widthScreen * 0.15,
        height: heightScreen * 0.15,
        decoration: new BoxDecoration(
          color: Color(int.parse(color.toString(), radix: 16)),
          shape: BoxShape.circle,
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
