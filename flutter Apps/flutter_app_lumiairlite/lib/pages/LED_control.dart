import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_bispectrum/services/DataVariables.dart';
import 'package:flutter_app_bispectrum/services/languageDataBase.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:get/get.dart';

class LEDPage extends StatefulWidget {
  @override
  _LEDPageState createState() => _LEDPageState();
}

class _LEDPageState extends State<LEDPage> {
  bool firstDisplayMainWidget = true;

  List<bool> zoneStates = [false, false, false, false];
  List<String> zonesNamesList = ['', '', '', ''];

  String zonesInHex = '0';
  String colorHue;

  Color lumMaxColor = Colors.white;
  Color stabMaxColor = Colors.transparent;
  Color stabMinColor = Colors.white;

  double hueValue = 0;
  double lumValue = 50;
  double satValue = 50;
  double whiteValue = 50;

  bool ccSwitchValue = false;

  int ccSwitchCounter = 0;

  void readDataMaestro() async {
    var parsedJson;
    try {
      if (Platform.isAndroid) {
        parsedJson = json.decode(dataCharAndroid2);
      }
      if (Platform.isIOS) {
        parsedJson = json.decode(dataCharIOS2p2);
      }
      zonesNamesList[0] = parsedJson['ZN'][0];
      zonesNamesList[1] = parsedJson['ZN'][1];
      zonesNamesList[2] = parsedJson['ZN'][2];
      zonesNamesList[3] = parsedJson['ZN'][3];
      ccSwitchValue = intToBool(int.parse(parsedJson['cc'][0].toString()));
      await Future.delayed(Duration(seconds: 2));
    } catch (e) {
      print('erreur zone');
      zonesNamesList = [
        firstZoneTextLanguageArray[languageArrayIdentifier],
        secondZoneTextLanguageArray[languageArrayIdentifier],
        thirdZoneTextLanguageArray[languageArrayIdentifier],
        fourthZoneTextLanguageArray[languageArrayIdentifier]
      ];
    }
  }

