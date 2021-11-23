import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutteruvcapp/services/CSVfileClass.dart';
import 'package:flutteruvcapp/services/DataVariables.dart';
import 'package:flutteruvcapp/services/httpRequests.dart';
import 'package:flutteruvcapp/services/languageDataBase.dart';
import 'package:flutteruvcapp/services/life_cycle_widget.dart';
import 'package:flutteruvcapp/services/uvcToast.dart';
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

  DataBaseRequests dataBaseRequests = DataBaseRequests();

  UVCDataFile uvcDataFile = UVCDataFile();

  FlutterBlue flutterBlue = FlutterBlue.instance;

  PermissionStatus _permissionStatus = PermissionStatus.unknown;

  int loadingSeconds = 3;

  LifecycleEventHandler lifecycleEventHandler;

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
    flutterBlue.startScan(timeout: Duration(seconds: loadingSeconds));
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
          myUvcToast.setToastMessage(localisationToastLanguageArray[languageArrayIdentifier]);
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
        myUvcToast.setToastMessage(localisationToastLanguageArray[languageArrayIdentifier]);
        myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
      }
    });
  }

  void startApp() async {
    bool checkingBLEAndLocal = true;
    if (await uvcDataFile.fileExist('RapportUVC.csv')) {
      flutterBlue.state.listen((state) {
        if (checkingBLEAndLocal) {
          if (Platform.isAndroid) {
            _listenForPermissionStatus();
          }
          if (state == BluetoothState.off) {
            checkingBLEAndLocal = false;
            //Alert user to turn on bluetooth.
            if (Platform.isAndroid && _permissionStatus.index != 2) {
              Future.delayed(Duration(seconds: loadingSeconds), () async {
                Navigator.pushReplacementNamed(context, '/check_permissions');
              });
            } else {
              Future.delayed(Duration(seconds: loadingSeconds), () async {
                Navigator.pushReplacementNamed(context, '/check_permissions');
              });
            }
          } else if (state == BluetoothState.on) {
            checkingBLEAndLocal = false;
            //if bluetooth is enabled then go ahead.
            //Make sure user's device gps is on.
            scanForDevices();
            if (Platform.isAndroid) {
              Future.delayed(Duration(seconds: loadingSeconds), () async {
                flutterBlue.startScan(timeout: Duration(seconds: loadingSeconds));
                qrCodeConnectionOrSecurity = false;
                Navigator.pushNamed(context, '/qr_code_scan');
              });
            } else {
              Future.delayed(Duration(seconds: loadingSeconds), () async {
                Navigator.pushReplacementNamed(context, '/scan_ble_list');
              });
            }
          }
        }
      });
    } else {
      Future.delayed(Duration(seconds: loadingSeconds), () async {
        Navigator.pushReplacementNamed(context, '/tutorial_view');
      });
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

    scanDevices = [];

    lifecycleEventHandler = LifecycleEventHandler(resumeCallBack: () async {
      print('resumed');
    }, inactiveCallBack: () async {
      print('inactivated');
    }, pauseCallBack: () async {
      print('paused');
    }, suspendingCallBack: () async {
      print('suspended');
    });

    WidgetsBinding.instance.addObserver(lifecycleEventHandler);

    wakeLock();

    dataBaseRequests.checkInternetConnection();

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

    startApp();

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
                      'assets/ic_launcher_UVC.png',
                      height: screenHeight * 0.15,
                      width: screenWidth * 0.7,
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Text(
                      appName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[300],
                        fontSize: screenWidth * 0.07,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: SpinKitCircle(
                  color: Colors.white,
                  size: screenHeight * 0.2,
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/logo_deeplight.png',
                      height: screenHeight * 0.1,
                      width: screenWidth * 0.7,
                    ),
                    Text(
                      welcomePageLogoMessageLanguageArray[languageArrayIdentifier],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[300],
                        fontSize: screenWidth * 0.05,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Powered by DELITECH Group',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: screenWidth * 0.04,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
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
                            ),
                          );
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
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
