import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutteruvcapp/services/bleDeviceClass.dart';
import 'package:flutteruvcapp/services/uvcClass.dart';
import 'package:flutteruvcapp/services/uvcToast.dart';
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

  Map qrCodeClassData = {};

  @override
  void initState() {
    myUvcToast = ToastyMessage(toastContext: context);
    Future.delayed(const Duration(seconds: 1), () {
      _controller.resume();
      myUvcToast.setToastDuration(2);
      myUvcToast.setToastMessage('Opening the camera ,please wait!');
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
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double cameraViewHeight = screenHeight * 0.60;
    qrCodeClassData = qrCodeClassData.isNotEmpty ? qrCodeClassData : ModalRoute.of(context).settings.arguments;

    qrCodeConnectionOrSecurity = qrCodeClassData['qrCodeConnectionOrSecurity'];

    if (!qrCodeConnectionOrSecurity) {
      if (Platform.isAndroid) {
        scanDevices = qrCodeClassData['scanDevices'];
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
              Navigator.pushNamed(context, '/profiles', arguments: {
                'myDevice': myDevice,
                'dataRead': myDevice.getReadCharMessage(),
              });
            }
          }
        });
      }
    } else {
      myDevice = qrCodeClassData['myDevice'];
      myUvcLight = qrCodeClassData['myUvcLight'];
      _controller.onCapture((data) async {
        print('onCapture----$data');
        if (data.isNotEmpty) {
          print('is checking qrcode security');
          if (data.contains(uvcSecurityWebPage) && !(qrCodeValidOrNot)) {
            qrCodeValidOrNot = true;
            _controller.pause();
            if (myDevice.getConnectionState()) {
              String message = 'UVCTreatement : ON';
              if (Platform.isIOS) {
                await myDevice.writeCharacteristic(0, 0, message);
              } else {
                await myDevice.writeCharacteristic(2, 0, message);
              }
              Navigator.pushNamed(context, '/uvc', arguments: {
                'uvclight': myUvcLight,
                'myDevice': myDevice,
              });
            } else {
              myUvcToast.setToastDuration(5);
              myUvcToast.setToastMessage('Connexion perdue avec le robot !');
              myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
              myDevice.disconnect();
              Navigator.pushNamedAndRemoveUntil(context, "/bluetooth_activation", (r) => false);
            }
          }
        }
      });
    }

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Qr code Scan'),
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
                  'Merci de scanner le QR-CODE pour vous connecter dispositif UVC DEEPLIGHT',
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
      onWillPop: () =>_ackDisconnect(context),
    );
  }

  Future<bool> _ackDisconnect(BuildContext context) async{
    if(Platform.isIOS & (myDevice!=null)){
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
              Text('Valider la connexion au dispositif UVC DEEPLIGHT'),
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
                  // clear the remaining toast message
                  myUvcToast.clearAllToast();
                  String message = 'STOP : ON';
                  if (Platform.isIOS) {
                    await myDevice.writeCharacteristic(0, 0, message);
                  } else {
                    await myDevice.writeCharacteristic(2, 0, message);
                  }
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/profiles', arguments: {
                    'myDevice': myDevice,
                    'dataRead': myDevice.getReadCharMessage(),
                  });
                  //myDevice.disconnect();
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
