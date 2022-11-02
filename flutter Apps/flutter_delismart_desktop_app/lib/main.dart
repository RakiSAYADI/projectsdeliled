import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/pages/automation_scan.dart';
import 'package:flutter_delismart_desktop_app/pages/device_functions_scene_modify.dart';
import 'package:flutter_delismart_desktop_app/pages/device_scan.dart';
import 'package:flutter_delismart_desktop_app/pages/device_scene_add.dart';
import 'package:flutter_delismart_desktop_app/pages/room_device_add.dart';
import 'package:flutter_delismart_desktop_app/pages/room_device_scan.dart';
import 'package:flutter_delismart_desktop_app/pages/room_scan.dart';
import 'package:flutter_delismart_desktop_app/pages/scene_create.dart';
import 'package:flutter_delismart_desktop_app/pages/scene_modify.dart';
import 'package:flutter_delismart_desktop_app/pages/scene_scan.dart';
import 'package:flutter_delismart_desktop_app/pages/timer_scene_add.dart';
import 'package:flutter_delismart_desktop_app/pages/universe_create.dart';
import 'package:flutter_delismart_desktop_app/pages/universe_scan.dart';
import 'package:flutter_delismart_desktop_app/pages/universe_user_add.dart';
import 'package:flutter_delismart_desktop_app/pages/universe_user_scan.dart';
import 'package:flutter_delismart_desktop_app/pages/user_create.dart';
import 'package:flutter_delismart_desktop_app/pages/user_delete.dart';
import 'package:flutter_delismart_desktop_app/pages/user_login.dart';
import 'package:flutter_delismart_desktop_app/pages/user_scan.dart';
import 'package:flutter_delismart_desktop_app/pages/welcome.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/internet_check_service.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

CheckInternet checkInternet = CheckInternet();

void main() {
  if (!kIsWeb) {
    languageCode = Platform.localeName.split('_')[0];
    debugPrint('le language de telephone : $languageCode');
    checkInternet.startChecking();
  } else {
    debugPrint('web');
  }

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

  getTuyaData();

  runApp(const MyApp());
}

void getTuyaData() async {
  await tokenClass.init();
  appClass.getInfo();
  appClass.getUserList();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: GetMaterialApp(
        onDispose: () {
          checkInternet.stopChecking();
        },
        title: appName,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const Welcome(),
          '/user_list': (context) => const ScanListUser(),
          '/universe_list': (context) => const ScanListUniverse(),
          '/universe_user_list': (context) => const ScanListUniverseUser(),
          '/device_list': (context) => const ScanListDevice(),
          '/automation_list': (context) => const ScanListAutomation(),
          '/scene_list': (context) => const ScanListScene(),
          '/room_list': (context) => const ScanListRoom(),
          '/room_device_list': (context) => const ScanListRoomDevice(),
          '/user_login': (context) => const UserLogin(),
          '/user_create': (context) => const UserCreate(),
          '/user_delete': (context) => const UserDelete(),
          '/universe_create': (context) => const UniverseCreate(),
          '/universe_user_add': (context) => const UniverseUserAdd(),
          '/room_device_add': (context) => const RoomDeviceAdd(),
          '/scene_create': (context) => const SceneCreate(),
          '/scene_modify': (context) => const SceneModify(),
          '/device_scene_add': (context) => const DeviceSceneAdd(),
          '/timer_scene_add': (context) => const TimerSceneAdd(),
          '/device_functions_scene_modify': (context) => const DeviceFunctionsSceneModify(),
        },
      ),
    );
  }
}
