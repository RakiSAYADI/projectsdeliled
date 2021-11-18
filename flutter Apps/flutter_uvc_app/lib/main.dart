import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutteruvcapp/pages/check_permissions.dart';
import 'package:flutteruvcapp/pages/data_view.dart';
import 'package:flutteruvcapp/pages/data_view_qrcode.dart';
import 'package:flutteruvcapp/pages/end_uvc.dart';
import 'package:flutteruvcapp/pages/profils.dart';
import 'package:flutteruvcapp/pages/qr_code_scan.dart';
import 'package:flutteruvcapp/pages/send_email.dart';
import 'package:flutteruvcapp/pages/send_file_qrcode.dart';
import 'package:flutteruvcapp/pages/settings.dart';
import 'package:flutteruvcapp/pages/tutorial_view.dart';
import 'package:flutteruvcapp/pages/uvc.dart';
import 'package:flutteruvcapp/pages/warnings.dart';
import 'package:flutteruvcapp/pages/scan_ble_list.dart';
import 'package:flutteruvcapp/pages/welcome.dart';
import 'package:flutteruvcapp/services/DataVariables.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wakelock/wakelock.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// Streams are created so that app can respond to notification-related events since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject = BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject = BehaviorSubject<String>();

NotificationAppLaunchDetails notificationAppLaunchDetails;

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}

void main() async {
  // needed if you intend to initialize in the `main` function
  WidgetsFlutterBinding.ensureInitialized();

  notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  // Note: permissions aren't requested here just to demonstrate that can be done later using the `requestPermissions()` method
  // of the `IOSFlutterLocalNotificationsPlugin` class
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (int id, String title, String body, String payload) async {
        didReceiveLocalNotificationSubject.add(ReceivedNotification(id: id, title: title, body: body, payload: payload));
      });
  var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    selectNotificationSubject.add(payload);
  });
  flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

  Wakelock.enable();
  bool wakelockEnabled = await Wakelock.enabled;
  if (wakelockEnabled) {
    // The following statement disables the wakelock.
    Wakelock.toggle(enable: false);
  }

  languageCode = Platform.localeName.split('_')[0];
  print('le language de telephone : $languageCode');

  if (languageCode.isEmpty) {
    languageCode = 'fr';
  }

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'SAFE UVC',
    initialRoute: '/',
    routes: {
      '/': (context) => Welcome(),
      '/check_permissions': (context) => CheckPermissions(),
      '/tutorial_view': (context) => TutorialView(),
      '/profiles': (context) => Profiles(),
      '/DataCSVView': (context) => DataCSVView(),
      '/DataCSVViewQrCode': (context) => DataCSVViewQrCode(),
      '/send_email': (context) => SendEmail(),
      '/send_email_qr_code': (context) => SendEmailQrCode(),
      '/scan_ble_list': (context) => ScanListBle(),
      '/qr_code_scan': (context) => QrCodeScan(),
      '/settings': (context) => Settings(),
      '/warnings': (context) => Warnings(),
      '/uvc': (context) => UVC(),
      '/end_uvc': (context) => EndUVC(),
    },
  ));
}
