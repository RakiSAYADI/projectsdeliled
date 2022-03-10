import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_dmx_maestro/services/DataVariables.dart';
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

  int boolToInt(bool a) => a == true ? 1 : 0;

  bool intToBool(int a) => a == 1 ? true : false;

  Color trackBarColor = Colors.black;

  String bottomBarTitle = 'Ambiances';
  String zonesInHexAmb;

  bool bottomBarTitleState = false;
  bool firstDisplayMainWidget = true;
  bool colorPickerSelected = false;

  double opacityLevelRemoteControl = 1.0;
  double opacityLevelAmbiances = 0.0;
  double _lowerValue = 50;

  List<String> ambiance1, ambiance2, ambiance3, ambiance4, ambiance5, ambiance6;
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
    print('home page');
    if (firstDisplayMainWidget) {
      try {
        var parsedJson;
        if (Platform.isIOS) {
          parsedJson = json.decode(dataMaestroIOS2);
          ambiance1 = List<String>.from(parsedJson['Amb1']);
          ambiance2 = List<String>.from(parsedJson['Amb2']);
          ambiance3 = List<String>.from(parsedJson['Amb3']);
          parsedJson = json.decode(dataMaestroIOS3);
          ambiance4 = List<String>.from(parsedJson['Amb4']);
          ambiance5 = List<String>.from(parsedJson['Amb5']);
          ambiance6 = List<String>.from(parsedJson['Amb6']);
          parsedJson = json.decode(dataMaestroIOS);
          zonesNamesList[0] = parsedJson['zone'][0];
          zonesNamesList[1] = parsedJson['zone'][1];
          zonesNamesList[2] = parsedJson['zone'][2];
          zonesNamesList[3] = parsedJson['zone'][3];
        }
        if (Platform.isAndroid) {
          parsedJson = json.decode(dataMaestro);
          ambiance1 = [parsedJson['Amb'][0].toString(), parsedJson['Amb'][1].toString(), parsedJson['Amb'][2].toString()];
          ambiance2 = [parsedJson['Amb'][3].toString(), parsedJson['Amb'][4].toString(), parsedJson['Amb'][5].toString()];
          ambiance3 = [parsedJson['Amb'][6].toString(), parsedJson['Amb'][7].toString(), parsedJson['Amb'][8].toString()];
          ambiance4 = [parsedJson['Amb'][9].toString(), parsedJson['Amb'][10].toString(), parsedJson['Amb'][11].toString()];
          ambiance5 = [parsedJson['Amb'][12].toString(), parsedJson['Amb'][13].toString(), parsedJson['Amb'][14].toString()];
          ambiance6 = [parsedJson['Amb'][15].toString(), parsedJson['Amb'][16].toString(), parsedJson['Amb'][17].toString()];
          zonesNamesList[0] = parsedJson['zone'][0];
          zonesNamesList[1] = parsedJson['zone'][1];
          zonesNamesList[2] = parsedJson['zone'][2];
          zonesNamesList[3] = parsedJson['zone'][3];
        }
      } catch (e) {
        print('erreur');
        ambiance1 = ['Ambiance 1', 'FF0000', 'F'];
        ambiance2 = ['Ambiance 2', '000000', 'F'];
        ambiance3 = ['Ambiance 3', '00FF00', 'F'];
        ambiance4 = ['Ambiance 4', '0000FF', 'F'];
        ambiance5 = ['Ambiance 5', 'FFFF00', 'F'];
        ambiance6 = ['Ambiance 6', '00FFFF', 'F'];
        zonesNamesList = ['Zone 1', 'Zone 2', 'Zone 3', 'Zone 4'];
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
                            Navigator.pushNamed(context, '/alarm_settings');
                          },
                        ),
                        VerticalDivider(
                          thickness: 1.0,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                    TextButton(
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
                        print(bottomBarTitle);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          bottomBarTitle,
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[200])),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        VerticalDivider(
                          thickness: 1.0,
                          color: Colors.grey[600],
                        ),
                        IconButton(
                          key: Key('settings_button'),
                          icon: Icon(Icons.settings),
                          onPressed: () {
                            Navigator.pushNamed(context, '/settings');
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
      onWillPop: () => showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('Attention'),
          content: Text('Êtes-vous sûr de vouloir revenir à la page de sélection des cartes Maestro™ ?'),
          actions: [
            TextButton(
                child: Text('Oui'),
                onPressed: () async {
                  await myDevice.disconnect();
                  Navigator.pop(c, true);
                  Navigator.pushNamedAndRemoveUntil(context, "/scan_ble_list", (r) => false);
                }),
            TextButton(
              child: Text('Non'),
              onPressed: () => Navigator.pop(c, false),
            ),
          ],
        ),
      ),
    );
  }

  Widget ambianceWidget(BuildContext context) {
    //double widthScreen = MediaQuery.of(context).size.width;
    //double heightScreen = MediaQuery.of(context).size.height;
    return Center(
      key: Key('ambiance_widget'),
      child: IntrinsicHeight(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Row(
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
            ),
            Expanded(
              flex: 2,
              child: Row(
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
            ),
            Expanded(
              flex: 2,
              child: Row(
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
                  child: IconButton(
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
                  child: IconButton(
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
          flex: 5,
          child: Stack(
            alignment: Alignment.center,
            children: [
              HSLColorPicker(
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
                size: widthScreen * 0.4 + heightScreen * 0.1,
                strokeWidth: widthScreen * 0.04,
                thumbSize: 0.00001,
                thumbStrokeSize: widthScreen * 0.005 + heightScreen * 0.005,
                showCenterColorIndicator: true,
                centerColorIndicatorSize: widthScreen * 0.005 + heightScreen * 0.005,
                initialColor: Colors.blue[900],
              ),
              bigCircle(widthScreen * 0.14, heightScreen * 0.1),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
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
                  if (_lowerValue > 50) {
                    trackBarColor = Colors.yellowAccent;
                  } else {
                    trackBarColor = Colors.blueAccent;
                  }
                  setState(() {});
                  if (myDevice.getConnectionState()) {
                    if (!bottomBarTitleState) {
                      characteristicMaestro.write('{\"light\":[8,${_lowerValue.toInt()},\"$zonesInHex\"]}'.codeUnits);
                    }
                  }
                },
                handler: FlutterSliderHandler(child: Icon(Icons.code)),
                trackBar: FlutterSliderTrackBar(activeTrackBar: BoxDecoration(color: trackBarColor), activeTrackBarHeight: 12, inactiveTrackBarHeight: 12),
                hatchMark: FlutterSliderHatchMark(
                  density: 0.5, // means 50 lines, from 0 to 100 percent
                  labels: [
                    FlutterSliderHatchMarkLabel(percent: 0, label: Icon(Icons.ac_unit, size: 30)),
                    FlutterSliderHatchMarkLabel(percent: 100, label: Icon(Icons.wb_sunny, size: 30)),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 16.0, 0),
                    child: IconButton(
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
                  TextButton(
                    onPressed: () async {
                      if (myDevice.getConnectionState()) {
                        if (!bottomBarTitleState) {
                          await characteristicMaestro.write('{\"light\":[4,2,\"$zonesInHex\"]}'.codeUnits);
                        }
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.all(widthScreen * 0.001 + heightScreen * 0.0001),
                      child: Text(
                        'Mode',
                        style: TextStyle(color: Colors.white, fontSize: widthScreen * 0.01 + heightScreen * 0.015),
                      ),
                    ),
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[400])),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                    child: IconButton(
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
                  Expanded(flex: 1, child: verticalDivider()),
                  Expanded(flex: 3, child: zoneOnOff(context, zonesNamesList[0], '1')),
                  Expanded(flex: 1, child: verticalDivider()),
                  Expanded(flex: 3, child: zoneOnOff(context, zonesNamesList[1], '2')),
                  Expanded(flex: 1, child: verticalDivider()),
                  Expanded(flex: 3, child: zoneOnOff(context, zonesNamesList[2], '4')),
                  Expanded(flex: 1, child: verticalDivider()),
                  Expanded(flex: 3, child: zoneOnOff(context, zonesNamesList[3], '8')),
                  Expanded(flex: 1, child: verticalDivider()),
                ],
              ),
            ),
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
    zonesInHexAmb = ambiance[2];
    zoneStates[0] = intToBool(int.parse(zonesInHexAmb, radix: 16) ~/ 8);
    zoneStates[1] = intToBool(int.parse(zonesInHexAmb, radix: 16) % 8 ~/ 4);
    zoneStates[2] = intToBool(int.parse(zonesInHexAmb, radix: 16) % 4 ~/ 2);
    zoneStates[3] = intToBool(int.parse(zonesInHexAmb, radix: 16) % 2);
    if (ambiance[1].length == 6 || ambiance[1].length == 7) color.write('ff');
    color.write(ambiance[1].replaceFirst('#', ''));
    ambianceNameEditor.text = ambiance[0];
    String colorHue = ambiance[1];
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Modifier l’ambiance'),
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
                    Text('Zone de votre ambiance:'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [zoneButton(context, 0), zoneButton(context, 1)],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [zoneButton(context, 2), zoneButton(context, 3)],
                    ),
                    Text('Couleur de votre ambiance:'),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: HSLColorPicker(
                        onChanged: (colorSelected) {
                          colorHue = colorSelected.toColor().toString().split("0x")[1].toUpperCase().replaceFirst("FF", "").replaceAll(")", "");
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
                TextButton(
                  child: Text(
                    'Sauvegarder',
                    style: TextStyle(color: Colors.green),
                  ),
                  onPressed: () async {
                    zonesInHexAmb = ((boolToInt(zoneStates[3])) + (boolToInt(zoneStates[2]) * 2) + (boolToInt(zoneStates[1]) * 4) + (boolToInt(zoneStates[0]) * 8)).toRadixString(16);
                    ambiance[0] = ambianceNameEditor.text;
                    ambiance[1] = colorHue;
                    ambiance[2] = zonesInHexAmb;
                    if (bottomBarTitleState) {
                      await characteristicMaestro.write('{\"couleur$ambianceID\":[${ambiance[0]},${ambiance[1]},${ambiance[2]}]}'.codeUnits);
                    }
                    switch (ambianceID) {
                      case 1:
                        ambiance1[0] = ambiance[0];
                        ambiance1[1] = ambiance[1];
                        ambiance1[2] = ambiance[2];
                        break;
                      case 2:
                        ambiance2[0] = ambiance[0];
                        ambiance2[1] = ambiance[1];
                        ambiance2[2] = ambiance[2];
                        break;
                      case 3:
                        ambiance3[0] = ambiance[0];
                        ambiance3[1] = ambiance[1];
                        ambiance3[2] = ambiance[2];
                        break;
                      case 4:
                        ambiance4[0] = ambiance[0];
                        ambiance4[1] = ambiance[1];
                        ambiance4[2] = ambiance[2];
                        break;
                      case 5:
                        ambiance5[0] = ambiance[0];
                        ambiance5[1] = ambiance[1];
                        ambiance5[2] = ambiance[2];
                        break;
                      case 6:
                        ambiance6[0] = ambiance[0];
                        ambiance6[1] = ambiance[1];
                        ambiance6[2] = ambiance[2];
                        break;
                    }
                    pageRefresh();
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
      },
    );
  }

  void pageRefresh() async {
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {});
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

  Widget zoneOnOff(BuildContext context, String zoneName, String zoneNumber) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blueAccent),
      ),
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
          Expanded(flex: 2, child: Center(child: Text(zoneName, style: TextStyle(fontSize: widthScreen * 0.02 + heightScreen * 0.009)))),
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
        if (myDevice.getConnectionState()) {
          if (bottomBarTitleState) {
            await characteristicMaestro.write('{\"Favoris\":\"Ambiance $ambianceID\"}'.codeUnits);
          }
        }
      },
      child: Container(
        width: widthScreen * 0.13,
        height: heightScreen * 0.1,
        decoration: new BoxDecoration(
          color: Color(int.parse(color.toString(), radix: 16)),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black, spreadRadius: 3),
          ],
        ),
      ),
    );
  }

  Widget verticalDivider() {
    return VerticalDivider(
      thickness: 1.0,
      color: Colors.white,
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
