import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_deliscan/pages/check_permissions.dart';
import 'package:flutter_app_deliscan/pages/pdf_email_send.dart';
import 'package:flutter_app_deliscan/pages/pdf_file_downloader.dart';
import 'package:flutter_app_deliscan/pages/pdf_files_list.dart';
import 'package:flutter_app_deliscan/pages/pdf_files_view.dart';
import 'package:flutter_app_deliscan/pages/pdf_view.dart';
import 'package:flutter_app_deliscan/pages/qr_code_scan.dart';
import 'package:flutter_app_deliscan/pages/welcome.dart';
import 'package:flutter_app_deliscan/services/DataVariables.dart';
import 'package:get/get.dart';

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
    return GetMaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => Welcome(),
        '/check_permissions': (context) => CheckPermissions(),
        '/qr_code_scan': (context) => QrCodeScan(),
        '/pdf_view': (context) => PDFViewer(),
        '/pdf_download': (context) => PDFDownloader(),
        '/pdf_list': (context) => PDFList(),
        '/pdf_file_view': (context) => PDFFileView(),
        '/pdf_email': (context) => PDFEmail(),
      },
    );
  }
}
