import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutteruvcapp/services/uvcToast.dart';
import 'package:location_permissions/location_permissions.dart';

class BluetoothActivation extends StatefulWidget {
  @override
  _BluetoothActivationState createState() => _BluetoothActivationState();
}

class _BluetoothActivationState extends State<BluetoothActivation> with TickerProviderStateMixin {
  ToastyMessage myUvcToast;

  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> scanDevices = [];

  bool firstDisplayMainWidget = true;

  Widget _myAnimationWidget;

  AnimationController _controller;
  Animation<double> _animation;

  PermissionStatus _permissionStatus = PermissionStatus.unknown;

  bool changeWidget = false;
  bool pageDisposed = false;

  void scanForDevices() async {
    PermissionStatus permission = await LocationPermissions().checkPermissionStatus();
    // Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 5));
    // Listen to scan results
    flutterBlue.scanResults.listen((results) {
      scanDevices.clear();
      // do something with scan results
      for (ScanResult r in results) {
        print('${r.device.name} found! mac: ${r.device.id.toString()}');
        if (scanDevices.isEmpty) {
          scanDevices.add(r.device);
        } else {
          if (!scanDevices.contains(r.device)) {
            scanDevices.add(r.device);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    pageDisposed = true;
    super.dispose();
  }

  void _listenForPermissionStatus() {
    final Future<PermissionStatus> statusFuture = LocationPermissions().checkPermissionStatus();

    statusFuture.then((PermissionStatus status) {
      setState(() {
        _permissionStatus = status;
        if (_permissionStatus.index != 2) {
          myUvcToast.setToastDuration(5);
          myUvcToast.setToastMessage('La Localisation n\'est pas autorisée sur votre téléphone !');
          myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
        } else {
          checkServiceStatus(context);
        }
      });
    });
  }

  void checkServiceStatus(BuildContext context) {
    LocationPermissions().checkServiceStatus().then((ServiceStatus serviceStatus) {
      if (serviceStatus.index != 2) {
        myUvcToast.setToastDuration(5);
        myUvcToast.setToastMessage('La Localisation n\'est pas activée sur votre téléphone !');
        myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
      }
    });
  }

  void animationControl() async {
    _controller.repeat(reverse: true);
    while (true) {
      await Future.delayed(Duration(seconds: 6), () async {
        setState(() {
          changeWidget = !changeWidget;
          if (changeWidget) {
            _myAnimationWidget = locationWidget(context);
          } else {
            _myAnimationWidget = bluetoothWidget(context);
          }
        });
        _controller.repeat(reverse: true);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
    myUvcToast = ToastyMessage(toastContext: context);
    _listenForPermissionStatus();
    flutterBlue.state.listen((state) {
      if (state == BluetoothState.off) {
        //Alert user to turn on bluetooth.
        print("Bluetooth is off");
        myUvcToast.setToastDuration(5);
        myUvcToast.setToastMessage('Le Bluetooth (BLE) n\'est pas activé sur votre téléphone !');
        myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
      } else if (state == BluetoothState.on) {
        //if bluetooth is enabled then go ahead.
        //Make sure user's device gps is on.
        flutterBlue = FlutterBlue.instance;
        print("Bluetooth is on");
        scanForDevices();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    if (firstDisplayMainWidget) {
      firstDisplayMainWidget = false;
      pageDisposed = false;
      _myAnimationWidget = bluetoothWidget(context);
      animationControl();
    }

    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.blue[400],
        appBar: AppBar(
          title: const Text('Bluetooth'),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(color: Colors.grey[200]),
          child: Builder(
            builder: (context) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AnimatedSwitcher(
                      duration: Duration(seconds: 2),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: _animation,
                          child: _myAnimationWidget,
                        );
                      },
                      child: _myAnimationWidget,
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    FlatButton(
                      color: Colors.blue[400],
                      child: Text(
                        'COMPRIS',
                        style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      onPressed: () {
                        // Start scanning
                        flutterBlue.startScan(timeout: Duration(seconds: 5));
                        if (Platform.isIOS) {
                          Navigator.pushNamed(context, '/scan_ble_list');
                        }
                        if (Platform.isAndroid) {
                          startScan(context);
                        }
                      },
                    ),
                    SizedBox(height: screenHeight * 0.05),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      onWillPop: () => stopActivity(context),
    );
  }

  Widget locationWidget(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Afin de garantir le bon fonctionnement de l\'application merci d\'activer votre Location.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: screenWidth * 0.04,
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.05),
        Image.asset(
          'assets/loading_Bluetooth.gif',
          height: screenHeight * 0.3,
          width: screenWidth * 0.8,
        ),
      ],
    );
  }

  Widget bluetoothWidget(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Afin de garantir le bon fonctionnement de l\'application merci d\'activer votre Bluetooth.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: screenWidth * 0.04,
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.05),
        Image.asset(
          'assets/loading_Bluetooth.gif',
          height: screenHeight * 0.3,
          width: screenWidth * 0.8,
        ),
      ],
    );
  }

  Future<void> startScan(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Scanner le QR code du dispositif UV-C DEEPLIGHT.'),
            Image.asset(
              'assets/scan_qr_code.gif',
              height: screenHeight * 0.3,
              width: screenWidth * 0.8,
            ),
          ],
        ),
        actions: [
          FlatButton(
            child: Text('OK'),
            onPressed: () async {
              Navigator.pop(c, true);
              // Start scanning
              flutterBlue.startScan(timeout: Duration(seconds: 5));
              pageDisposed = true;
              Navigator.pushNamed(context, '/qr_code_scan', arguments: {
                'scanDevices': scanDevices,
                'qrCodeConnectionOrSecurity': false,
              });
            },
          ),
          FlatButton(
            child: Text('Annuler'),
            onPressed: () => Navigator.pop(c, false),
          ),
        ],
      ),
    );
  }

  Future<void> stopActivity(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Attention'),
        content: Text('Voulez-vous vraiment quitter l\'application ?'),
        actions: [
          FlatButton(
            child: Text('Oui'),
            onPressed: () {
              Navigator.pop(c, true);
            },
          ),
          FlatButton(
            child: Text('Non'),
            onPressed: () => Navigator.pop(c, false),
          ),
        ],
      ),
    );
  }
}
