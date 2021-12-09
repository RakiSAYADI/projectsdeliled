import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_master_uvc/services/DataVariables.dart';
import 'package:flutter_app_master_uvc/services/bleDeviceClass.dart';
import 'package:flutter_app_master_uvc/services/languageDataBase.dart';
import 'package:flutter_app_master_uvc/services/uvcToast.dart';
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

  int devicesPosition = 0;
  bool deviceExistOrNot = false;

  AnimationController animationController;
  AnimationController animationRefreshIcon;

  @override
  void initState() {
    myUvcToast = ToastyMessage(toastContext: context);
    Future.delayed(const Duration(seconds: 1), () {
      _controller.resume();
      myUvcToast.setToastDuration(2);
      myUvcToast.setToastMessage(cameraStartToastTextLanguageArray[languageArrayIdentifier]);
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

    if (Platform.isAndroid) {
      _controller.onCapture((data) {
        print('onCapture----$data');
        if (data.isNotEmpty && !qrCodeScanAccess) {
          print('is checking qrcode android');
          for (int i = 0; i < scanDevices.length; i++) {
            if (data.contains(scanDevices.elementAt(i).id.toString())) {
              deviceExistOrNot = true;
              devicesPosition = i;
              break;
            } else {
              deviceExistOrNot = false;
            }
          }
          setState(() {
            if (deviceExistOrNot) {
              qrCodeMessage = qrCodeValidMessageTextLanguageArray[languageArrayIdentifier];
              colorMessage = Colors.green;
              qrCodeScanAccess = true;
            } else {
              qrCodeMessage = qrCodeNonValidMessageTextLanguageArray[languageArrayIdentifier];
              colorMessage = Colors.red;
              qrCodeScanAccess = false;
            }
          });
          if (deviceExistOrNot) {
            _controller.pause();
            _ackAlert(data, context);
          }
        }
      });
    }
    if (Platform.isIOS) {
      _controller.onCapture((data) {
        print('onCapture----$data');
        if (data.isNotEmpty && !qrCodeScanAccess) {
          print('is checking qrcode ios');
          if (data.contains(myDevice.device.name)) {
            deviceExistOrNot = true;
          } else {
            deviceExistOrNot = false;
          }
          setState(() {
            if (deviceExistOrNot) {
              qrCodeMessage = qrCodeValidMessageTextLanguageArray[languageArrayIdentifier];
              colorMessage = Colors.green;
              qrCodeScanAccess = true;
            } else {
              qrCodeMessage = qrCodeNonValidMessageTextLanguageArray[languageArrayIdentifier];
              colorMessage = Colors.red;
              qrCodeScanAccess = false;
            }
          });
          if (deviceExistOrNot) {
            _controller.pause();
            qrCodeScanAccess = false;
            Future.delayed(const Duration(seconds: 2), () async {
              // Read data from robot
              await myDevice.readCharacteristic(0, 0);
              // clear the remaining toast message
              myUvcToast.clearAllToast();
              dataRobotUVC = myDevice.getReadCharMessage();
              Navigator.pushNamed(context, '/home');
            });
          }
        }
      });
    }

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF554c9a),
          title: Text(cameraPageTitleTextLanguageArray[languageArrayIdentifier]),
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
      ),
      onWillPop: () => stopActivity(context),
    );
  }

  Future<void> stopActivity(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(attentionTextLanguageArray[languageArrayIdentifier]),
        content: Text(stopActivityAlertDialogMessageTextLanguageArray[languageArrayIdentifier]),
        actions: [
          TextButton(
            child: Text(yesTextLanguageArray[languageArrayIdentifier]),
            onPressed: () {
              if (myDevice != null) {
                myDevice.disconnect();
              }
              Navigator.pop(c, true);
            },
          ),
          TextButton(
            child: Text(noTextLanguageArray[languageArrayIdentifier]),
            onPressed: () => Navigator.pop(c, false),
          ),
        ],
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
            cameraPageTorchButtonTextLanguageArray[languageArrayIdentifier],
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
    double screenHeight = MediaQuery.of(context).size.height;
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(checkConnectionAlertDialogTitleTextLanguageArray[languageArrayIdentifier]),
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

  Future<void> _ackAlert(String qrCodeData, BuildContext myContext) {
    double screenWidth = MediaQuery.of(myContext).size.width;
    double screenHeight = MediaQuery.of(myContext).size.height;
    return showDialog<void>(
      context: myContext,
      barrierDismissible: false,
      builder: (BuildContext myContext) {
        return AlertDialog(
          title: Text(checkConnectionAlertDialogTitleTextLanguageArray[languageArrayIdentifier]),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(checkConnectionAlertDialogMessageTextLanguageArray[languageArrayIdentifier]),
              Image.asset(
                'assets/connexion_dispositif.gif',
                height: screenHeight * 0.3,
                width: screenWidth * 0.8,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                okTextLanguageArray[languageArrayIdentifier],
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () async {
                Navigator.of(myContext).pop();
                waitingWidget();
                qrCodeScanAccess = false;
                animationRefreshIcon.repeat();
                await Future.delayed(const Duration(milliseconds: 400));
                myUvcToast.setAnimationIcon(animationRefreshIcon);
                myUvcToast.setToastDuration(60);
                myDevice = Device(device: scanDevices.elementAt(devicesPosition));
                myUvcToast.setToastMessage(authoriseConnectionToastTextLanguageArray[languageArrayIdentifier]);
                myUvcToast.showToast(Colors.green, Icons.autorenew, Colors.white);
                // stop scanning and start connecting
                while (true) {
                  myDevice.connect(false);
                  await Future.delayed(Duration(milliseconds: 2200));
                  print('result of trying connection is ${myDevice.getConnectionState()}');
                  if (myDevice.getConnectionState()) {
                    break;
                  } else {
                    myDevice.disconnect();
                    await Future.delayed(Duration(milliseconds: 2200));
                  }
                }
                if (myDevice.getConnectionState()) {
                  Future.delayed(const Duration(seconds: 2), () async {
                    // Read data from robot
                    await myDevice.readCharacteristic(2, 0);
                    Navigator.of(context).pop();
                    myUvcToast.clearAllToast();
                    dataRobotUVC = myDevice.getReadCharMessage();
                    Navigator.pushNamed(context, '/home');
                  });
                }
              },
            ),
            TextButton(
              child: Text(
                cancelTextLanguageArray[languageArrayIdentifier],
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                _controller.resume();
                qrCodeScanAccess = false;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
