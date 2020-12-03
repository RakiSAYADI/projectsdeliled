import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_app_master_uvc/services/bleDeviceClass.dart';
import 'package:flutter_app_master_uvc/services/uvcClass.dart';
import 'package:flutter_app_master_uvc/services/uvcToast.dart';
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

  List<BluetoothDevice> scanDevices = [];
  Device myDevice;
  int devicesPosition = 0;
  bool deviceExistOrNot = false;

  AnimationController animationController;
  AnimationController animationRefreshIcon;

  final String uvcSecurityWebPage = 'https://qrgo.page.link/hYgXu';

  UvcLight myUvcLight;

  bool qrCodeConnectionOrSecurity = false;
  bool qrCodeValidOrNot = false;
  bool qrCodeSettings = false;

  Map qrCodeClassData = {};

  Map<String, dynamic> dataRead;
  Map<String, dynamic> dataUVC;

  String myName = '';
  String myCompany = '';
  String myRoom = '';
  int extinctionTime;
  int activationTime;

  List<String> myExtinctionTimeMinute = [
    ' 30 sec',
    '  1 min',
    '  2 min',
    '  5 min',
    ' 10 min',
    ' 15 min',
    ' 20 min',
    ' 25 min',
    ' 30 min',
    ' 35 min',
    ' 40 min',
    ' 45 min',
    ' 50 min',
    ' 55 min',
    ' 60 min',
    ' 65 min',
    ' 70 min',
    ' 75 min',
    ' 80 min',
    ' 85 min',
    ' 90 min',
    ' 95 min',
    '100 min',
    '105 min',
    '110 min',
    '115 min',
    '120 min',
  ];

  List<String> myActivationTimeMinute = [
    ' 10 sec',
    ' 20 sec',
    ' 30 sec',
    ' 40 sec',
    ' 50 sec',
    ' 60 sec',
    ' 70 sec',
    ' 80 sec',
    ' 90 sec',
    '100 sec',
    '110 sec',
    '120 sec',
  ];

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
    qrCodeClassData = qrCodeClassData.isNotEmpty ? qrCodeClassData : ModalRoute.of(context).settings.arguments;

    if (Platform.isAndroid) {
      scanDevices = qrCodeClassData['scanDevices'];
      _controller.resume();
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
            _ackAlert(data, context);
          }
        }
      });
    }
    if (Platform.isIOS) {
      myDevice = qrCodeClassData['myDevice'];
      _controller.resume();
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
            qrCodeScanAccess = false;
            Future.delayed(const Duration(seconds: 2), () async {
              // Read data from robot
              await myDevice.readCharacteristic(0, 0);
              // clear the remaining toast message
              myUvcToast.clearAllToast();
              Navigator.pushNamed(context, '/home', arguments: {
                'myDevice': myDevice,
                'dataRead': myDevice.getReadCharMessage(),
              });
            });
          }
        }
      });
    }

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF554c9a),
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
      ),
      onWillPop: () => _ackDisconnect(context),
    );
  }

  Future<bool> _ackDisconnect(BuildContext context) async {
    if (myDevice != null) {
      myDevice.disconnect();
    }

    Navigator.pop(context, true);
    return true;
  }

  Widget _buildToolBar() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FlatButton(
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

  Future<void> _ackAlert(String qrCodeData, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
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
              Text('Veuillez rester près du dispositif UV-C pendant quelques instants, la connexion est en cours.'),
              Image.asset(
                'assets/connexion_dispositif.gif',
                height: screenHeight * 0.3,
                width: screenWidth * 0.8,
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'OK',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () async {
                qrCodeScanAccess = false;
                animationRefreshIcon.repeat();
                await Future.delayed(const Duration(milliseconds: 400));
                myUvcToast.setAnimationIcon(animationRefreshIcon);
                myUvcToast.setToastDuration(60);
                myDevice = Device(device: scanDevices.elementAt(devicesPosition));
                myUvcToast.setToastMessage('Autorisation de connexion validée !');
                myUvcToast.showToast(Colors.green, Icons.autorenew, Colors.white);
                // stop scanning and start connecting
                await myDevice.connect(false);
                Future.delayed(const Duration(seconds: 2), () async {
                  // Read data from robot
                  await myDevice.readCharacteristic(2, 0);
                  myUvcToast.clearAllToast();
                  Navigator.pushNamed(context, '/home', arguments: {
                    'myDevice': myDevice,
                    'dataRead': myDevice.getReadCharMessage(),
                  });
                });
              },
            ),
            FlatButton(
              child: Text(
                'Annuler',
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
