import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_dmx_maestro/services/bleDeviceClass.dart';
import 'package:flutter_blue/flutter_blue.dart';

final String appName = 'LumyHome';

final double hueCoefficient = (256 / 360);

String dataRobotUVC;

Device myDevice;
BluetoothCharacteristic characteristicMaestro;
BluetoothCharacteristic characteristicWifi;
List<Device> devices = [];

List<String> zonesNames = ['', '', '', ''];

String dataMaestro = '';
String dataMaestro2 = '';
String dataMaestro3 = '';
String dataMaestro4 = '';

String dataMaestroIOS = '';
String dataMaestroIOS2 = '';
String dataMaestroIOS3 = '';
String dataMaestroIOS4 = '';
String dataMaestroIOS5 = '';
String dataMaestroIOS6 = '';
String dataMaestroIOS7 = '';
String dataMaestroIOS8 = '';
String dataMaestroIOS9 = '';

String embeddedTimeZone = '';

int backGroundColorSelect = 0;

bool appMode = true;

final List<Color> backGroundColor = [Color(0xFF2F2E3E), Color(0xFFDCE2E6)];
final List<List<Color>> modeColor = [
  [Color(0xFF494961), Color(0xFF353546)],
  [Color(0xFFF3FAFF), Color(0xFFC6C9CB)]
];
final List<Color> textColor = [Colors.white, Color(0xFF656574)];

final List<List<Color>> textZoneSelectorColor = [
  [Colors.white, Color(0xFF656574)],
  [Color(0xFF656574), Colors.grey[400]]
];

final List<Color> positiveButton = [Colors.white, Colors.black];
final List<Color> negativeButton = [Colors.grey, Colors.grey];

int boolToInt(bool a) => a == true ? 1 : 0;

bool intToBool(int a) => a == 1 ? true : false;

Color whiteSelection(int whiteSelector) {
  return Color.lerp(Color(0xFF8FB5FF), Color(0xFFFFF99A), whiteSelector / 100);
}

StringBuffer getColors(String ambianceColor) {
  StringBuffer color = StringBuffer();
  if (ambianceColor.length == 6 || ambianceColor.length == 7) color.write('ff');
  color.write(ambianceColor.replaceFirst('#', ''));
  return color;
}

Future<void> readBLEData() async {
  if (Platform.isAndroid) {
    dataMaestro = String.fromCharCodes(await characteristicWifi.read());
    debugPrint(dataMaestro);
    await Future.delayed(Duration(milliseconds: 500));
    dataMaestro2 = String.fromCharCodes(await characteristicWifi.read());
    debugPrint(dataMaestro2);
    await Future.delayed(Duration(milliseconds: 500));
    dataMaestro3 = String.fromCharCodes(await characteristicWifi.read());
    debugPrint(dataMaestro3);
    await Future.delayed(Duration(milliseconds: 500));
    dataMaestro4 = String.fromCharCodes(await characteristicWifi.read());
    debugPrint(dataMaestro4);
  }
  if (Platform.isIOS) {
    dataMaestroIOS = String.fromCharCodes(await characteristicWifi.read());
    debugPrint(dataMaestroIOS);
    await Future.delayed(Duration(milliseconds: 500));
    dataMaestroIOS2 = String.fromCharCodes(await characteristicWifi.read());
    debugPrint(dataMaestroIOS2);
    await Future.delayed(Duration(milliseconds: 500));
    dataMaestroIOS3 = String.fromCharCodes(await characteristicWifi.read());
    debugPrint(dataMaestroIOS3);
    await Future.delayed(Duration(milliseconds: 500));
    dataMaestroIOS4 = String.fromCharCodes(await characteristicWifi.read());
    debugPrint(dataMaestroIOS4);
    await Future.delayed(Duration(milliseconds: 500));
    dataMaestroIOS5 = String.fromCharCodes(await characteristicWifi.read());
    debugPrint(dataMaestroIOS5);
    await Future.delayed(Duration(milliseconds: 500));
    dataMaestroIOS6 = String.fromCharCodes(await characteristicWifi.read());
    debugPrint(dataMaestroIOS6);
    await Future.delayed(Duration(milliseconds: 500));
    dataMaestroIOS7 = String.fromCharCodes(await characteristicWifi.read());
    debugPrint(dataMaestroIOS7);
    await Future.delayed(Duration(milliseconds: 500));
    dataMaestroIOS8 = String.fromCharCodes(await characteristicWifi.read());
    debugPrint(dataMaestroIOS8);
    await Future.delayed(Duration(milliseconds: 500));
    dataMaestroIOS9 = String.fromCharCodes(await characteristicWifi.read());
    debugPrint(dataMaestroIOS9);
  }
}

Widget bigCircle(double width, double height, Color color) {
  return Container(
    width: width,
    height: height,
    decoration: new BoxDecoration(
      color: color,
      shape: BoxShape.circle,
    ),
  );
}

Future<void> displayAlert({BuildContext context, String title, Widget mainWidget, List<Widget> buttons}) {
  return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, textAlign: TextAlign.center, style: TextStyle(color: textColor[backGroundColorSelect])),
          backgroundColor: backGroundColor[backGroundColorSelect],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32.0))),
          content: mainWidget,
          actions: buttons,
        );
      });
}

List<String> myAlarmOption = ['Basic', 'Sun rise', 'Vibe', 'Shock'];

List<String> myAmbiances = ['Ambiance 1', 'Ambiance 2', 'Ambiance 3', 'Ambiance 4', 'Ambiance 5', 'Ambiance 6'];

List<String> myTimeHours = ['00', '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23'];

List<String> myTimeMinutes = [
  '00',
  '01',
  '02',
  '03',
  '04',
  '05',
  '06',
  '07',
  '08',
  '09',
  '10',
  '11',
  '12',
  '13',
  '14',
  '15',
  '16',
  '17',
  '18',
  '19',
  '20',
  '21',
  '22',
  '23',
  '24',
  '25',
  '26',
  '27',
  '28',
  '29',
  '30',
  '31',
  '32',
  '33',
  '34',
  '35',
  '36',
  '37',
  '38',
  '39',
  '40',
  '41',
  '42',
  '43',
  '44',
  '45',
  '46',
  '47',
  '48',
  '49',
  '50',
  '51',
  '52',
  '53',
  '54',
  '55',
  '56',
  '57',
  '58',
  '59'
];

List<String> myTimeSeconds = [
  '00',
  '01',
  '02',
  '03',
  '04',
  '05',
  '06',
  '07',
  '08',
  '09',
  '10',
  '11',
  '12',
  '13',
  '14',
  '15',
  '16',
  '17',
  '18',
  '19',
  '20',
  '21',
  '22',
  '23',
  '24',
  '25',
  '26',
  '27',
  '28',
  '29',
  '30',
  '31',
  '32',
  '33',
  '34',
  '35',
  '36',
  '37',
  '38',
  '39',
  '40',
  '41',
  '42',
  '43',
  '44',
  '45',
  '46',
  '47',
  '48',
  '49',
  '50',
  '51',
  '52',
  '53',
  '54',
  '55',
  '56',
  '57',
  '58',
  '59'
];
