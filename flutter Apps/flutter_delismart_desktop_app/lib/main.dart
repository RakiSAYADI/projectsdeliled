import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/pages/welcome.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/intenet_check_service.dart';
import 'package:get/get.dart';

CheckInternet checkInternet = CheckInternet();

void main() {
  languageCode = Platform.localeName.split('_')[0];
  debugPrint('le language de telephone : $languageCode');

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

  checkInternet.startChecking();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      onDispose: () {
        checkInternet.stopChecking();
      },
      title: appName,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const Welcome(),
      },
    );
  }
}
