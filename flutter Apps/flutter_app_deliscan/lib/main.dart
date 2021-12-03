import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_deliscan/pages/check_permissions.dart';
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
        '/check_permissions': (context) => CheckPermissions(),
        '/qr_code_scan': (context) => QrCodeScan(),
      },
    );
  }
}
