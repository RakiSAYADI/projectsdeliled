import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_dmx_maestro/services/DataVariables.dart';
import 'package:flutter_app_dmx_maestro/services/uvcToast.dart';
import 'package:hsl_colorpicker/HSLColorPicker.dart';

class Ambiances extends StatefulWidget {
  @override
  _AmbiancesState createState() => _AmbiancesState();
}

class _AmbiancesState extends State<Ambiances> {
  final int zonesTabPadding = 60;

  ToastyMessage myUvcToast;

  List<String> ambiance;
  List<String> zonesNamesList = ['', '', '', ''];

  List<bool> zoneStates = [false, false, false, false];

  int ambianceID;
  int zoneID = 0;

  Map ambiancesClassData = {};

  Color saveButtonColor = Colors.blue[400];
  Color circlePickerColor = Colors.blue[400];

  final myAmbianceName = TextEditingController();

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
    print('ambiance page');
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    try {
      ambiancesClassData = ambiancesClassData.isNotEmpty ? ambiancesClassData : ModalRoute.of(context).settings.arguments;
      ambiance = ambiancesClassData['ambiance'];
      ambianceID = ambiancesClassData['ambianceID'];
      zonesNamesList = ambiancesClassData['zoneNames'];
      myAmbianceName.text = ambiance[0];
    } catch (e) {
      debugPrint('error DATA');
      ambianceID = 0;
      zonesNamesList = ['Zone 1', 'Zone 2', 'Zone 3', 'Zone 4'];
      ambiance = ['Ambiance $ambianceID', 'FF0000', 'FF0000', 'FF0000', 'FF0000'];
      myAmbianceName.text = ambiance[0];
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          ambiance[0],
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: true,
      ),
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
                children: [
                  VerticalDivider(
                    thickness: 1.0,
                    color: Colors.grey[600],
                  ),
                  TextButton(
                    onPressed: () async {
                      setState(() {
                        saveButtonColor = Colors.blue[400];
                      });
                      if (myDevice.getConnectionState()) {
                        ambiance[0] = myAmbianceName.text;
                        await characteristicMaestro.write('{\"couleur$ambianceID\":[\"${ambiance[0]}\",\"${ambiance[1]}\",\"${ambiance[2]}\",\"${ambiance[3]}\",\"${ambiance[4]}\"]}'.codeUnits);
                        if (Platform.isAndroid) {
                          await Future.delayed(Duration(milliseconds: 500));
                          dataMaestro = String.fromCharCodes(await characteristicWifi.read());
                          await Future.delayed(Duration(milliseconds: 500));
                          dataMaestro2 = String.fromCharCodes(await characteristicWifi.read());
                          await Future.delayed(Duration(milliseconds: 500));
                          dataMaestro3 = String.fromCharCodes(await characteristicWifi.read());
                        }
                        if (Platform.isIOS) {
                          await Future.delayed(Duration(milliseconds: 500));
                          dataMaestroIOS = String.fromCharCodes(await characteristicWifi.read());
                          await Future.delayed(Duration(milliseconds: 500));
                          dataMaestroIOS2 = String.fromCharCodes(await characteristicWifi.read());
                          await Future.delayed(Duration(milliseconds: 500));
                          dataMaestroIOS3 = String.fromCharCodes(await characteristicWifi.read());
                          await Future.delayed(Duration(milliseconds: 500));
                          dataMaestroIOS4 = String.fromCharCodes(await characteristicWifi.read());
                          await Future.delayed(Duration(milliseconds: 500));
                          dataMaestroIOS5 = String.fromCharCodes(await characteristicWifi.read());
                          await Future.delayed(Duration(milliseconds: 500));
                          dataMaestroIOS6 = String.fromCharCodes(await characteristicWifi.read());
                        }
                        myUvcToast.setToastDuration(5);
                        myUvcToast.setToastMessage('Données enregistrées !');
                        myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
                      }
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'Enregistrer',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0), side: BorderSide(color: Colors.black))),
                        backgroundColor: MaterialStateProperty.all<Color>(saveButtonColor)),
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
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Nom du l\'ambiance :',
                  style: TextStyle(fontSize: (widthScreen * 0.05)),
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
                  style: TextStyle(
                    fontSize: widthScreen * 0.02 + heightScreen * 0.02,
                  ),
                  decoration: InputDecoration(
                      hintText: 'exp:ambiance1',
                      hintStyle: TextStyle(
                        fontSize: widthScreen * 0.02 + heightScreen * 0.02,
                        color: Colors.grey,
                      )),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [zoneButton(context, 0), zoneButton(context, 1)],
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [zoneButton(context, 2), zoneButton(context, 3)],
              ),
            ),/*
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 10.0),
                child: ToggleButtons(
                  borderRadius: BorderRadius.circular(18.0),
                  isSelected: zoneStates,
                  onPressed: (int index) {
                    print(index);
                    setState(() {
                      zoneStates[index] = !zoneStates[index];
                      zoneID = index;
                      circlePickerColor = Color(int.parse(getColors(ambiance[zoneID + 1]).toString(), radix: 16));
                    });
                    for (int buttonIndex = 0; buttonIndex < zoneStates.length; buttonIndex++) {
                      if (buttonIndex == index) {
                        zoneStates[buttonIndex] = true;
                      } else {
                        zoneStates[buttonIndex] = false;
                      }
                    }
                    saveButtonColor = Colors.grey[400];
                  },
                  children: [
                    Container(
                        width: (widthScreen - zonesTabPadding) / 4,
                        height: (heightScreen - zonesTabPadding) / 7,
                        child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                          new SizedBox(width: 4.0),
                          new Text(
                            zonesNamesList[0],
                            style: TextStyle(fontSize: widthScreen * 0.05, color: Color(0xFF264eb6), fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          )
                        ])),
                    Container(
                        width: (widthScreen - zonesTabPadding) / 4,
                        height: (heightScreen - zonesTabPadding) / 7,
                        child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                          new SizedBox(width: 4.0),
                          new Text(
                            zonesNamesList[1],
                            style: TextStyle(fontSize: widthScreen * 0.05, color: Color(0xFF264eb6), fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          )
                        ])),
                    Container(
                        width: (widthScreen - zonesTabPadding) / 4,
                        height: (heightScreen - zonesTabPadding) / 7,
                        child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                          new SizedBox(width: 4.0),
                          new Text(
                            zonesNamesList[2],
                            style: TextStyle(fontSize: widthScreen * 0.05, color: Color(0xFF264eb6), fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          )
                        ])),
                    Container(
                        width: (widthScreen - zonesTabPadding) / 4,
                        height: (heightScreen - zonesTabPadding) / 7,
                        child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                          new SizedBox(width: 4.0),
                          new Text(
                            zonesNamesList[3],
                            style: TextStyle(fontSize: widthScreen * 0.05, color: Color(0xFF264eb6), fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          )
                        ])),
                  ],
                  selectedColor: Colors.black,
                  selectedBorderColor: Colors.white,
                  fillColor: Colors.black.withOpacity(0.5),
                ),
              ),
            ),*/
            Expanded(
              flex: 5,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  HSLColorPicker(
                    onChanged: (colorSelected) {
                      saveButtonColor = Colors.grey[400];
                      ambiance[zoneID + 1] = colorSelected.toColor().toString().split("0x")[1].toUpperCase().replaceFirst("FF", "").replaceAll(")", "");
                      setState(() {
                        circlePickerColor = Color(int.parse(getColors(ambiance[zoneID + 1]).toString(), radix: 16));
                      });
                    },
                    size: widthScreen * 0.4 + heightScreen * 0.3,
                    strokeWidth: widthScreen * 0.06,
                    thumbSize: 0.00001,
                    thumbStrokeSize: widthScreen * 0.005 + heightScreen * 0.005,
                    showCenterColorIndicator: false,
                    centerColorIndicatorSize: widthScreen * 0.1 + heightScreen * 0.1,
                  ),
                  bigCircle(widthScreen * 0.3, heightScreen * 0.3, circlePickerColor),
                ],
              ),
            ),
          ],
        ),
      ),
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
                for (int buttonIndex = 0; buttonIndex < zoneStates.length; buttonIndex++) {
                  if (buttonIndex == zoneID) {
                    zoneStates[buttonIndex] = true;
                  } else {
                    zoneStates[buttonIndex] = false;
                  }
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(5.0),
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
}
