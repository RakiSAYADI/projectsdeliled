import 'package:flutter/material.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/QrcodeDisplay.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/QrcodeDisplayFullAuto.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/QrcodeGenerate.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/QrcodeGenerateFullAuto.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/check_permissions.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/choose_qrcode.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/qr_code_scan.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/welcome.dart';

void main() {
  runApp(MaterialApp(
    title: 'SAFE UVC QR code',
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => Welcome(),
      '/choose_qr_code': (context) => ChooseQrCode(),
      '/check_permissions': (context) => CheckPermissions(),
      '/qr_code_scan': (context) => QrCodeScan(),
      '/Qr_code_Generate_Full_Auto': (context) => QrCodeGeneratorFullAuto(),
      '/Qr_code_Display_Full_Auto': (context) => QrCodeDisplayFullAuto(),
      '/Qr_code_Generate': (context) => QrCodeGenerator(),
      '/Qr_code_Display': (context) => QrCodeDisplay(),
    },
  ));
}
