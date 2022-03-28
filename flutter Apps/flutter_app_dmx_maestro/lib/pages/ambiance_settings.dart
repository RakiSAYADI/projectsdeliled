import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_dmx_maestro/services/DataVariables.dart';
import 'package:flutter_app_dmx_maestro/services/elavated_button.dart';
import 'package:flutter_app_dmx_maestro/services/uvcToast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hsl_colorpicker/HSLColorPicker.dart';

class Ambiances extends StatefulWidget {
  @override
  _AmbiancesState createState() => _AmbiancesState();
}

class _AmbiancesState extends State<Ambiances> {
  ToastyMessage myUvcToast;

  List<dynamic> ambiance;
  List<String> zonesNamesList = ['', '', '', ''];

  List<Color> zoneStates = [Colors.red, Colors.red, Colors.red, Colors.red];

  int ambianceID;
  int zoneID = 0;

  Map ambiancesClassData = {};

  Color circlePickerColor = Colors.blue[400];

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
        ambianceID = ambiancesClassData['ambianceID'];
        zonesNamesList = ambiancesClassData['zoneNames'];
        myAmbianceName.text = ambiance[0];
      } catch (e) {
        debugPrint('error DATA');
        ambianceID = 0;
        zonesNamesList = ['Zone 1', 'Zone 2', 'Zone 3', 'Zone 4'];
        ambiance = ['Ambiance $ambianceID', true, 'FF0000', true, 'FF0000', true, 'FF0000', true, 'FF0000'];
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
                await characteristicMaestro.write(
                    '{\"couleur$ambianceID\":[\"${ambiance[0]}\",${ambiance[1]},\"${ambiance[2]}\",${ambiance[3]},\"${ambiance[4]}\",${ambiance[5]},\"${ambiance[6]}\",${ambiance[7]},\"${ambiance[8]}\"]}'
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
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(flex: 1, child: zoneButton(context, 0)),
                  Expanded(flex: 1, child: zoneButton(context, 1)),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(flex: 1, child: zoneButton(context, 2)),
                  Expanded(flex: 1, child: zoneButton(context, 3)),
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
                      int id = 0;
                      switch (zoneID) {
                        case 0:
                          id = 2;
                          break;
                        case 1:
                          id = 4;
                          break;
                        case 2:
                          id = 6;
                          break;
                        case 3:
                          id = 8;
                          break;
                      }
                      ambiance[id] = colorSelected.toColor().toString().split("0x")[1].toUpperCase().replaceFirst("FF", "").replaceAll(")", "");
                      setState(() {
                        circlePickerColor = Color(int.parse(getColors(ambiance[id]).toString(), radix: 16));
                      });
                    },
                    size: widthScreen * 0.4 + heightScreen * 0.3,
                    strokeWidth: widthScreen * 0.06,
                    thumbSize: 0.00001,
                    thumbStrokeSize: widthScreen * 0.005 + heightScreen * 0.005,
                    showCenterColorIndicator: false,
                    centerColorIndicatorSize: widthScreen * 0.1 + heightScreen * 0.1,
                  ),
                  bigCircle(widthScreen * 0.3, heightScreen * 0.2, circlePickerColor),
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MyElevatedButton(
        onPressed: () {
          zoneID = zoneNumber;
          for (int i = 0; i < 4; i++) {
            if (i == zoneNumber) {
              zoneStates[zoneNumber] = Colors.green;
            } else {
              zoneStates[i] = Colors.red;
            }
          }
          int id = 0;
          switch (zoneID) {
            case 0:
              id = 2;
              break;
            case 1:
              id = 4;
              break;
            case 2:
              id = 6;
              break;
            case 3:
              id = 8;
              break;
          }
          setState(() {
            circlePickerColor = Color(int.parse(getColors(ambiance[id]).toString(), radix: 16));
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            zonesNamesList[zoneNumber],
            style: TextStyle(color: zoneStates[zoneNumber], fontSize: widthScreen * 0.01 + heightScreen * 0.015),
          ),
        ),
      ),
    );
  }
}