  void setBarreColorsState() {
    lumMaxColor = HSLColor.fromColor(Colors.black).withHue((hueValue * 360) / 256).withLightness(0.5).withSaturation(1.0).toColor();
    stabMaxColor = HSLColor.fromColor(Colors.black).withHue((hueValue * 360) / 256).withLightness(0.5).withSaturation(1.0).toColor();
    stabMinColor = HSLColor.fromColor(Colors.black).withHue((hueValue * 360) / 256).withLightness(0.5).withSaturation(0.0).toColor();
  }

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    if (firstDisplayMainWidget) {
      readDataMaestro();
      firstDisplayMainWidget = false;
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: WillPopScope(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background-bispectrum.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 10, 16.0, 10),
                    child: Container(
                      padding: EdgeInsets.zero,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        border: Border.all(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(18.0)),
                      ),
                      child: ToggleButtons(
                        borderRadius: BorderRadius.circular(18.0),
                        isSelected: zoneStates,
                        onPressed: (int index) async {
                          zoneStates[index] = !zoneStates[index];
                          setState(() {});
                          zonesInHex = ((boolToInt(zoneStates[0])) + (boolToInt(zoneStates[1]) * 2) + (boolToInt(zoneStates[2]) * 4) + (boolToInt(zoneStates[3]) * 8)).toRadixString(16);
                          if (myDevice.getConnectionState()) {
                            switch (index) {
                              case 0:
                                characteristicSensors.write('{\"light\":[1,${boolToInt(!zoneStates[index])},\"1\"]}'.codeUnits);
                                break;
                              case 1:
                                characteristicSensors.write('{\"light\":[1,${boolToInt(!zoneStates[index])},\"2\"]}'.codeUnits);
                                break;
                              case 2:
                                characteristicSensors.write('{\"light\":[1,${boolToInt(!zoneStates[index])},\"4\"]}'.codeUnits);
                                break;
                              case 3:
                                characteristicSensors.write('{\"light\":[1,${boolToInt(!zoneStates[index])},\"8\"]}'.codeUnits);
                                break;
                            }
                          }
                        },
                        children: [
                          Container(
                              width: (widthScreen - 80) / 4,
                              height: (heightScreen - 80) / 4,
                              child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[new SizedBox(width: 4.0), new Text(zonesNamesList[0], style: TextStyle(fontSize: widthScreen * 0.025), textAlign: TextAlign.center)])),
                          Container(
                              width: (widthScreen - 80) / 4,
                              height: (heightScreen - 80) / 4,
                              child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[new SizedBox(width: 4.0), new Text(zonesNamesList[1], style: TextStyle(fontSize: widthScreen * 0.025), textAlign: TextAlign.center)])),
                          Container(
                              width: (widthScreen - 80) / 4,
                              height: (heightScreen - 80) / 4,
                              child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[new SizedBox(width: 4.0), new Text(zonesNamesList[2], style: TextStyle(fontSize: widthScreen * 0.025), textAlign: TextAlign.center)])),
                          Container(
                              width: (widthScreen - 80) / 4,
                              height: (heightScreen - 80) / 4,
                              child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[new SizedBox(width: 4.0), new Text(zonesNamesList[3], style: TextStyle(fontSize: widthScreen * 0.025), textAlign: TextAlign.center)])),
                        ],
                        borderWidth: 2,
                        selectedColor: Colors.white,
                        selectedBorderColor: Colors.black,
                        fillColor: Colors.green,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 15, 16.0, 15),
                    child: FlutterSlider(
                      tooltip: FlutterSliderTooltip(disabled: true),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.0),
                        gradient: LinearGradient(
                          colors: [
                            Colors.purpleAccent[400],
                            Colors.red,
                            Colors.yellow,
                            Colors.green,
                            Colors.lightBlue[200],
                            Colors.lightBlue,
                            Colors.blue,
                            Colors.purple[300],
                            Colors.purple,
                            Colors.purpleAccent[400],
                          ],
                        ),
                      ),
                      values: [hueValue],
                      max: 255,
                      min: 0,
                      onDragging: (handlerIndex, lowerValue, upperValue) {
                        if (ccSwitchValue && ccSwitchCounter == 0) {
                          displayCCWarning();
                          ccSwitchCounter++;
                        } else if (Platform.isAndroid) {
                          hueValue = lowerValue;
                          setBarreColorsState();
                          setState(() {});
                          if (myDevice.getConnectionState()) {
                            characteristicSensors.write('{\"light\":[3,${hueValue.toInt()},\"$zonesInHex\"]}'.codeUnits);
                          }
                        }
                      },
                      onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                        if (ccSwitchValue && ccSwitchCounter == 0) {
                          displayCCWarning();
                          ccSwitchCounter++;
                        } else if (Platform.isIOS) {
                          hueValue = lowerValue;
                          setBarreColorsState();
                          setState(() {});
                          if (myDevice.getConnectionState()) {
                            characteristicSensors.write('{\"light\":[3,${hueValue.toInt()},\"$zonesInHex\"]}'.codeUnits);
                          }
                        }
                      },
                      handler: FlutterSliderHandler(child: Icon(Icons.color_lens)),
                      trackBar: FlutterSliderTrackBar(
                          inactiveTrackBar: BoxDecoration(color: Colors.transparent), activeTrackBar: BoxDecoration(color: Colors.transparent), activeTrackBarHeight: 12, inactiveTrackBarHeight: 12),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 15, 16.0, 15),
                    child: FlutterSlider(
                      tooltip: FlutterSliderTooltip(disabled: true),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.0),
                        gradient: LinearGradient(colors: [Colors.grey, lumMaxColor]),
                      ),
                      values: [lumValue],
                      max: 100,
                      min: 0,
                      centeredOrigin: true,
                      handlerAnimation: FlutterSliderHandlerAnimation(curve: Curves.elasticOut, reverseCurve: null, duration: Duration(milliseconds: 700), scale: 1.4),
                      onDragging: (handlerIndex, lowerValue, upperValue) {
                        if (ccSwitchValue && ccSwitchCounter == 0) {
                          displayCCWarning();
                          ccSwitchCounter++;
                        } else if (Platform.isAndroid) {
                          lumValue = lowerValue;
                          setBarreColorsState();
                          setState(() {});
                          if (myDevice.getConnectionState()) {
                            characteristicSensors.write('{\"light\":[7,${lumValue.toInt()},\"$zonesInHex\"]}'.codeUnits);
                          }
                        }
                      },
                      onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                        if (ccSwitchValue && ccSwitchCounter == 0) {
                          displayCCWarning();
                          ccSwitchCounter++;
                        } else if (Platform.isIOS) {
                          lumValue = lowerValue;
                          setBarreColorsState();
                          setState(() {});
                          if (myDevice.getConnectionState()) {
                            characteristicSensors.write('{\"light\":[7,${lumValue.toInt()},\"$zonesInHex\"]}'.codeUnits);
                          }
                        }
                      },
                      handler: FlutterSliderHandler(child: Icon(Icons.highlight)),
                      trackBar: FlutterSliderTrackBar(
                          inactiveTrackBar: BoxDecoration(color: Colors.transparent), activeTrackBar: BoxDecoration(color: Colors.transparent), activeTrackBarHeight: 12, inactiveTrackBarHeight: 12),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 15, 16.0, 15),
                    child: FlutterSlider(
                      tooltip: FlutterSliderTooltip(disabled: true),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.0),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [stabMinColor, stabMaxColor],
                        ),
                      ),
                      values: [satValue],
                      max: 100,
                      min: 0,
                      centeredOrigin: true,
                      handlerAnimation: FlutterSliderHandlerAnimation(curve: Curves.elasticOut, reverseCurve: null, duration: Duration(milliseconds: 700), scale: 1.4),
                      onDragging: (handlerIndex, lowerValue, upperValue) {
                        if (ccSwitchValue && ccSwitchCounter == 0) {
                          displayCCWarning();
                          ccSwitchCounter++;
                        } else if (Platform.isAndroid) {
                          satValue = lowerValue;
                          setBarreColorsState();
                          setState(() {});
                          if (myDevice.getConnectionState()) {
                            characteristicSensors.write('{\"light\":[9,${satValue.toInt()},\"$zonesInHex\"]}'.codeUnits);
                          }
                        }
                      },
                      onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                        if (ccSwitchValue && ccSwitchCounter == 0) {
                          displayCCWarning();
                          ccSwitchCounter++;
                        } else if (Platform.isIOS) {
                          satValue = lowerValue;
                          setBarreColorsState();
                          setState(() {});
                          if (myDevice.getConnectionState()) {
                            characteristicSensors.write('{\"light\":[9,${satValue.toInt()},\"$zonesInHex\"]}'.codeUnits);
                          }
                        }
                      },
                      handler: FlutterSliderHandler(child: Icon(Icons.wb_twighlight)),
                      trackBar: FlutterSliderTrackBar(
                          inactiveTrackBar: BoxDecoration(color: Colors.transparent), activeTrackBar: BoxDecoration(color: Colors.transparent), activeTrackBarHeight: 12, inactiveTrackBarHeight: 12),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 15, 16.0, 15),
                    child: FlutterSlider(
                      tooltip: FlutterSliderTooltip(disabled: true),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.0),
                        gradient: LinearGradient(colors: [Colors.blueAccent, Colors.white, Colors.yellowAccent]),
                      ),
                      values: [whiteValue],
                      max: 100,
                      min: 0,
                      centeredOrigin: true,
                      handlerAnimation: FlutterSliderHandlerAnimation(curve: Curves.elasticOut, reverseCurve: null, duration: Duration(milliseconds: 700), scale: 1.4),
                      onDragging: (handlerIndex, lowerValue, upperValue) {
                        if (ccSwitchValue && ccSwitchCounter == 0) {
                          displayCCWarning();
                          ccSwitchCounter++;
                        } else if (Platform.isAndroid) {
                          whiteValue = lowerValue;
                          setState(() {});
                          if (myDevice.getConnectionState()) {
                            characteristicSensors.write('{\"light\":[8,${whiteValue.toInt()},\"$zonesInHex\"]}'.codeUnits);
                          }
                        }
                      },
                      onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                        if (ccSwitchValue && ccSwitchCounter == 0) {
                          displayCCWarning();
                          ccSwitchCounter++;
                        } else if (Platform.isIOS) {
                          whiteValue = lowerValue;
                          setState(() {});
                          if (myDevice.getConnectionState()) {
                            characteristicSensors.write('{\"light\":[8,${whiteValue.toInt()},\"$zonesInHex\"]}'.codeUnits);
                          }
                        }
                      },
                      handler: FlutterSliderHandler(child: Icon(Icons.code)),
                      trackBar: FlutterSliderTrackBar(
                          inactiveTrackBar: BoxDecoration(color: Colors.transparent), activeTrackBar: BoxDecoration(color: Colors.transparent), activeTrackBarHeight: 12, inactiveTrackBarHeight: 12),
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
              ],
            ),
          ),
        ),
        onWillPop: () => returnButton(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_back),
        onPressed: () => returnButton(context),
        backgroundColor: Colors.blue[400],
      ),
    );
  }

  void displayCCWarning() {
    Get.defaultDialog(
      title: attentionTextLanguageArray[languageArrayIdentifier],
      barrierDismissible: false,
      content: Text(ccAlertDialogMessageTextLanguageArray[languageArrayIdentifier], style: TextStyle(fontSize: 14)),
      actions: [
        TextButton(
          child: Text(understoodTextLanguageArray[languageArrayIdentifier], style: TextStyle(fontSize: 14)),
          onPressed: () {
            Get.back();
            ccSwitchCounter = 0;
          },
        ),
      ],
    );
  }

  Future<bool> returnButton(BuildContext context) async {
    stateOfSleepAndReadingProcess = 0;
    Navigator.pop(context, true);
    return true;
  }
}
