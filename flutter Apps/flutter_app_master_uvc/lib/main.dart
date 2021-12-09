import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_master_uvc/pages/check_permissions.dart';
import 'package:flutter_app_master_uvc/pages/home.dart';
import 'package:flutter_app_master_uvc/pages/qr_code_scan.dart';
import 'package:flutter_app_master_uvc/pages/scan_ble_list.dart';
import 'package:flutter_app_master_uvc/pages/warning.dart';
import 'package:flutter_app_master_uvc/pages/welcome.dart';
import 'package:flutter_app_master_uvc/services/DataVariables.dart';
import 'package:wakelock/wakelock.dart';

void main() async {
  // needed if you intend to initialize in the `main` function
  WidgetsFlutterBinding.ensureInitialized();

  Wakelock.enable();
  bool wakelockEnabled = await Wakelock.enabled;
  if (wakelockEnabled) {
    // The following statement disables the wakelock.
    Wakelock.toggle(enable: false);
  }

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
      initialRoute: '/',
      title: 'MASTER UVC',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => Welcome(),
        '/check_permissions': (context) => CheckPermissions(),
        '/home': (context) => Home(),
        '/warning': (context) => Warning(),
        '/scan_ble_list': (context) => ScanListBle(),
        '/qr_code_scan': (context) => QrCodeScan(),
      },
    );
  }
}
