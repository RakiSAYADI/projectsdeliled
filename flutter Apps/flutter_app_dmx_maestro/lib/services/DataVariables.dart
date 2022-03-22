import 'package:flutter/material.dart';
import 'package:flutter_app_dmx_maestro/services/bleDeviceClass.dart';
import 'package:flutter_blue/flutter_blue.dart';

final String appName = 'MAESTRO DMX';

String dataRobotUVC;

Device myDevice;
BluetoothCharacteristic characteristicMaestro;
BluetoothCharacteristic characteristicWifi;
List<Device> devices = [];

List<String> zonesNames = ['', '', '', ''];

String dataMaestro = '';
String dataMaestro2 = '';
String dataMaestro3 = '';

String dataMaestroIOS = '';
String dataMaestroIOS2 = '';
String dataMaestroIOS3 = '';
String dataMaestroIOS4 = '';
String dataMaestroIOS5 = '';
String dataMaestroIOS6 = '';

bool startWithOutSettings;

int backGroundColorSelect = 0;

final List<Color> backGroundColor = [Color(0xFF2F2E3E), Color(0xFFDCE2E6)];
final List<List<Color>> modeColor = [
  [Color(0xFF494961), Color(0xFF353546)],
  [Color(0xFFF3FAFF), Color(0xFFC6C9CB)]
];
final List<Color> textColor = [Colors.white, Color(0xFF656574)];

final List<Color> positiveButton = [Colors.white, Colors.black];
final List<Color> negativeButton = [Colors.grey, Colors.grey];

StringBuffer getColors(String ambianceColor) {
  StringBuffer color = StringBuffer();
  if (ambianceColor.length == 6 || ambianceColor.length == 7) color.write('ff');
  color.write(ambianceColor.replaceFirst('#', ''));
  return color;
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

Future<void> displayAlert(BuildContext context, String title, Widget mainWidget, List<Widget> buttons) async {
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

List<String> myAlarmOption = ['Sun rise', 'Vibe', 'Shock'];

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

List<String> myAlarmTimeMinute = [
  '  5 sec',
  ' 10 sec',
  ' 20 sec',
  ' 30 sec',
  '  1 min',
  '  2 min',
  '  5 min',
  ' 10 min',
  ' 15 min',
  ' 20 min',
  ' 25 min',
  ' 30 min',
  ' 35 min',
  ' 40 min',
  ' 45 min',
  ' 50 min',
  ' 55 min',
  ' 60 min',
  ' 65 min',
  ' 70 min',
  ' 75 min',
  ' 80 min',
  ' 85 min',
  ' 90 min',
  ' 95 min',
  '100 min',
  '105 min',
  '110 min',
  '115 min',
  '120 min',
];
