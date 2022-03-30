import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_dmx_maestro/services/DataVariables.dart';
import 'package:flutter_app_dmx_maestro/services/elavated_button.dart';
import 'package:flutter_app_dmx_maestro/services/uvcToast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

class Ambiances extends StatefulWidget {
  @override
  _AmbiancesState createState() => _AmbiancesState();
}

class _AmbiancesState extends State<Ambiances> {
  ToastyMessage myUvcToast;

  List<dynamic> ambiance;
  List<String> zonesNamesList = ['', '', '', ''];

  List<Color> zoneStates = [Colors.green, Colors.red, Colors.red, Colors.red];

  int ambianceID;
  int zoneID = 0;

  Map ambiancesClassData = {};

  final myAmbianceName = TextEditingController();

  bool firstDisplayMainWidget = true;

  @override
  void initState() {
    myUvcToast = ToastyMessage(toastContext: context);
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    myAmbianceName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('ambiance page');
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    if (firstDisplayMainWidget) {
      try {
        ambiancesClassData = ambiancesClassData.isNotEmpty ? ambiancesClassData : ModalRoute.of(context).settings.arguments;
        ambiance = ambiancesClassData['ambiance'];
        debugPrint(ambiance.toString());
        ambianceID = ambiancesClassData['ambianceID'];
        zonesNamesList = ambiancesClassData['zoneNames'];
        myAmbianceName.text = ambiance[0];
      } catch (e) {
        debugPrint('error DATA');
        ambianceID = 0;
        zonesNamesList = ['Zone 1', 'Zone 2', 'Zone 3', 'Zone 4'];
        ambiance = ['Ambiance $ambianceID', true, true, 'FF0000', 50, 100, true, true, 'FF0000', 50, 100, true, true, 'FF0000', 50, 100, true, true, 'FF0000', 50, 100];
        myAmbianceName.text = ambiance[0];
      }
      firstDisplayMainWidget = false;
    }

    return Scaffold(
      backgroundColor: backGroundColor[backGroundColorSelect],
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: modeColor[backGroundColorSelect]),
          ),
        ),
        title: Text(
          ambiance[0],
          style: TextStyle(fontSize: 18, color: textColor[backGroundColorSelect]),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 10.0,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 20.0, 12.0, 20.0),
          child: MyElevatedButton(
            onPressed: () async {
              if (myDevice.getConnectionState()) {
                ambiance[0] = myAmbianceName.text;
                await characteristicMaestro.write('{\"couleur$ambianceID\":[\"${ambiance[0]}\",'
                        '${ambiance[1]},${ambiance[2]},\"${ambiance[3]}\",${ambiance[4]},${ambiance[5]},'
                        '${ambiance[6]},${ambiance[7]},\"${ambiance[8]}\",${ambiance[9]},${ambiance[10]},'
                        '${ambiance[11]},${ambiance[12]},\"${ambiance[13]}\",${ambiance[14]},${ambiance[15]},'
                        '${ambiance[16]},${ambiance[17]},\"${ambiance[18]}\",${ambiance[19]},${ambiance[20]}]}'
                    .codeUnits);
                displayAlert(
                  context,
                  'Enregistrement en cours',
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SpinKitCircle(
                        color: Colors.blue[600],
                        size: heightScreen * 0.1,
                      ),
                    ],
                  ),
                  null,
                );
                await readBLEData();
                myUvcToast.setToastDuration(5);
                myUvcToast.setToastMessage('Données enregistrées !');
                myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
              }
              // double popup for the alert dialog and the page
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Enregistrer',
                style: TextStyle(color: textColor[backGroundColorSelect], fontSize: 15),
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Nom de l\'ambiance :',
                  style: TextStyle(fontSize: (widthScreen * 0.05), color: textColor[backGroundColorSelect]),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: (widthScreen * 0.1)),
                child: TextField(
                  textAlign: TextAlign.center,
                  controller: myAmbianceName,
                  maxLines: 1,
                  maxLength: 12,
                  cursorColor: textColor[backGroundColorSelect],
                  style: TextStyle(fontSize: widthScreen * 0.02 + heightScreen * 0.02, color: textColor[backGroundColorSelect]),
                  decoration: InputDecoration(
                      hintText: 'exp:ambiance1',
                      counterStyle: TextStyle(color: textColor[backGroundColorSelect]),
                      hintStyle: TextStyle(
                        fontSize: widthScreen * 0.02 + heightScreen * 0.02,
                        color: textColor[backGroundColorSelect],
                      )),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Modifier l\'ambiance :',
                  style: TextStyle(fontSize: (widthScreen * 0.05), color: textColor[backGroundColorSelect]),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(flex: 1, child: zoneButton(context, 0)),
                  Expanded(flex: 1, child: zoneButton(context, 1)),
                  Expanded(flex: 1, child: zoneButton(context, 2)),
                  Expanded(flex: 1, child: zoneButton(context, 3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget zoneButton(BuildContext context, int zoneNumber) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    int zoneCommand = 0, zoneState = 0, colorState = 0, colorID = 0, whiteID = 0, whiteIDLum = 0;
    switch (zoneNumber) {
      case 0:
        zoneCommand = 1;
        zoneState = 1;
        colorState = 2;
        colorID = 3;
        whiteID = 4;
        whiteIDLum = 5;
        break;
      case 1:
        zoneCommand = 2;
        zoneState = 6;
        colorState = 7;
        colorID = 8;
        whiteID = 9;
        whiteIDLum = 10;
        break;
      case 2:
        zoneCommand = 4;
        zoneState = 11;
        colorState = 12;
        colorID = 13;
        whiteID = 14;
        whiteIDLum = 15;
        break;
      case 3:
        zoneCommand = 8;
        zoneState = 16;
        colorState = 17;
        colorID = 18;
        whiteID = 19;
        whiteIDLum = 20;
        break;
    }
    Color finalColor;
    if (intToBool(ambiance[zoneState])) {
      if (intToBool(ambiance[colorState])) {
        finalColor = whiteSelection(ambiance[whiteID]);
      } else {
        finalColor = Color(int.parse(getColors(ambiance[colorID]).toString(), radix: 16));
      }
    } else {
      finalColor = Colors.black;
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              zonesNamesList[zoneNumber],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: (widthScreen * 0.05),
                color: textColor[backGroundColorSelect],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Switch(
              value: intToBool(ambiance[zoneState]),
              onChanged: (value) async {
                setState(() {
                  ambiance[zoneState] = boolToInt(value);
                  debugPrint(ambiance[zoneState].toString());
                });
                await characteristicMaestro.write('{\"light\":[1,${boolToInt(!value)},\"$zoneCommand\"]}'.codeUnits);
              },
              activeTrackColor: Colors.lightGreenAccent,
              activeColor: Colors.green,
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                width: widthScreen * 0.06,
                height: heightScreen * 0.06,
                decoration: BoxDecoration(shape: BoxShape.circle, color: finalColor),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(Icons.settings, color: textColor[backGroundColorSelect]),
              onPressed: () {
                modifyAmbianceWidget(context, zonesNamesList[zoneNumber], whiteID, whiteIDLum, colorID, zoneCommand);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> modifyAmbianceWidget(BuildContext context, String zoneName, int hueID, int whiteID, int whiteLumID, int zoneCommand) {
    double hueValue = HSLColor.fromColor(Color(int.parse(getColors(ambiance[hueID].toString()).toString(), radix: 16))).hue * (256 / 360);
    double lumValue = HSLColor.fromColor(Color(int.parse(getColors(ambiance[hueID].toString()).toString(), radix: 16))).lightness * 100;
    double satValue = HSLColor.fromColor(Color(int.parse(getColors(ambiance[hueID].toString()).toString(), radix: 16))).saturation * 100;
    double whiteValue = double.parse(ambiance[whiteID].toString());
    double whiteLumValue = double.parse(ambiance[whiteLumID].toString());
    final Color lumMaxColor = Colors.white;
    final Color stabMaxColor = Colors.transparent;
    final Color stabMinColor = Colors.white;
    return displayAlert(
      context,
      zoneName,
      DefaultTabController(
        length: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.directions_car)),
                Tab(icon: Icon(Icons.directions_transit)),
              ],
            ),
            /*TabBarView(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
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
                          if (Platform.isAndroid) {
                            setState(() {
                              hueValue = lowerValue;
                            });
                            if (myDevice.getConnectionState()) {
                              characteristicMaestro.write('{\"light\":[3,${hueValue.toInt()},\"$zoneCommand\"]}'.codeUnits);
                            }
                          }
                        },
                        onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                          if (Platform.isIOS) {
                            setState(() {
                              hueValue = lowerValue;
                            });
                            if (myDevice.getConnectionState()) {
                              characteristicMaestro.write('{\"light\":[3,${hueValue.toInt()},\"$zoneCommand\"]}'.codeUnits);
                            }
                          }
                        },
                        handler: FlutterSliderHandler(child: Icon(Icons.color_lens)),
                        trackBar: FlutterSliderTrackBar(
                            inactiveTrackBar: BoxDecoration(color: Colors.transparent), activeTrackBar: BoxDecoration(color: Colors.transparent), activeTrackBarHeight: 12, inactiveTrackBarHeight: 12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FlutterSlider(
                        tooltip: FlutterSliderTooltip(disabled: true),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18.0),
                          gradient: LinearGradient(colors: [Colors.black, lumMaxColor]),
                        ),
                        values: [lumValue],
                        max: 100,
                        min: 0,
                        centeredOrigin: true,
                        handlerAnimation: FlutterSliderHandlerAnimation(curve: Curves.elasticOut, reverseCurve: null, duration: Duration(milliseconds: 700), scale: 1.4),
                        onDragging: (handlerIndex, lowerValue, upperValue) {
                          if (Platform.isAndroid) {
                            lumValue = lowerValue;
                            setState(() {});
                            if (myDevice.getConnectionState()) {
                              characteristicMaestro.write('{\"light\":[7,${lumValue.toInt()},\"$zoneCommand\"]}'.codeUnits);
                            }
                          }
                        },
                        onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                          if (Platform.isIOS) {
                            lumValue = lowerValue;
                            setState(() {});
                            if (myDevice.getConnectionState()) {
                              characteristicMaestro.write('{\"light\":[7,${lumValue.toInt()},\"$zoneCommand\"]}'.codeUnits);
                            }
                          }
                        },
                        handler: FlutterSliderHandler(child: Icon(Icons.highlight)),
                        trackBar: FlutterSliderTrackBar(
                            inactiveTrackBar: BoxDecoration(color: Colors.transparent), activeTrackBar: BoxDecoration(color: Colors.transparent), activeTrackBarHeight: 12, inactiveTrackBarHeight: 12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
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
                          if (Platform.isAndroid) {
                            satValue = lowerValue;
                            setState(() {});
                            if (myDevice.getConnectionState()) {
                              characteristicMaestro.write('{\"light\":[9,${satValue.toInt()},\"$zoneCommand\"]}'.codeUnits);
                            }
                          }
                        },
                        onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                          if (Platform.isIOS) {
                            satValue = lowerValue;
                            setState(() {});
                            if (myDevice.getConnectionState()) {
                              characteristicMaestro.write('{\"light\":[9,${satValue.toInt()},\"$zoneCommand\"]}'.codeUnits);
                            }
                          }
                        },
                        handler: FlutterSliderHandler(child: Icon(Icons.wb_twighlight)),
                        trackBar: FlutterSliderTrackBar(
                            inactiveTrackBar: BoxDecoration(color: Colors.transparent), activeTrackBar: BoxDecoration(color: Colors.transparent), activeTrackBarHeight: 12, inactiveTrackBarHeight: 12),
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
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
                          if (Platform.isAndroid) {
                            whiteValue = lowerValue;
                            setState(() {});
                            if (myDevice.getConnectionState()) {
                              characteristicMaestro.write('{\"light\":[8,${whiteValue.toInt()},\"$zonesInHex\"]}'.codeUnits);
                            }
                          }
                        },
                        onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                          if (Platform.isIOS) {
                            whiteValue = lowerValue;
                            setState(() {});
                            if (myDevice.getConnectionState()) {
                              characteristicMaestro.write('{\"light\":[8,${whiteValue.toInt()},\"$zonesInHex\"]}'.codeUnits);
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
                  ],
                )
              ],
            ),*/
          ],
        ),
      ),
      [
        TextButton(
          child: Text(
            'Valider',
            style: TextStyle(color: Colors.green),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(
            'Annuler',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
