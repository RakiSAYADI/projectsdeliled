import 'package:flutter/material.dart';
import 'package:flutterdmxapp/services/bleDeviceClass.dart';
import 'package:flutterdmxapp/services/uvcClass.dart';
import 'package:flutterdmxapp/services/uvcToast.dart';
import 'package:qrcode/qrcode.dart';

class ScanQrCodeSecurity extends StatefulWidget {
  @override
  _ScanQrCodeSecurityState createState() => _ScanQrCodeSecurityState();
}

class _ScanQrCodeSecurityState extends State<ScanQrCodeSecurity>
    with TickerProviderStateMixin {
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

  int devicesPosition = 0;
  bool qrCodeValidOrNot = false;

  AnimationController animationRefreshIcon;

  UvcLight myUvcLight;

  Map scanQrCodeSecurityClassData = {};

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

    Future.delayed(const Duration(seconds: 1), () async {
      captureController.resume();
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
    super.dispose();
    animationController.dispose();
    animationRefreshIcon.dispose();
  }

  @override
  Widget build(BuildContext context) {
    scanQrCodeSecurityClassData = scanQrCodeSecurityClassData.isNotEmpty
        ? scanQrCodeSecurityClassData
        : ModalRoute.of(context).settings.arguments;
    myDevice = scanQrCodeSecurityClassData['myDevice'];
    myUvcLight = scanQrCodeSecurityClassData['uvclight'];

    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    double cameraViewHeight = heightScreen * 0.60;
    print('$cameraViewHeight');
    captureController.onCapture((data) async {
      print('onCapture----$data');
      if (data.isNotEmpty) {
        print('is checking qrcode');
        if (data.contains('https://qrgo.page.link/hYgXu') &&
            !(qrCodeValidOrNot)) {
          qrCodeValidOrNot = true;
          String message = 'safetyTime : ON';
          await myDevice.writeCharacteristic(2, 0, message);
          Navigator.pushNamed(context, '/uvc', arguments: {
            'uvclight': myUvcLight,
            'myDevice': myDevice,
          });
        }
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
}
