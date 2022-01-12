import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_master_uvc/services/DataVariables.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:package_info/package_info.dart';
import 'package:super_easy_permissions/super_easy_permissions.dart';
import 'package:wakelock/wakelock.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> with TickerProviderStateMixin {
  AnimationController controller;

  FlutterBlue flutterBlue = FlutterBlue.instance;

  void wakeLock() async {
    await Wakelock.enable();
    bool wakelockEnabled = await Wakelock.enabled;
    if (wakelockEnabled) {
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

  void _listenForPermissionStatus() async {
    bool result = await SuperEasyPermissions.askPermission(Permissions.camera);
    if (result) {
      SuperEasyPermissions.askPermission(Permissions.location).then((value) {
        if (value) {
          SuperEasyPermissions.askPermission(Permissions.locationAlways).then((value) {
            if (value) {
              SuperEasyPermissions.askPermission(Permissions.locationWhenInUse).then((value){
                if(value){
                  SuperEasyPermissions.askPermission(Permissions.bluetooth);
                }
              });
            }
          });
        }
      });
    } else {
      print("permission denied");
    }
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

    bool checkingBLEAndLocal = true;

    try {
      flutterBlue.state.listen((state) {
        if (checkingBLEAndLocal) {
          checkingBLEAndLocal = false;
          if (Platform.isAndroid) {
            _listenForPermissionStatus();
          }
          if (state == BluetoothState.off) {
            //Alert user to turn on bluetooth.
            Future.delayed(Duration(seconds: 5), () async {
              Navigator.pushReplacementNamed(context, '/check_permissions');
            });
          } else if (state == BluetoothState.on) {
            //if bluetooth is enabled then go ahead.
            //Make sure user's device gps is on.
            scanForDevices();
            Future.delayed(Duration(seconds: 5), () async {
              Navigator.pushReplacementNamed(context, '/qr_code_scan');
            });
          }
        }
      });
    } catch (e) {
      print('App not working !');
    }
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
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/logo_uv_c.png',
                      height: screenHeight * 0.15,
                      width: screenWidth * 0.7,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        appName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[300],
                          fontSize: screenWidth * 0.07,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: SpinKitCircle(
                  color: Colors.white,
                  size: screenHeight * 0.1,
                ),
              ),
              Expanded(
                flex: 2,
                child: Image.asset(
                  'assets/logo_deeplight.png',
                  height: screenHeight * 0.15,
                  width: screenWidth * 0.7,
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Powered by DELITECH Group',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: screenWidth * 0.04,
                        ),
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
            ],
          ),
        ),
      ),
    );
  }
}
