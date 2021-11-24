import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/DataVariables.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/uvcToast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:qrcode_flutter/qrcode_flutter.dart';

class QrCodeScan extends StatefulWidget {
  @override
  _QrCodeScanState createState() => _QrCodeScanState();
}

class _QrCodeScanState extends State<QrCodeScan> with TickerProviderStateMixin {
  QRCaptureController _controller = QRCaptureController();
  bool _isTorchOn = false;
  String qrCodeMessage = '';
  Color colorMessage;
  bool qrCodeScanAccess = false;

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
  void initState() {
    myUvcToast = ToastyMessage(toastContext: context);
    Future.delayed(const Duration(seconds: 1), () {
      _controller.resume();
      myUvcToast.setToastDuration(2);
      myUvcToast.setToastMessage('Lancement de la caméra !');
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
    _controller.pause();
    animationRefreshIcon.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double cameraViewHeight = screenHeight * 0.60;

    _controller.onCapture((data) {
      print('onCapture----$data');
      if (data.isNotEmpty && !qrCodeScanAccess) {
        try {
          startIndex = data.indexOf(startMAC);
          endIndex = data.indexOf(endMAC, startIndex + startMAC.length);
          macAddress = data.substring(startIndex + startMAC.length, endIndex);
          startIndex = data.indexOf(startNAME);
          endIndex = data.indexOf(endNAME, startIndex + startNAME.length);
          uvcName = data.substring(startIndex + startNAME.length, endIndex);
          deviceExistOrNot = true;
        } catch (e) {
          try {
            startIndex = data.indexOf(startNAME);
            endIndex = data.indexOf(endNAME2, startIndex + startNAME.length);
            uvcName = data.substring(startIndex + startNAME.length, endIndex);
            deviceExistOrNot = true;
          } catch (e) {
            deviceExistOrNot = false;
          }
        }

        setState(() {
          if (deviceExistOrNot) {
            qrCodeMessage = 'Accès valide';
            colorMessage = Colors.green;
            qrCodeScanAccess = true;
          } else {
            qrCodeMessage = 'Accès non valide';
            colorMessage = Colors.red;
            qrCodeScanAccess = false;
          }
        });
        if (deviceExistOrNot) {
          _controller.pause();
          Navigator.pushNamed(context, "/Qr_code_Generate_Full_Auto");
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: const Text('Scanner le QR code'),
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
              child: QRCaptureView(
                controller: _controller,
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
          onPressed: () {
            if (_isTorchOn) {
              _controller.torchMode = CaptureTorchMode.off;
            } else {
              _controller.torchMode = CaptureTorchMode.on;
            }
            _isTorchOn = !_isTorchOn;
          },
          child: Text(
            'torch',
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

  Future<void> waitingWidget() async {
    //double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Connexion en cours'),
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
}
