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

  String _qrCodeMessage = '';

  Color _colorMessage = Colors.white;

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
    controller.scannedDataStream.listen((scanData) {
      _result = scanData;
      print('onCapture----${_result.code}');
      if (_result.code.isNotEmpty && !qrCodeVerified) {
        if (_result.code.startsWith(qrCodeFirstPart) && _result.code.endsWith(qrCodeLastPart)) {
          pdfFileURL = _result.code;
          print("good qrcode ");
          qrCodeVerified = true;
        } else {
          print("bad qrcode ");
          qrCodeVerified = false;
        }
        setState(() {
          if (qrCodeVerified) {
            _qrCodeMessage = validAccessTextLanguageArray[languageArrayIdentifier];
            _colorMessage = Colors.green;
          } else {
            _qrCodeMessage = nonValidAccessTextLanguageArray[languageArrayIdentifier];
            _colorMessage = Colors.red;
          }
        });
        if (qrCodeVerified) {
          controller.pauseCamera();
          createRoute(context, PDFViewer());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double cameraViewHeight = screenHeight * 0.60;

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
            SizedBox(height: screenHeight * 0.02),
            Container(
              width: screenWidth,
              height: cameraViewHeight,
              child: QRView(
                key: _qrKey,
                onQRViewCreated: _onQrViewCreated,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    _qrCodeMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenHeight * 0.02,
                      color: _colorMessage,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextButton(
                        onPressed: () async {
                          await qrViewController.toggleFlash();
                        },
                        child: Text(
                          torchButtonTextLanguageArray[languageArrayIdentifier],
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
