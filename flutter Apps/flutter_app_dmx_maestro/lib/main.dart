import 'package:flutter/material.dart';
import 'package:flutter_app_dmx_maestro/pages/alarm_settings.dart';
import 'package:flutter_app_dmx_maestro/pages/settings.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_app_dmx_maestro/pages/home.dart';
import 'package:flutter_app_dmx_maestro/pages/scan_qrcode.dart';
import 'package:flutter_app_dmx_maestro/pages/scan_ble_list.dart';
import 'package:flutter_app_dmx_maestro/pages/welcome.dart';
import 'package:rxdart/subjects.dart';
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
    Wakelock.toggle(enable: true);
  }
  runApp(MaterialApp(
    title: 'Maestro DmX',
    initialRoute: '/',
    routes: {
      '/': (context) => Home(), //Welcome(),
      '/scan_ble_list': (context) => ScanListBle(),
      '/scan_qrcode': (context) => ScanQrCode(),
      '/home': (context) => Home(),
      '/settings': (context) => Settings(),
      '/alarm_settings': (context) => AlarmClock(),
    },
  ));
}
