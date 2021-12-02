import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_master_uvc/services/DataVariables.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_app_master_uvc/services/uvcToast.dart';
import 'package:permission_handler/permission_handler.dart';

class CheckPermissions extends StatefulWidget {
  @override
  _CheckPermissionsState createState() => _CheckPermissionsState();
}

class _CheckPermissionsState extends State<CheckPermissions> with TickerProviderStateMixin {
  ToastyMessage myUvcToast;

  FlutterBlue flutterBlue = FlutterBlue.instance;

  bool firstDisplayMainWidget = true;

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

  void _listenForPermissionStatus() async {
    await [Permission.locationWhenInUse, Permission.locationAlways].request();
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Permissions'),
          centerTitle: true,
          backgroundColor: Color(0xFF554c9a),
        ),
        body: Container(
          decoration: BoxDecoration(color: Colors.grey[200]),
          child: Builder(
            builder: (context) {
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
                    TextButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
                        backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF554c9a)),
                      ),
                      child: Text(
                        'COMPRIS',
                        style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
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
          TextButton(
            child: Text('OK'),
            onPressed: () async {
              Navigator.pop(c, true);
              // Start scanning
              flutterBlue.startScan(timeout: Duration(seconds: 5));
              Navigator.pushNamed(context, '/qr_code_scan');
            },
          ),
          TextButton(
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
          TextButton(
            child: Text('Oui'),
            onPressed: () {
              Navigator.pop(c, true);
            },
          ),
          TextButton(
            child: Text('Non'),
            onPressed: () => Navigator.pop(c, false),
          ),
        ],
      ),
    );
  }
}
