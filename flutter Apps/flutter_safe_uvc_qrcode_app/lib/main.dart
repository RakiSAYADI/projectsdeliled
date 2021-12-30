import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/QrcodeDisplay.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/QrcodeDisplayData.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/QrcodeDisplaySecurity.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/QrcodeGenerate.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/QrcodeGenerateData.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/QrcodeGenerateFullAuto.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/check_permissions.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/choose_qrcode.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/file_select_to_print.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/qr_code_scan.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/scan_printers_list.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/welcome.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/DataVariables.dart';

void main() {
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
      title: appName,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => Welcome(),
        '/choose_qr_code': (context) => ChooseQrCode(),
        '/check_permissions': (context) => CheckPermissions(),
        '/scan_list_printers': (context) => ScanListPrinters(),
        '/file_selector': (context) => FileSelector(),
        '/qr_code_scan': (context) => QrCodeScan(),
        '/Qr_code_Generate_Full_Auto': (context) => QrCodeGeneratorFullAuto(),
        '/Qr_code_Generate_Data': (context) => QrCodeGeneratorData(),
        '/Qr_code_Display_Data': (context) => QrCodeDisplayData(),
        '/Qr_code_Generate': (context) => QrCodeGenerator(),
        '/Qr_code_Display': (context) => QrCodeDisplay(),
        '/Qr_code_Display_Security': (context) => QrCodeDisplaySecurity()
      },
    );
  }
}
