import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutteruvcapp/services/uvcToast.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:flutteruvcapp/services/DataVariables.dart';
import 'package:package_info/package_info.dart';

class TutorialView extends StatefulWidget {
  @override
  _TutorialViewState createState() => _TutorialViewState();
}

class _TutorialViewState extends State<TutorialView> {
  ToastyMessage myUvcToast;

  FlutterBlue flutterBlue = FlutterBlue.instance;

  bool firstDisplayMainWidget = true;

  PermissionStatus _permissionStatus = PermissionStatus.unknown;

  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    // Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 5));
    flutterBlue.state.listen((state) {
      if (state == BluetoothState.off) {
        Navigator.pushNamed(context, '/check_permissions');
      }
      if (state == BluetoothState.on) {
        if (Platform.isIOS) {
          Navigator.pushNamed(context, '/scan_ble_list');
        }
        if (Platform.isAndroid) {
          // Start scanning
          flutterBlue.startScan(timeout: Duration(seconds: 5));
          qrCodeConnectionOrSecurity = false;
          Navigator.pushNamed(context, '/qr_code_scan');
        }
      }
    });
  }

  Widget _buildImage(String assetName) {
    //double screenHeight = MediaQuery.of(context).size.height;
    return Align(
      child: Image.asset('assets/$assetName'),
      alignment: Alignment.bottomCenter,
    );
  }

  void scanForDevices() {
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

  void _listenForPermissionStatusAndAppName() async {
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
    myUvcToast = ToastyMessage(toastContext: context);
    _listenForPermissionStatusAndAppName();
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
    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.blue[400],
        appBar: AppBar(
          title: const Text('Tutoriel'),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(color: Colors.grey[200]),
          child: Builder(
            builder: (context) {
              return IntroductionScreen(
                key: introKey,
                pages: [
                  PageViewModel(
                    image: _buildImage('TUTO-01.png'),
                    titleWidget: FutureBuilder(
                        future: PackageInfo.fromPlatform(),
                        builder: (BuildContext context, snapshot) {
                          if (snapshot.hasData) {
                            String data = "Merci d’avoir installé l’application ${snapshot.data.appName} !";
                            return Center(
                                child: Text(
                              '$data',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: screenWidth * 0.06 + screenHeight * 0.012,
                              ),
                            ));
                          } else {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        }),
                    body: "Nous allons vous montrer comment vous en servir en toute sécurité.",
                    decoration: pageDecoration,
                  ),
                  PageViewModel(
                    image: _buildImage('TUTO-02.png'),
                    title: "Brancher le matériel.",
                    body: "Tout d’abord, veuillez à ce que votre solution UV-C DEEPLIGHT® soit correctement raccordée à l’alimentation."
                        " Si vous avez des solutions auxiliaires veuillez également les connecter.",
                    decoration: pageDecoration,
                  ),
                  PageViewModel(
                    image: _buildImage('TUTO-03.png'),
                    title: "Connecter une solution UV-C DEEPLIGHT®.",
                    body: "Scannez l’étiquette présente sur la solution de désinfection quand il vous le sera demandé "
                        "afin que nous puissions reconnaître le produit utilisé.",
                    decoration: pageDecoration,
                  ),
                  PageViewModel(
                    image: _buildImage('TUTO-04.png'),
                    title: "Définir vos besoins.",
                    body: "Indiquez ensuite les données de désinfection comme le nom de l’entreprise, "
                        "le nom de l’opérateur et la durée de désinfection.",
                    decoration: pageDecoration,
                  ),
                  PageViewModel(
                    image: _buildImage('TUTO-05.png'),
                    title: "C'est presque fini !",
                    body: "Il ne vous restera plus qu’à scanner le QR code de sécurité et lancer la désinfection !",
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
                dotsDecorator: DotsDecorator(
                  size: Size(screenWidth * 0.01, screenHeight * 0.01),
                  color: Color(0xFFBDBDBD),
                  activeSize: Size(screenWidth * 0.022, screenHeight * 0.010),
                  activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                ),
              );
            },
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
