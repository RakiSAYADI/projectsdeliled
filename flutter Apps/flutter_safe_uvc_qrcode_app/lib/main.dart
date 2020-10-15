import 'package:flutter/material.dart';
import 'package:flutter_safe_uvc_qrcode_app/pages/welcome.dart';

void main() async {

  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => Welcome(),
    },
  ));
}
