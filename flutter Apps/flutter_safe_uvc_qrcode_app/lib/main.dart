import 'package:flutter/material.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/QrcodeDisplay.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/QrcodeDisplayData.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/QrcodeDisplaySecurity.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/QrcodeGenerate.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/QrcodeGenerateData.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/QrcodeGenerateFullAuto.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/check_permissions.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/choose_qrcode.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/qr_code_scan.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/welcome.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QRcode UVC',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => Welcome(),
        '/choose_qr_code': (context) => ChooseQrCode(),
        '/check_permissions': (context) => CheckPermissions(),
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
