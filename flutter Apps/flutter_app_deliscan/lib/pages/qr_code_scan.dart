import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_deliscan/pages/pdf_view.dart';
import 'package:flutter_app_deliscan/services/DataVariables.dart';
import 'package:flutter_app_deliscan/services/animation_between_pages.dart';
import 'package:flutter_app_deliscan/services/connectivityCheck.dart';
import 'package:flutter_app_deliscan/services/languageDataBase.dart';
import 'package:flutter_app_deliscan/services/uvcToast.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrCodeScan extends StatefulWidget {
  @override
  _QrCodeScanState createState() => _QrCodeScanState();
}

class _QrCodeScanState extends State<QrCodeScan> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  Barcode _result;

  ToastyMessage _myUvcToast;

  final MyConnectivity _connectivity = MyConnectivity.instance;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      qrViewController.pauseCamera();
    }
    if (Platform.isIOS) {
      qrViewController.resumeCamera();
    }
  }

  @override
  void initState() {
    _myUvcToast = ToastyMessage(toastContext: context);
    Future.delayed(const Duration(seconds: 1), () async {
      await qrViewController.resumeCamera();
      _myUvcToast.setToastDuration(2);
      _myUvcToast.setToastMessage(cameraLaunchToastTextLanguageArray[languageArrayIdentifier]);
      _myUvcToast.showToast(Colors.green, Icons.autorenew, Colors.white);
    });
    _connectivity.initialise();
    super.initState();
  }

  @override
  void dispose() {
    _connectivity.disposeStream();
    qrViewController.dispose();
    super.dispose();
  }

  void _onQrViewCreated(QRViewController controller) {
    qrViewController = controller;
    controller.scannedDataStream.listen((scanData) async {
      _result = scanData;
      print('onCapture----${_result.code}');
      if (_result.code.isNotEmpty && !qrCodeVerified) {
        if (_result.code.startsWith(qrCodeFirstPart)) {
          pdfFileURL = _result.code;
          print("good qrcode ");
          qrCodeVerified = true;
        } else {
          print("bad qrcode ");
          qrCodeVerified = false;
        }
        if (qrCodeVerified) {
          controller.pauseCamera();
          if (ancientFilePath != '') {
            File ancientFile = File(ancientFilePath);
            await ancientFile.delete();
          }
          createRoute(context, PDFViewer());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: Text(qrcodeScanTitleTextLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                child: QRView(
                  key: _qrKey,
                  onQRViewCreated: _onQrViewCreated,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () async => await qrViewController.toggleFlash(),
                  child: Text(
                    torchButtonTextLanguageArray[languageArrayIdentifier],
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
