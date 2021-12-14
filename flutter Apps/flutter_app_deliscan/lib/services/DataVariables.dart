import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

final String appName = 'DeliScan';

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

final String qrCodeFirstPart = 'https://www.deliled.com/';
final String pdfFilesFolderName = 'Rapport_PDF_File';

String filePDFPath = '';
String filePDFName = '';
String pdfFileURL = '';
String userEmail = '';

bool filePDFIsSaved = false;

QRViewController qrViewController;

bool qrCodeVerified = false;

String languageCode = 'fr';
int languageArrayIdentifier = 0;

Map connectionSource = {ConnectivityResult.none: false};

Future<bool> hasNetwork() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}

Future<void> waitingWidget(BuildContext buildContext, String messageText) async {
  double screenHeight = MediaQuery.of(buildContext).size.height;
  return showDialog<void>(
      context: buildContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(messageText, textAlign: TextAlign.center),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SpinKitCircle(
                color: Colors.blue[600],
                size: screenHeight * 0.1,
              ),
            ],
          ),
        );
      });
}
