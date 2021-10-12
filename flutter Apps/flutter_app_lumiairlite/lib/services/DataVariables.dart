import 'package:flutter/material.dart';
import 'package:flutter_app_bispectrum/services/bleDeviceClass.dart';
import 'package:flutter_blue/flutter_blue.dart';

final String appName = 'Bispectrum';

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

bool deactivateSleepAndReadingProcess = false;
Widget mainWidgetScreen;
final int timeSleep = 60000;

Device myDevice;
BluetoothCharacteristic characteristicSensors;
BluetoothCharacteristic characteristicData;

String dataChar1 = '';
String dataChar2 = '';

int deviceTimeValue = 1000000;
int detectionTimeValue = 0;
int temperatureValue = 28;
int humidityValue = 50;
int lightValue = 20;
int co2Value = 500;
int tvocValue = 750;
bool deviceWifiState = false;

String appTime = '00:00';
int temperatureMeteoValue = 28;
String weatherState = '01d';

int myExtinctionTimeMinutePosition = 0;
int myActivationTimeMinutePosition = 0;
int activationTime;

String pinCodeAccess;

List<List<String>> uvcData;

List<String> myExtinctionTimeMinute = [
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

List<String> myActivationTimeMinute = [
  ' 10 sec',
  ' 20 sec',
  ' 30 sec',
  ' 40 sec',
  ' 50 sec',
  ' 60 sec',
  ' 70 sec',
  ' 80 sec',
  ' 90 sec',
  '100 sec',
  '110 sec',
  '120 sec',
];

List<String> myTimeHours = [
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
  '23'
];

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