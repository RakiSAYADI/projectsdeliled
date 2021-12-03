import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_deliscan/pages/QrcodeDisplay.dart';
import 'package:flutter_app_deliscan/pages/QrcodeDisplayData.dart';
import 'package:flutter_app_deliscan/pages/QrcodeDisplaySecurity.dart';
import 'package:flutter_app_deliscan/pages/QrcodeGenerate.dart';
import 'package:flutter_app_deliscan/pages/QrcodeGenerateData.dart';
import 'package:flutter_app_deliscan/pages/QrcodeGenerateFullAuto.dart';
import 'package:flutter_app_deliscan/pages/check_permissions.dart';
import 'package:flutter_app_deliscan/pages/choose_qrcode.dart';
import 'package:flutter_app_deliscan/pages/qr_code_scan.dart';
import 'package:flutter_app_deliscan/pages/welcome.dart';
import 'package:flutter_app_deliscan/services/DataVariables.dart';

void main() {
  languageCode = Platform.localeName.split('_')[0];
  print('le language de telephone : $languageCode');

  if (languageCode.isEmpty) {
    languageCode = 'en';
  }

  switch (languageCode) {
    case 'fr':
      languageArrayIdentifier = 0;
      break;
    case 'en':
      languageArrayIdentifier = 1;
      break;
    default:
      languageArrayIdentifier = 1;
      break;
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => Welcome(),
        '/choose_qr_code': (context) => ChooseQrCode(),
        '/check_permissions': (context) => CheckPermissions(),
        '/qr_code_scan': (context) => QrCodeScan(),
        '/Qr_code_Generate_Full_Auto': (context) => QrCodeGeneratorFullAuto(),
        '/Qr_code_Generate_Data': (context) => QrCodeGeneratorData(),
        '/Qr_code_Display_Data': (context) => QrCodeDisplayData(),
        '/Qr_code_Generate': (context) => QrCodeGenerator(),
        '/Qr_code_Display': (context) => QrCodeDisplay(),
        '/Qr_code_Display_Security': (context) => QrCodeDisplaySecurity()
      },
    );
  }
}
