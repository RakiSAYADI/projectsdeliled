import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_master_uvc/services/uvcToast.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:package_info/package_info.dart';
import 'package:wakelock/wakelock.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> with TickerProviderStateMixin {
  AnimationController controller;

  ToastyMessage myUvcToast;

  FlutterBlue flutterBlue = FlutterBlue.instance;

  List<BluetoothDevice> scanDevices = [];

  PermissionStatus _permissionStatus = PermissionStatus.unknown;

  void wakeLock() async {
    await Wakelock.enable();
    bool wakelockEnabled = await Wakelock.enabled;
    if (wakelockEnabled) {
      // The following statement disables the wakelock.
      Wakelock.toggle(enable: true);
    }
    print('screen lock is disabled');
  }

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
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    wakeLock();

    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );

    if (Platform.isAndroid) {
      print('android');
    }
    if (Platform.isIOS) {
      print('ios');
    }
    if (Platform.isWindows) {
      print('windows');
    }
    if (Platform.isLinux) {
      print('linux');
    }
    if (Platform.isMacOS) {
      print('macos');
    }

    myUvcToast = ToastyMessage(toastContext: context);

    bool checkingBLEAndLocal = true;

    flutterBlue.state.listen((state) {
      if (checkingBLEAndLocal) {
        checkingBLEAndLocal = false;
        if (Platform.isAndroid) {
          _listenForPermissionStatus();
        }
        if (state == BluetoothState.off) {
          //Alert user to turn on bluetooth.
          if (Platform.isAndroid && _permissionStatus.index != 2) {
            Future.delayed(Duration(seconds: 5), () async {
              Navigator.pushReplacementNamed(context, '/check_permissions');
            });
          } else {
            Future.delayed(Duration(seconds: 5), () async {
              Navigator.pushReplacementNamed(context, '/check_permissions');
            });
          }
        } else if (state == BluetoothState.on) {
          //if bluetooth is enabled then go ahead.
          //Make sure user's device gps is on.
          scanForDevices();
          Future.delayed(Duration(seconds: 5), () async {
            Navigator.pushReplacementNamed(context, '/qr_code_scan', arguments: {
              'scanDevices': scanDevices,
              'qrCodeConnectionOrSecurity': false,
            });
          });
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    print('width : $screenWidth and height : $screenHeight');
    return Scaffold(
      backgroundColor: Colors.indigo[700],
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/fondapplication.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/logo_uv_c.png',
                height: screenHeight * 0.15,
                width: screenWidth * 0.7,
              ),
              SizedBox(height: screenHeight * 0.02),
              Image.asset(
                'assets/logo_deeplight.png',
                height: screenHeight * 0.15,
                width: screenWidth * 0.7,
              ),
              SizedBox(height: screenHeight * 0.1),
              SpinKitCircle(
                color: Color(0xFF554c9a),
                size: screenHeight * 0.1,
              ),
              SizedBox(height: screenHeight * 0.1),
              Image.asset(
                'assets/logodelitechblanc.png',
                height: screenHeight * 0.15,
                width: screenWidth * 0.7,
              ),
              SizedBox(height: screenHeight * 0.05),
              Text(
                'Powered by DELITECH Group',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: screenWidth * 0.04,
                ),
              ),
              FutureBuilder(
                  future: PackageInfo.fromPlatform(),
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.hasData) {
                      String version = snapshot.data.version;
                      return Center(
                          child: Text(
                        '$version',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: screenWidth * 0.04,
                        ),
                      ));
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
