import 'package:flutter/material.dart';
import 'package:flutter_app_master_uvc/pages/pin_access.dart';
import 'package:flutter_app_master_uvc/pages/pin_settings.dart';
import 'package:flutter_app_master_uvc/pages/profils.dart';
import 'package:flutter_app_master_uvc/pages/qr_code_scan.dart';
import 'package:flutter_app_master_uvc/pages/scan_ble_list.dart';
import 'package:flutter_app_master_uvc/pages/welcome.dart';
import 'package:wakelock/wakelock.dart';

void main() async {
  // needed if you intend to initialize in the `main` function
  WidgetsFlutterBinding.ensureInitialized();

  Wakelock.enable();
  bool wakelockEnabled = await Wakelock.enabled;
  if(wakelockEnabled){
    // The following statement disables the wakelock.
    Wakelock.toggle(enable: false);
  }

  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => Welcome(),
      '/pin_access': (context) => AccessPin(),
      '/pin_settings': (context) => PinSettings(),
      '/profiles': (context) => Profiles(),
      '/scan_ble_list': (context) => ScanListBle(),
      '/qr_code_scan': (context) => QrCodeScan(),
    },
  ));
}
