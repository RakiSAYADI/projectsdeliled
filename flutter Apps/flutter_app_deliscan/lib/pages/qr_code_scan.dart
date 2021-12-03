import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_deliscan/services/DataVariables.dart';
import 'package:flutter_app_deliscan/services/languageDataBase.dart';
import 'package:flutter_app_deliscan/services/uvcToast.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrCodeScan extends StatefulWidget {
  @override
  _QrCodeScanState createState() => _QrCodeScanState();
}

class _QrCodeScanState extends State<QrCodeScan> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController controller;
  Barcode result;

  String qrCodeMessage = '';

  Color colorMessage;

  bool qrCodeScanAccess = false;
  bool deviceExistOrNot = false;

  ToastyMessage myUvcToast;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  @override
  void initState() {
    myUvcToast = ToastyMessage(toastContext: context);
    Future.delayed(const Duration(seconds: 1), () async {
      await controller.resumeCamera();
      myUvcToast.setToastDuration(2);
      myUvcToast.setToastMessage(cameraLaunchToastTextLanguageArray[languageArrayIdentifier]);
      myUvcToast.showToast(Colors.green, Icons.autorenew, Colors.white);
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onQrViewCreated(QRViewController controller) {
    this.controller = controller;
    String data;
    controller.scannedDataStream.listen((scanData) {
      data = result.code;
      print('onCapture----$data');
      if (data.isNotEmpty && !qrCodeScanAccess) {

        setState(() {
          if (deviceExistOrNot) {
            qrCodeMessage = validAccessTextLanguageArray[languageArrayIdentifier];
            colorMessage = Colors.green;
            qrCodeScanAccess = true;
          } else {
            qrCodeMessage = nonValidAccessTextLanguageArray[languageArrayIdentifier];
            colorMessage = Colors.red;
            qrCodeScanAccess = false;
          }
        });
        if (deviceExistOrNot) {
          controller.pauseCamera();
          Navigator.pushNamed(context, "/Qr_code_Generate_Full_Auto");
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
                key: qrKey,
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
                    qrCodeMessage,
                    style: TextStyle(
                      color: colorMessage,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextButton(
                        onPressed: () async {
                          await controller.toggleFlash();
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
