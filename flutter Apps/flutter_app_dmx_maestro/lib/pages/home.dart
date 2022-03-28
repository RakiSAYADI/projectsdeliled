import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_dmx_maestro/services/DataVariables.dart';
import 'package:flutter_app_dmx_maestro/services/custom_container.dart';
import 'package:flutter_app_dmx_maestro/services/elavated_button.dart';
import 'package:flutter_app_dmx_maestro/services/icon_button.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:hsl_colorpicker/HSLColorPicker.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final String zonesInHex = 'F';
  final double hueCoefficient = (256 / 360);

  HSLColor hslColor = HSLColor.fromColor(Colors.blue);

  String bottomBarTitle = 'Ambiances';
  String zonesInHexAmb;

  bool bottomBarTitleState = false;
  bool colorPickerSelected = false;

  double opacityLevelRemoteControl = 1.0;
  double opacityLevelAmbiances = 0.0;
  double _lowerValue = 50;

  List<dynamic> ambiance1, ambiance2, ambiance3, ambiance4, ambiance5, ambiance6;
  List<bool> remoteAndAmbVisibility = [true, false];
  List<String> zonesNamesList = ['', '', '', ''];
  List<bool> zoneStates;

  @override
  void initState() {
    // TODO: implement initState
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    zoneStates = [false, false, false, false];
    zonesInHexAmb = '0';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('home page');
    try {
      var parsedJson;
      if (Platform.isIOS) {
        parsedJson = json.decode(dataMaestroIOS2);
        ambiance1 = List<dynamic>.from(parsedJson['Amb1']);
        ambiance2 = List<dynamic>.from(parsedJson['Amb2']);
        parsedJson = json.decode(dataMaestroIOS3);
        ambiance3 = List<dynamic>.from(parsedJson['Amb3']);
        ambiance4 = List<dynamic>.from(parsedJson['Amb4']);
        parsedJson = json.decode(dataMaestroIOS4);
        ambiance5 = List<dynamic>.from(parsedJson['Amb5']);
        ambiance6 = List<dynamic>.from(parsedJson['Amb6']);
        parsedJson = json.decode(dataMaestroIOS);
        zonesNamesList[0] = parsedJson['zone'][0];
        zonesNamesList[1] = parsedJson['zone'][1];
        zonesNamesList[2] = parsedJson['zone'][2];
        zonesNamesList[3] = parsedJson['zone'][3];
      }
      if (Platform.isAndroid) {
        parsedJson = json.decode(dataMaestro2);
        ambiance1 = [
          parsedJson['Amb'][0].toString(),
          parsedJson['Amb'][1],
          parsedJson['Amb'][2].toString(),
          parsedJson['Amb'][3],
          parsedJson['Amb'][4].toString(),
          parsedJson['Amb'][5],
          parsedJson['Amb'][6].toString(),
          parsedJson['Amb'][7],
          parsedJson['Amb'][8].toString()
        ];
        ambiance2 = [
          parsedJson['Amb'][9].toString(),
          parsedJson['Amb'][10],
          parsedJson['Amb'][11].toString(),
          parsedJson['Amb'][12],
          parsedJson['Amb'][13].toString(),
          parsedJson['Amb'][14],
          parsedJson['Amb'][15].toString(),
          parsedJson['Amb'][16],
          parsedJson['Amb'][17].toString()
        ];
        ambiance3 = [
          parsedJson['Amb'][18].toString(),
          parsedJson['Amb'][19],
          parsedJson['Amb'][20].toString(),
          parsedJson['Amb'][21],
          parsedJson['Amb'][22].toString(),
          parsedJson['Amb'][23],
          parsedJson['Amb'][24].toString(),
          parsedJson['Amb'][25],
          parsedJson['Amb'][26].toString()
        ];
        ambiance4 = [
          parsedJson['Amb'][27].toString(),
          parsedJson['Amb'][28],
          parsedJson['Amb'][29].toString(),
          parsedJson['Amb'][30],
          parsedJson['Amb'][31].toString(),
          parsedJson['Amb'][32],
          parsedJson['Amb'][33].toString(),
          parsedJson['Amb'][34],
          parsedJson['Amb'][35].toString()
        ];
        ambiance5 = [
          parsedJson['Amb'][36].toString(),
          parsedJson['Amb'][37],
          parsedJson['Amb'][38].toString(),
          parsedJson['Amb'][39],
          parsedJson['Amb'][40].toString(),
          parsedJson['Amb'][41],
          parsedJson['Amb'][42].toString(),
          parsedJson['Amb'][43],
          parsedJson['Amb'][44].toString()
        ];
        ambiance6 = [
          parsedJson['Amb'][45].toString(),
          parsedJson['Amb'][46],
          parsedJson['Amb'][47].toString(),
          parsedJson['Amb'][48],
          parsedJson['Amb'][49].toString(),
          parsedJson['Amb'][50],
          parsedJson['Amb'][51].toString(),
          parsedJson['Amb'][52],
          parsedJson['Amb'][53].toString()
        ];
        parsedJson = json.decode(dataMaestro);
        zonesNamesList[0] = parsedJson['zone'][0];
        zonesNamesList[1] = parsedJson['zone'][1];
        zonesNamesList[2] = parsedJson['zone'][2];
        zonesNamesList[3] = parsedJson['zone'][3];
      }
    } catch (e) {
      debugPrint(e.toString());
      debugPrint('erreur');
      ambiance1 = ['Ambiance 1', true, 'FF0000', true, 'FF0000', true, 'FF0000', true, 'FF0000'];
      ambiance2 = ['Ambiance 2', true, '000000', true, '000000', true, '000000', true, '000000'];
      ambiance3 = ['Ambiance 3', true, '00FF00', true, '00FF00', true, '00FF00', true, '00FF00'];
      ambiance4 = ['Ambiance 4', true, '0000FF', true, '0000FF', true, '0000FF', true, '0000FF'];
      ambiance5 = ['Ambiance 5', true, 'FFFF00', true, 'FFFF00', true, 'FFFF00', true, 'FFFF00'];
      ambiance6 = ['Ambiance 6', true, '00FFFF', true, '00FFFF', true, '00FFFF', true, '00FFFF'];
      zonesNamesList = ['Zone 1', 'Zone 2', 'Zone 3', 'Zone 4'];
    }

    return WillPopScope(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: backGroundColor[backGroundColorSelect],
        bottomNavigationBar: BottomAppBar(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: MyIconButton(
                    iconColor: textColor[backGroundColorSelect],
                    icon: Icon(Icons.alarm),
                    onPressed: () {
                      Navigator.pushNamed(context, '/alarm_settings', arguments: {
                        'ambiance1list': ambiance1,
                        'ambiance2list': ambiance2,
                        'ambiance3list': ambiance3,
                        'ambiance4list': ambiance4,
                        'ambiance5list': ambiance5,
                        'ambiance6list': ambiance6,
                      }).then((_) => setState(() {}));
                    },
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: MyElevatedButton(
                    key: Key('bottom_bar_title'),
                    onPressed: () {
                      setState(() {
                        if (bottomBarTitleState) {
                          bottomBarTitle = 'Ambiances';
                        } else {
                          bottomBarTitle = 'Télécommande';
                        }
                        bottomBarTitleState = !bottomBarTitleState;
                        opacityLevelAmbiances = opacityLevelAmbiances == 0 ? 1.0 : 0.0;
                        opacityLevelRemoteControl = opacityLevelRemoteControl == 0 ? 1.0 : 0.0;
                        remoteAndAmbVisibility[0] = !remoteAndAmbVisibility[0];
                        remoteAndAmbVisibility[1] = !remoteAndAmbVisibility[1];
                      });
                      debugPrint(bottomBarTitle);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        bottomBarTitle,
                        style: TextStyle(color: textColor[backGroundColorSelect], fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: MyIconButton(
                    key: Key('settings_button'),
                    iconColor: textColor[backGroundColorSelect],
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      Navigator.pushNamed(context, '/settings').then((_) => setState(() {}));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Center(
          child: Stack(
            children: [
              AnimatedOpacity(
                duration: Duration(seconds: 1),
                curve: Curves.linear,
                opacity: opacityLevelRemoteControl,
                child: Visibility(visible: remoteAndAmbVisibility[0], child: remoteControlWidget(context)),
              ),
              AnimatedOpacity(
                duration: Duration(seconds: 1),
                curve: Curves.linear,
                opacity: opacityLevelAmbiances,
                child: Visibility(visible: remoteAndAmbVisibility[1], child: ambianceWidget(context)),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () =>
          displayAlert(context, 'Attention', Text('Êtes-vous sûr de vouloir revenir à la page de sélection des cartes Maestro™ ?', style: TextStyle(color: textColor[backGroundColorSelect])), [
        TextButton(
            child: Text(
              'Oui',
              style: TextStyle(color: positiveButton[backGroundColorSelect]),
            ),
            onPressed: () async {
              await myDevice.disconnect();
              Navigator.pop(context, true);
              Navigator.pushNamedAndRemoveUntil(context, "/scan_ble_list", (r) => false);
            }),
        TextButton(
          child: Text(
            'Non',
            style: TextStyle(color: negativeButton[backGroundColorSelect]),
          ),
          onPressed: () => Navigator.pop(context, false),
        ),
      ]),
    );
  }

  Widget ambianceWidget(BuildContext context) {
    //double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Center(
      key: Key('ambiance_widget'),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(flex: 2, child: ambianceDisplayWidget(context, ambiance1, 1)),
                  Expanded(flex: 2, child: ambianceDisplayWidget(context, ambiance3, 3)),
                  Expanded(flex: 2, child: ambianceDisplayWidget(context, ambiance5, 5)),
                  Expanded(flex: 1, child: SizedBox(height: heightScreen * 0.1)),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(flex: 1, child: SizedBox(height: heightScreen * 0.1)),
                  Expanded(flex: 2, child: ambianceDisplayWidget(context, ambiance2, 2)),
                  Expanded(flex: 2, child: ambianceDisplayWidget(context, ambiance4, 4)),
                  Expanded(flex: 2, child: ambianceDisplayWidget(context, ambiance6, 6)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget ambianceDisplayWidget(BuildContext context, List<dynamic> ambiance, int ambianceID) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MyCustomContainer(
        shape: BoxShape.rectangle,
        radius: 20,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () async {
                  if (myDevice.getConnectionState()) {
                    if (bottomBarTitleState) {
                      await characteristicMaestro.write('{\"Favoris\":\"Ambiance $ambianceID\"}'.codeUnits);
                    }
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          ambiance[0],
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: widthScreen * 0.01 + heightScreen * 0.015, color: textColor[backGroundColorSelect]),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ambianceCircleDisplay(context, ambiance, ambianceID),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: () async {
                    if (bottomBarTitleState) {
                      Navigator.pushNamed(context, '/ambiances_settings', arguments: {'ambianceID': ambianceID, 'ambiance': ambiance, 'zoneNames': zonesNamesList}).then((_) => setState(() {}));
                    }
                  },
                  icon: Icon(Icons.settings, color: textColor[backGroundColorSelect]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget remoteControlWidget(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Column(
      key: Key('remote_control_widget'),
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                  child: MyIconButton(
                    icon: Icon(Icons.power_settings_new, color: Colors.green, size: widthScreen * 0.03 + heightScreen * 0.02),
                    onPressed: () async {
                      if (myDevice.getConnectionState()) {
                        if (!bottomBarTitleState) {
                          await characteristicMaestro.write('{\"light\":[1,0,\"$zonesInHex\"]}'.codeUnits);
                        }
                      }
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                  child: MyIconButton(
                    shape: BoxShape.circle,
                    icon: Icon(Icons.close, color: Colors.red, size: widthScreen * 0.03 + heightScreen * 0.02),
                    onPressed: () async {
                      if (myDevice.getConnectionState()) {
                        if (!bottomBarTitleState) {
                          await characteristicMaestro.write('{\"light\":[1,1,\"$zonesInHex\"]}'.codeUnits);
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 6,
          child: MyCustomContainer(
            child: HSLColorPicker(
              onChanged: (colorSelected) {
                if (myDevice.getConnectionState()) {
                  if (!bottomBarTitleState) {
                    if (colorPickerSelected) {
                      if (hslColor.lightness != colorSelected.lightness) {
                        characteristicMaestro.write('{\"light\":[7,${(hslColor.lightness * 100).toInt()},\"$zonesInHex\"]}'.codeUnits);
                      }
                      if (hslColor.hue != colorSelected.hue) {
                        characteristicMaestro.write('{\"light\":[3,${(hslColor.hue * hueCoefficient).toInt()},\"$zonesInHex\"]}'.codeUnits);
                      }
                      if (hslColor.saturation != colorSelected.saturation) {
                        characteristicMaestro.write('{\"light\":[9,${(hslColor.saturation * 100).toInt()},\"$zonesInHex\"]}'.codeUnits);
                      }
                    } else {
                      colorPickerSelected = true;
                      characteristicMaestro
                          .write('{\"hue\":${hslColor.toColor().toString().split("0x")[1].toUpperCase().replaceFirst("FF", "").replaceAll(")", "")},\"zone\":\"$zonesInHex\"}'.codeUnits);
                    }
                    hslColor = colorSelected;
                  }
                }
              },
              size: widthScreen * 0.45 + heightScreen * 0.15,
              strokeWidth: widthScreen * 0.045,
              thumbStrokeSize: widthScreen * 0.005 + heightScreen * 0.005,
              showCenterColorIndicator: false,
              centerColorIndicatorSize: widthScreen * 0.005 + heightScreen * 0.005,
              initialColor: Colors.blue[900],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(flex: 1, child: Icon(Icons.wb_sunny, size: widthScreen * 0.03 + heightScreen * 0.02, color: textColor[backGroundColorSelect])),
                Expanded(
                  flex: 8,
                  child: Center(
                    child: FlutterSlider(
                      tooltip: FlutterSliderTooltip(disabled: true),
                      values: [_lowerValue],
                      max: 100,
                      min: 0,
                      centeredOrigin: true,
                      disabled: bottomBarTitleState,
                      handlerAnimation: FlutterSliderHandlerAnimation(curve: Curves.elasticOut, reverseCurve: null, duration: Duration(milliseconds: 700), scale: 1.4),
                      onDragging: (handlerIndex, lowerValue, upperValue) {
                        _lowerValue = lowerValue;
                        setState(() {});
                        if (Platform.isAndroid) {
                          if (myDevice.getConnectionState()) {
                            if (!bottomBarTitleState) {
                              characteristicMaestro.write('{\"light\":[8,${100 - _lowerValue.toInt()},\"$zonesInHex\"]}'.codeUnits);
                            }
                          }
                        }
                      },
                      onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                        _lowerValue = lowerValue;
                        setState(() {});
                        if (Platform.isIOS) {
                          if (myDevice.getConnectionState()) {
                            if (!bottomBarTitleState) {
                              characteristicMaestro.write('{\"light\":[8,${100 - _lowerValue.toInt()},\"$zonesInHex\"]}'.codeUnits);
                            }
                          }
                        }
                      },
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFFFFF99A), Color(0xFF8FB5FF)],
                        ),
                      ),
                      handler: FlutterSliderHandler(child: MyCustomContainer(child: null)),
                      trackBar: FlutterSliderTrackBar(
                        inactiveTrackBar: BoxDecoration(color: Colors.transparent),
                        activeTrackBar: BoxDecoration(color: Colors.transparent),
                        activeTrackBarHeight: heightScreen * 0.001,
                        inactiveTrackBarHeight: heightScreen * 0.001,
                      ),
                    ),
                  ),
                ),
                Expanded(flex: 1, child: Icon(Icons.ac_unit, size: widthScreen * 0.03 + heightScreen * 0.02, color: textColor[backGroundColorSelect])),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 16.0, 0),
                    child: MyIconButton(
                      icon: Icon(Icons.more_time, color: Colors.green, size: widthScreen * 0.025 + heightScreen * 0.015),
                      onPressed: () async {
                        if (myDevice.getConnectionState()) {
                          if (!bottomBarTitleState) {
                            await characteristicMaestro.write('{\"light\":[4,1,\"$zonesInHex\"]}'.codeUnits);
                          }
                        }
                      },
                    ),
                  ),
                  MyElevatedButton(
                    onPressed: () async {
                      if (myDevice.getConnectionState()) {
                        if (!bottomBarTitleState) {
                          await characteristicMaestro.write('{\"light\":[4,2,\"$zonesInHex\"]}'.codeUnits);
                        }
                      }
                    },
                    child: Text('Mode', style: TextStyle(color: textColor[backGroundColorSelect])),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                    child: MyIconButton(
                      icon: Icon(Icons.timelapse, color: Colors.red, size: widthScreen * 0.025 + heightScreen * 0.015),
                      onPressed: () async {
                        if (myDevice.getConnectionState()) {
                          if (!bottomBarTitleState) {
                            await characteristicMaestro.write('{\"light\":[4,0,\"$zonesInHex\"]}'.codeUnits);
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Center(
            child: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(flex: 3, child: zoneOnOff(context, zonesNamesList[0], '1', 1)),
                  Expanded(flex: 3, child: zoneOnOff(context, zonesNamesList[1], '2', 2)),
                  Expanded(flex: 3, child: zoneOnOff(context, zonesNamesList[2], '4', 3)),
                  Expanded(flex: 3, child: zoneOnOff(context, zonesNamesList[3], '8', 4)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget zoneButton(BuildContext context, int zoneID) {
    Color zoneState;
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    final Color selected = Colors.green;
    final Color notSelected = Colors.red;
    if (zoneStates[zoneID]) {
      zoneState = selected;
    } else {
      zoneState = notSelected;
    }
    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            onPressed: () {
              zoneStates[zoneID] = !zoneStates[zoneID];
              setState(() {
                if (zoneStates[zoneID]) {
                  zoneState = selected;
                } else {
                  zoneState = notSelected;
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                zonesNamesList[zoneID],
                style: TextStyle(color: Colors.white, fontSize: widthScreen * 0.01 + heightScreen * 0.015),
              ),
            ),
            style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
                backgroundColor: MaterialStateProperty.all<Color>(zoneState)),
          ),
        );
      },
    );
  }

  Widget zoneOnOff(BuildContext context, String zoneName, String zoneNumber, int zoneID) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17.0, vertical: 3.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              flex: 1,
              child: Center(child: Text(zoneName, textAlign: TextAlign.center, style: TextStyle(fontSize: widthScreen * 0.02 + heightScreen * 0.009, color: textColor[backGroundColorSelect])))),
          Expanded(
            flex: 4,
            child: MyCustomContainer(
              shape: BoxShape.rectangle,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: IconButton(
                        icon: Icon(Icons.power_settings_new, color: Colors.green, size: widthScreen * 0.025 + heightScreen * 0.015),
                        onPressed: () async {
                          if (myDevice.getConnectionState()) {
                            if (!bottomBarTitleState) {
                              await characteristicMaestro.write('{\"light\":[1,0,\"$zoneNumber\"]}'.codeUnits);
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        '$zoneID',
                        style: TextStyle(
                          fontSize: widthScreen * 0.03 + heightScreen * 0.01,
                          color: textColor[backGroundColorSelect],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.red, size: widthScreen * 0.025 + heightScreen * 0.015),
                        onPressed: () async {
                          if (myDevice.getConnectionState()) {
                            if (!bottomBarTitleState) {
                              await characteristicMaestro.write('{\"light\":[1,1,\"$zoneNumber\"]}'.codeUnits);
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget ambianceCircleDisplay(BuildContext context, List<dynamic> ambianceColors, int ambianceID) {
    final colorZone1 = getColors(ambianceColors[2].toString());
    final colorZone2 = getColors(ambianceColors[4].toString());
    final colorZone3 = getColors(ambianceColors[6].toString());
    final colorZone4 = getColors(ambianceColors[8].toString());
    return GestureDetector(
      onTap: () async {
        if (myDevice.getConnectionState()) {
          if (bottomBarTitleState) {
            await characteristicMaestro.write('{\"Favoris\":\"Ambiance $ambianceID\"}'.codeUnits);
          }
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ambianceZoneColor(context, Color(int.parse(colorZone1.toString(), radix: 16)), intToBool(ambianceColors[1])),
          ambianceZoneColor(context, Color(int.parse(colorZone2.toString(), radix: 16)), intToBool(ambianceColors[3])),
          ambianceZoneColor(context, Color(int.parse(colorZone3.toString(), radix: 16)), intToBool(ambianceColors[5])),
          ambianceZoneColor(context, Color(int.parse(colorZone4.toString(), radix: 16)), intToBool(ambianceColors[7])),
        ],
      ),
    );
  }

  Widget ambianceZoneColor(BuildContext context, Color zoneColor, bool zoneState) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    if (!zoneState) {
      zoneColor = Colors.black;
    }
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        width: widthScreen * 0.06,
        height: heightScreen * 0.06,
        decoration: BoxDecoration(shape: BoxShape.circle, color: zoneColor),
      ),
    );
  }
}
