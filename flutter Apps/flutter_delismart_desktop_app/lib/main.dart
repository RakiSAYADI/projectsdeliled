import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/pages/welcome.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:get/get.dart';

void main() async {
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
  debugPrint('connection is : ${await hasNetwork()}');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      onDispose: () {},
      title: appName,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const Welcome(),
      },
    );
  }
}
