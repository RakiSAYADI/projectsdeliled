import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutteruvcapp/services/uvcToast.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:location_permissions/location_permissions.dart';

class CheckPermissions extends StatefulWidget {
  @override
  _CheckPermissionsState createState() => _CheckPermissionsState();
}

class _CheckPermissionsState extends State<CheckPermissions> with TickerProviderStateMixin {
  ToastyMessage myUvcToast;

  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> scanDevices = [];

  bool firstDisplayMainWidget = true;

  PermissionStatus _permissionStatus = PermissionStatus.unknown;

  void scanForDevices() async {
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
    super.dispose();
  }

  void _listenForPermissionStatus() {
    final Future<PermissionStatus> statusFuture = LocationPermissions().checkPermissionStatus();

    statusFuture.then((PermissionStatus status) {
      setState(() {
        _permissionStatus = status;
        if (_permissionStatus.index != 2) {
          myUvcToast.setToastDuration(5);
          myUvcToast.setToastMessage('La localisation n\'est pas activée sur votre téléphone !');
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
        myUvcToast.setToastMessage('La localisation n\'est pas activée sur votre téléphone !');
        myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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

  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    // Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 5));
    if (Platform.isIOS) {
      Navigator.pushNamed(context, '/scan_ble_list');
    }
    if (Platform.isAndroid) {
      startScan(context);
    }
  }

  Widget _buildImage(String assetName) {
    return Align(
      child: Image.asset('assets/$assetName', width: 350.0),
      alignment: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.blue[400],
        appBar: AppBar(
          title: const Text('Permissions'),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(color: Colors.grey[200]),
          child: Builder(
            builder: (context) {
/*              return IntroductionScreen(
                key: introKey,
                pages: [
                  PageViewModel(
                    title: "Bienvenue",
                    body: "Bienvenue sur l'application DEEPLIGHT",
                    image: _buildImage('ic_launcher_UVC.png'),
                    decoration: pageDecoration,
                  ),
                  PageViewModel(
                    title: "Activation du Bluetooth",
                    body: "Afin de garantir le bon fonctionnement de l\'application merci d\'activer votre Bluetooth.",
                    image: _buildImage('loading_Bluetooth.gif'),
                    decoration: pageDecoration,
                  ),
                  PageViewModel(
                    title: "Activation du Location",
                    body: "Afin de garantir le bon fonctionnement de l\'application merci d\'activer votre Location.",
                    image: _buildImage('loading_Bluetooth.gif'),
                    decoration: pageDecoration,
                  ),
                  PageViewModel(
                    title: "Another title page",
                    body: "Another beautiful body text for this example onboarding",
                    image: _buildImage('img2'),
                    footer: RaisedButton(
                      onPressed: () {
                        introKey.currentState?.animateScroll(0);
                      },
                      child: const Text(
                        'FooButton',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.lightBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    decoration: pageDecoration,
                  ),*//*
                  PageViewModel(
                    title: "Title of last page",
                    bodyWidget: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text("Click on ", style: bodyStyle),
                        Icon(Icons.edit),
                        Text(" to edit a post", style: bodyStyle),
                      ],
                    ),
                    image: _buildImage('img1'),
                    decoration: pageDecoration,
                  ),
                ],
                onDone: () => _onIntroEnd(context),
                //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
                showSkipButton: true,
                skipFlex: 0,
                nextFlex: 0,
                skip: const Text('Passer'),
                next: const Icon(Icons.arrow_forward),
                done: const Text('COMPRIS', style: TextStyle(fontWeight: FontWeight.w600)),
                dotsDecorator: const DotsDecorator(
                  size: Size(10.0, 10.0),
                  color: Color(0xFFBDBDBD),
                  activeSize: Size(22.0, 10.0),
                  activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                ),
              );*/
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Afin de garantir le bon fonctionnement de l\'application merci d\'activer votre Bluetooth ainsi que votre localisation.',
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
