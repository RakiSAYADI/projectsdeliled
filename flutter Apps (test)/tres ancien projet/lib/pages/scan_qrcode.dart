import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutterdmxapp/services/bleDeviceClass.dart';
import 'package:flutterdmxapp/services/uvcToast.dart';
import 'package:qrcode/qrcode.dart';

class ScanQrCode extends StatefulWidget {
  @override
  _ScanQrCodeState createState() => _ScanQrCodeState();
}

class _ScanQrCodeState extends State<ScanQrCode> with TickerProviderStateMixin {
  AnimationController animationController;
  Animation colorInfoQrCode;

  QRCaptureController captureController = QRCaptureController();

  bool isTorchOn = false;

  String cameraMessage = '';
  String qrCodeMessage = '';
  Color colorMessage;
  bool qrCodeScanAccess = false;

  ToastyMessage myUvcToast;

  Device myDevice;
  List<BluetoothDevice> scanDevices = [];

  int devicesPosition = 0;
  bool deviceExistOrNot = false;

  AnimationController animationRefreshIcon;

  Map qrCodeClassData = {};

  @override
  void initState() {
    super.initState();
    // initialise the animation
    animationRefreshIcon = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 3),
    );
    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 10));
    colorInfoQrCode = animationColor(Colors.red, Colors.transparent);
    animationController.forward();

    animationRefreshIcon.repeat();
    Future.delayed(const Duration(seconds: 1), () {
      captureController.resume();
      myUvcToast = ToastyMessage(toastContext: context);
      myUvcToast.setAnimationIcon(animationRefreshIcon);
      myUvcToast.setToastDuration(2);
      myUvcToast.setToastMessage('Opening the camera ,please wait!');
      myUvcToast.showToast(Colors.green, Icons.autorenew, Colors.white);
    });
  }

  Animation animationColor(Color colorBegin, Color colorend) {
    return ColorTween(begin: colorBegin, end: colorend)
        .animate(animationController)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              animationController.reverse();
            } else if (status == AnimationStatus.dismissed) {
              animationController.forward();
            }
          });
  }

  @override
  void dispose() {
    animationController.dispose();
    animationRefreshIcon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    qrCodeClassData = qrCodeClassData.isNotEmpty
        ? qrCodeClassData
        : ModalRoute.of(context).settings.arguments;
    scanDevices = qrCodeClassData['scanDevices'];

    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    double cameraViewHeight = heightScreen * 0.60;
    print('$cameraViewHeight');
    captureController.onCapture((data) async {
      print('onCapture----$data');
      if (data.isNotEmpty && !qrCodeScanAccess) {
        print('is checking qrcode');
        for (int i = 0; i < scanDevices.length; i++) {
          if (scanDevices.elementAt(i).id.toString().contains(data)) {
            deviceExistOrNot = true;
            devicesPosition = i;
            break;
          } else {
            deviceExistOrNot = false;
          }
        }
        if (deviceExistOrNot) {
          qrCodeMessage = 'Access Valid';
          colorMessage = Colors.green;
          qrCodeScanAccess = true;
          _ackAlert(data, context);
        } else {
          qrCodeMessage = 'Access non Valid';
          colorMessage = Colors.red;
          qrCodeScanAccess = false;
        }
        setState(() {
          colorMessage = colorMessage;
          qrCodeMessage = qrCodeMessage;
        });
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qr code Scan'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fondapplication.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                'Merci de scanner le QR-CODE pour vous connecter au boitier',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 20.0,
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: widthScreen,
              height: cameraViewHeight,
              child: QRCaptureView(
                controller: captureController,
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  SizedBox(height: 20),
                  Text(
                    qrCodeMessage,
                    style: TextStyle(
                      color: colorMessage,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildToolBar(),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: colorInfoQrCode,
              builder: (context, child) => Container(
                child: Text(
                  '$cameraMessage',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorInfoQrCode.value,
                  ),
                ),
              ),
            )
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
        FlatButton(
          onPressed: () {
            if (isTorchOn) {
              captureController.torchMode = CaptureTorchMode.off;
            } else {
              captureController.torchMode = CaptureTorchMode.on;
            }
            isTorchOn = !isTorchOn;
            setState(() {
              if (isTorchOn) {
                colorInfoQrCode =
                    animationColor(Colors.black, Colors.transparent);

                cameraMessage = 'Torch ON';
              }
              if ((!isTorchOn)) {
                cameraMessage = '';
              }
            });
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

  Future<void> _ackAlert(String qrCodeData, BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Robot UV-C :'),
          content: Text(
              'Vous êtes sur le point de vous connecter au robot : ${scanDevices.elementAt(devicesPosition).name}'
              ' d\'addresse : ${scanDevices.elementAt(devicesPosition).id.toString()}'),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Annuler',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                qrCodeScanAccess = false;
                scanDevices.clear();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                'Valider',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () async {
                qrCodeScanAccess = false;
                myUvcToast.clearAllToast();
                animationRefreshIcon.repeat();
                myUvcToast = ToastyMessage(toastContext: context);
                myUvcToast.setAnimationIcon(animationRefreshIcon);
                myUvcToast.setToastDuration(60);
                myDevice =
                    Device(device: scanDevices.elementAt(devicesPosition));
                myUvcToast
                    .setToastMessage('Connecting to ${myDevice.device.name} !');
                myUvcToast.showToast(
                    Colors.green, Icons.autorenew, Colors.white);
                // stop scanning and start connecting
                await myDevice.connect(false);
                Future.delayed(const Duration(seconds: 1), () async {
                  // clear the remaining toast message
                  myUvcToast.clearAllToast();
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/settings', arguments: {
                    'myDevice': myDevice,
                  });
                  //myDevice.disconnect();
                });
              },
            ),
          ],
        );
      },
    );
  }
}
