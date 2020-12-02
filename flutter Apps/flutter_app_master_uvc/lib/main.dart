import 'package:flutter/material.dart';
import 'package:flutter_app_master_uvc/pages/check_permissions.dart';
import 'package:flutter_app_master_uvc/pages/home.dart';
import 'package:flutter_app_master_uvc/pages/qr_code_scan.dart';
import 'package:flutter_app_master_uvc/pages/scan_ble_list.dart';
import 'package:flutter_app_master_uvc/pages/warning.dart';
import 'package:flutter_app_master_uvc/pages/welcome.dart';
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

  runApp(MaterialApp(
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
  ));
}
