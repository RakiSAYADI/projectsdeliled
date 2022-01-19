import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/DataVariables.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/languageDataBase.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/uvcToast.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrCodeScan extends StatefulWidget {
  @override
  _QrCodeScanState createState() => _QrCodeScanState();
}

class _QrCodeScanState extends State<QrCodeScan> with TickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode result;

  String qrCodeMessage = '';
  Color colorMessage;

  ToastyMessage myUvcToast;

  bool deviceExistOrNot = false;

  AnimationController animationController;
  AnimationController animationRefreshIcon;

  int startIndex;
  int endIndex;

  final String startMAC = "(";
  final String endMAC = ")";
  final String startNAME = "+";
  final String endNAME = "+";
  final String endNAME2 = "https";

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
    // initialise the animation
    animationRefreshIcon = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 3),
    );
    animationController = AnimationController(vsync: this, duration: Duration(seconds: 10));
    animationController.forward();
    animationRefreshIcon.repeat();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    animationRefreshIcon.dispose();
    animationController.dispose();
    super.dispose();
  }

  void _onQrViewCreated(QRViewController qrViewController) {
    controller = qrViewController;
    qrViewController.scannedDataStream.listen((scanData) {
      result = scanData;
      print('onCapture----${result.code}');
      if (result.code.isNotEmpty && !qrCodeScanAccess) {
        try {
          startIndex = result.code.indexOf(startMAC);
          endIndex = result.code.indexOf(endMAC, startIndex + startMAC.length);
          macAddress = result.code.substring(startIndex + startMAC.length, endIndex);
          startIndex = result.code.indexOf(startNAME);
          endIndex = result.code.indexOf(endNAME, startIndex + startNAME.length);
          uvcName = result.code.substring(startIndex + startNAME.length, endIndex);
          deviceExistOrNot = true;
        } catch (e) {
          try {
            startIndex = result.code.indexOf(startNAME);
            endIndex = result.code.indexOf(endNAME2, startIndex + startNAME.length);
            uvcName = result.code.substring(startIndex + startNAME.length, endIndex);
            deviceExistOrNot = true;
          } catch (e) {
            deviceExistOrNot = false;
          }
        }

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
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: screenWidth * 0.04,
                ),
              ),
            ),
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
                  _buildToolBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolBar() {
    return Row(
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
    );
  }

  Animation animationColor(Color colorBegin, Color colorEnd) {
    return ColorTween(begin: colorBegin, end: colorEnd).animate(animationController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          animationController.forward();
        }
      });
  }
}
