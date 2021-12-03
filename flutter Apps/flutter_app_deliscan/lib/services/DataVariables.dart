import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';

final String appName = 'QRcode UVC';

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

String languageCode = 'fr';
int languageArrayIdentifier = 0;

int myExtinctionTimeMinutePosition = 0;
int myActivationTimeMinutePosition = 0;
int activationTime;

String myEmailText;
String uvcName;
String macAddress;
String pinCodeAccess;
String myRoomNameText;
String qrCodeFileName;
String qrCodeData;

String myExtinctionTimeMinuteData = ' 30 sec';
String myActivationTimeMinuteData = ' 10 sec';

List<Attachment> qrCodeList = [];
List<File> qrCodeImageList = [];
List<Widget> myQrCodes = [];
List<TableRow> listQrCodes = [];

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