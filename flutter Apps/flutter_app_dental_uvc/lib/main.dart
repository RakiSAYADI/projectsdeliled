import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutterappdentaluvc/pages/Automatique_UVC.dart';
import 'package:flutterappdentaluvc/pages/advanced_settings.dart';
import 'package:flutterappdentaluvc/pages/data_view.dart';
import 'package:flutterappdentaluvc/pages/end_uvc.dart';
import 'package:flutterappdentaluvc/pages/pin_access.dart';
import 'package:flutterappdentaluvc/pages/pin_settings.dart';
import 'package:flutterappdentaluvc/pages/profils.dart';
import 'package:flutterappdentaluvc/pages/scan_ble_list.dart';
import 'package:flutterappdentaluvc/pages/settings.dart';
import 'package:flutterappdentaluvc/pages/uvc.dart';
import 'package:flutterappdentaluvc/pages/warnings.dart';
import 'package:flutterappdentaluvc/pages/welcome.dart';
import 'package:rxdart/subjects.dart';

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
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
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
  runApp(
    Phoenix(
      child: MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => Welcome(),
          '/pin_access': (context) => AccessPin(),
          '/advanced_settings': (context) => AdvancedSettings(),
          '/scan_ble_list': (context) => ScanListBle(),
          '/auto_uvc': (context) => UVCAuto(),
          '/DataCSVView': (context) => DataCSVView(),
          '/pin_settings': (context) => PinSettings(),
          '/profiles': (context) => Profiles(),
          '/settings': (context) => Settings(),
          '/warnings': (context) => Warnings(),
          '/uvc': (context) => UVC(),
          '/end_uvc': (context) => EndUVC(),
        },
      ),
    ),
  );
}
