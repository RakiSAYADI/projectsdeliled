import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wifiglobalapp/pages/advanced_settings.dart';
import 'package:wifiglobalapp/pages/data_modification_view.dart';
import 'package:wifiglobalapp/pages/data_view.dart';
import 'package:wifiglobalapp/pages/data_view_settings.dart';
import 'package:wifiglobalapp/pages/end_uvc.dart';
import 'package:wifiglobalapp/pages/pin_access.dart';
import 'package:wifiglobalapp/pages/pin_settings.dart';
import 'package:wifiglobalapp/pages/profils.dart';
import 'package:wifiglobalapp/pages/settings.dart';
import 'package:wifiglobalapp/pages/uvc.dart';
import 'package:wifiglobalapp/pages/warnings.dart';
import 'package:wifiglobalapp/pages/welcome.dart';
import 'package:wifiglobalapp/services/data_variables.dart';
import 'package:wifiglobalapp/services/notification_init.dart';

void main() async {
  // needed if you intend to initialize in the `main` function
  WidgetsFlutterBinding.ensureInitialized();
  //initialize notification
  notificationInit();
  // hide phone keyboard
  SystemChannels.textInput.invokeMethod('TextInput.hide');
  // set orientation to landscape
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  // check device language
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

  embeddedTimeZone = WidgetsBinding.instance!.window.locale.countryCode!;
  debugPrint(embeddedTimeZone);

  // run the main App class
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of my application.
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: GetMaterialApp(
        title: appName,
        initialRoute: '/',
        routes: {
          '/': (context) => Welcome(),
          '/pin_access': (context) => AccessPin(),
          '/pin_settings': (context) => PinSettings(),
          '/advanced_settings': (context) => AdvancedSettings(),
          '/rapport_modification': (context) => DataViewModification(),
          '/profiles': (context) => Profiles(),
          '/settings': (context) => Settings(),
          '/warnings': (context) => Warnings(),
          '/uvc': (context) => UVC(),
          '/end_uvc': (context) => EndUVC(),
          '/DataCSVView': (context) => DataCSVView(),
          '/DataCSVSettingsView': (context) => DataCSVSettingsView(),
        },
      ),
    );
  }
}
