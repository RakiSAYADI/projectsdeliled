import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterappdentaluvc/services/CSVfileClass.dart';
import 'package:flutterappdentaluvc/services/LEDControl.dart';
import 'package:flutterappdentaluvc/services/bleDeviceClass.dart';
import 'package:flutterappdentaluvc/services/uvcToast.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:package_info/package_info.dart';
import 'package:wakelock/wakelock.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> with TickerProviderStateMixin {
  AnimationController controller;

  LedControl ledControl;

  UVCDataFile uvcDataFile = UVCDataFile();

  String macRobotUVC = '';

  ToastyMessage myUvcToast;

  Animation colorInfoQrCode;

  List<BluetoothDevice> scanDevices = [];

  AnimationController animationRefreshIcon;
  AnimationController animationController;

  Device myDevice;

  FlutterBlue flutterBlue = FlutterBlue.instance;

  PermissionStatus _permissionStatus = PermissionStatus.unknown;

  void ledInit() async {
    ledControl = LedControl();
    await ledControl.setLedColor('ON');
    await ledControl.setLedColor('GREEN');
  }

  void wakeLock() async {
    await Wakelock.enable();
    bool wakelockEnabled = await Wakelock.enabled;
    if (wakelockEnabled) {
      // The following statement disables the wakelock.
      Wakelock.toggle(enable: true);
    }
    print('screen lock is disabled');
  }

  void readUVCDevice() async {
    int devicesPosition = 0;
    bool deviceExistOrNot = false;
    macRobotUVC = await uvcDataFile.readUVCDevice();
    await Future.delayed(const Duration(seconds: 3));
    //myDevice.disconnect();
    if (macRobotUVC.isEmpty) {
      myUvcToast.setToastDuration(10);
      myDevice = Device(device: scanDevices.elementAt(devicesPosition));
      myUvcToast.setToastMessage('Veuillez associer un dispositif UV-C dans la page \'Réglages\' !');
      myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
      Future.delayed(Duration(seconds: 1), () async {
        Navigator.pushReplacementNamed(context, '/pin_access', arguments: {
          'myDevice': myDevice,
          'dataRead': '',
        });
      });
    } else {
      for (int i = 0; i < scanDevices.length; i++) {
        if (scanDevices.elementAt(i).id.toString().contains(macRobotUVC)) {
          deviceExistOrNot = true;
          devicesPosition = i;
          break;
        } else {
          deviceExistOrNot = false;
        }
      }
      if (deviceExistOrNot) {
        myUvcToast.setAnimationIcon(animationRefreshIcon);
        myUvcToast.setToastDuration(60);
        myDevice = Device(device: scanDevices.elementAt(devicesPosition));
        myUvcToast.setToastMessage('Autorisation de connexion validée !');
        myUvcToast.showToast(Colors.green, Icons.autorenew, Colors.white);
        // stop scanning and start connecting
        try {
          await myDevice.connect(false);
        } catch (e) {
          myDevice.disconnect();
          await myDevice.connect(false);
        }
        Future.delayed(const Duration(seconds: 2), () async {
          // clear the remaining toast message
          myUvcToast.clearAllToast();
          await myDevice.readCharacteristic(2, 0);
          Future.delayed(Duration(seconds: 1), () async {
            Navigator.pushReplacementNamed(context, '/pin_access', arguments: {
              'myDevice': myDevice,
              'dataRead': myDevice.getReadCharMessage(),
            });
          });
        });
      } else {
        myUvcToast.setToastDuration(10);
        myDevice = Device(device: scanDevices.elementAt(devicesPosition));
        myUvcToast
            .setToastMessage('Le dispositif UV-C enregistré n\'est pas détecté !\n Veuillez le mettre sous tension et redémarrer l\'application.');
        myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
        Navigator.pushReplacementNamed(context, '/pin_access');
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    animationRefreshIcon.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    wakeLock();

    _listenForPermissionStatus();

    if (Platform.isAndroid) {
      ledInit();
    }

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

    animationRefreshIcon = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 3),
    );
    animationController = AnimationController(vsync: this, duration: Duration(seconds: 10));
    colorInfoQrCode = animationColor(Colors.red, Colors.transparent);
    animationController.forward();

    animationRefreshIcon.repeat();
    myUvcToast = ToastyMessage(toastContext: context);
    //checks bluetooth current state
    Future.delayed(const Duration(seconds: 1), () async {
      flutterBlue.state.listen((state) {
        if (state == BluetoothState.off) {
          //Alert user to turn on bluetooth.
          print("Bluetooth is off");
          myUvcToast.setToastDuration(5);
          myUvcToast.setToastMessage('Le Bluetooth (BLE) sur votre téléphone n\'est pas activé !');
          myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
        } else if (state == BluetoothState.on) {
          //if bluetooth is enabled then go ahead.
          //Make sure user's device gps is on.
          flutterBlue = FlutterBlue.instance;
          print("Bluetooth is on");
          scanForDevices();
        }
      });
    });

    super.initState();
  }

  void _listenForPermissionStatus() {
    checkServiceStatus(context);
    final Future<PermissionStatus> statusFuture = LocationPermissions().checkPermissionStatus();

    statusFuture.then((PermissionStatus status) async{
        _permissionStatus = status;
        if (_permissionStatus.index != 2) {
          myUvcToast.setToastDuration(5);
          myUvcToast.setToastMessage('La Localisation n\'est pas autorisée sur votre téléphone !');
          myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
        } else {
          checkServiceStatus(context);
        }
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

  Animation animationColor(Color colorBegin, Color colorEnd) {
    return ColorTween(begin: colorBegin, end: colorEnd).animate(animationController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          animationController.forward();
        }
      });
  }

  void scanForDevices() {
    // Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 5));
    // Listen to scan results
    bool firstTime = true;
    flutterBlue.scanResults.listen((results) {
      scanDevices.clear();
      // do something with scan results
      for (ScanResult r in results) {
        if(firstTime){
          firstTime = false;
          readUVCDevice();
        }
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
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    print('width : $widthScreen and height : $heightScreen');
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
                height: heightScreen * 0.15,
                width: widthScreen * 0.7,
              ),
              SizedBox(height: heightScreen * 0.02),
              Image.asset(
                'assets/logo_deeplight.png',
                height: heightScreen * 0.15,
                width: widthScreen * 0.7,
              ),
              SizedBox(height: heightScreen * 0.05),
              SpinKitCircle(
                color: Colors.white,
                size: heightScreen * 0.1,
              ),
              SizedBox(height: heightScreen * 0.05),
              Image.asset(
                'assets/logodelitechblanc.png',
                height: heightScreen * 0.15,
                width: widthScreen * 0.7,
              ),
              SizedBox(height: heightScreen * 0.05),
              Text(
                'Powered by DELITECH Group',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: widthScreen * 0.02,
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
                          fontSize: widthScreen * 0.02,
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
      ),
    );
  }
}
