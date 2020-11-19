import 'package:flutter/material.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/QrcodeDisplay.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/QrcodeGenerate.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/check_permissions.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/welcome.dart';

void main() {
  runApp(MaterialApp(
    title: 'SAFE UVC QR code',
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => Welcome(),
      '/check_permissions': (context) => CheckPermissions(),
      '/Qr_code_Generate': (context) => QrCodeGenerator(),
      '/Qr_code_Display': (context) => QrCodeDisplay(),
    },
  ));
}
