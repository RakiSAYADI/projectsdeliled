import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutteruvcapp/services/bleDeviceClass.dart';
import 'package:flutteruvcapp/services/uvcClass.dart';

final String appName = 'SAFE UVC';

Device myDevice;

UvcLight myUvcLight;

int languageArrayIdentifier = 0;

int myExtinctionTimeMinutePosition;
int myActivationTimeMinutePosition;
int activationTime;

List<BluetoothDevice> scanDevices;
List<List<String>> uvcData;

String pinCodeAccess;
String userEmail;
String languageCode = 'fr';

bool isTreatmentCompleted;
bool qrCodeConnectionOrSecurity;
bool startWithOutSettings;

List<String> myTimeDays = [
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
  '30'
];

List<String> myTimeMonths = [
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
  '12'
];

List<String> myTimeYears = [
  '2020',
  '2021',
  '2022',
  '2023',
  '2024',
  '2025',
  '2026',
  '2027',
  '2028',
  '2029',
  '2030'
];
