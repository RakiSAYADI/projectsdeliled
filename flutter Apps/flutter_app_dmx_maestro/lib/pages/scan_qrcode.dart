import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:qrcode/qrcode.dart';

class ScanQrCode extends StatefulWidget {
  @override
  _ScanQrCodeState createState() => _ScanQrCodeState();
}

class _ScanQrCodeState extends State<ScanQrCode> with SingleTickerProviderStateMixin {
  Map bleDeviceData = {};
  BluetoothDevice myDevice;
  BluetoothCharacteristic characteristicRelays;

  AnimationController animationController;
  Animation colorInfoQrCode;
  bool isItPausedOrResumed;

  QRCaptureController captureController = QRCaptureController();

  bool isTorchOn = false;

  String cameraMessage = '';
  String qrCodeMessage = '';
  Color colorMessage;
  int qrCodeScanCounter = 0;

  @override
  void initState() {
    super.initState();

    isItPausedOrResumed = true;
    animationController = AnimationController(vsync: this, duration: Duration(seconds: 10));
    colorInfoQrCode = animationColor(Colors.red, Colors.transparent);
    animationController.forward();

    captureController.onCapture((data) {
      print('onCapture----$data');
      if (data.isNotEmpty && qrCodeScanCounter == 0) {
        qrCodeScanCounter++;
        _ackAlert(data, context);
      }
    });
  }

  Animation animationColor(Color colorBegin, Color colorend) {
    return ColorTween(begin: colorBegin, end: colorend).animate(animationController)
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
  }

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    double cameraViewHeight = heightScreen * 0.60;
    print('$cameraViewHeight');

    bleDeviceData = bleDeviceData.isNotEmpty ? bleDeviceData : ModalRoute.of(context).settings.arguments;
    myDevice = bleDeviceData['bleDevice'];
    characteristicRelays = bleDeviceData['bleCharacteristic'];

    return WillPopScope(
      child: Scaffold(
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
      ),
      onWillPop: () => showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('Attention'),
          content: Text('Voulez-vous vraiment deconnecter du ${myDevice.name} ?'),
          actions: [
            FlatButton(
              child: Text('Oui'),
              onPressed: () {
                myDevice.disconnect();
                Navigator.pop(c, true);
              },
            ),
            FlatButton(
              child: Text('Non'),
              onPressed: () => Navigator.pop(c, false),
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
        FlatButton(
          onPressed: () {
            if (isTorchOn) {
              captureController.torchMode = CaptureTorchMode.off;
            } else {
              captureController.torchMode = CaptureTorchMode.on;
            }
            isTorchOn = !isTorchOn;
            setState(() {
              if (isTorchOn && isItPausedOrResumed) {
                colorInfoQrCode = animationColor(Colors.black, Colors.transparent);

                cameraMessage = 'Torch ON';
              }
              if ((!isTorchOn) && isItPausedOrResumed) {
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
    if (qrCodeData == 'hello' && qrCodeData.isNotEmpty) {
      qrCodeMessage = 'Access Valid';
      colorMessage = Colors.green;
    } else {
      qrCodeMessage = 'Access non Valid';
      colorMessage = Colors.red;
    }
    setState(() {
      colorMessage = colorMessage;
      qrCodeMessage = qrCodeMessage;
    });
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert'),
          content: Text('Voulez vous commander le maestro : ${myDevice.name} \nde l\'adresse : ${myDevice.id} ?'),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Annuler',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                qrCodeScanCounter = 0;
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                'Valider',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                qrCodeScanCounter = 0;
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/home', arguments: {
                  'bleCharacteristic': characteristicRelays,
                  'bleDevice': myDevice,
                });
              },
            ),
          ],
        );
      },
    );
  }
}
