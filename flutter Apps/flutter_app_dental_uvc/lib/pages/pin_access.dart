import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutterappdentaluvc/services/NFCManagerClass.dart';
import 'package:flutterappdentaluvc/services/bleDeviceClass.dart';
import 'package:flutterappdentaluvc/services/uvcToast.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pinput/pin_put/pin_put.dart';

class AccessPin extends StatefulWidget {
  @override
  _AccessPinState createState() {
    print('create task');
    return _AccessPinState();
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

class _AccessPinState extends State<AccessPin> with TickerProviderStateMixin {
  final TextEditingController _pinPutController = TextEditingController();
  String pinCode;

  final String macRobot = '70:B3:D5:01:80:06';
  String pinCodeAccess = '';
  String myPinCode = '';

  ToastyMessage myUvcToast;

  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> scanDevices = [];

  Animation colorInfoQrCode;

  bool qrCodeScanAccess = false;

  AnimationController animationRefreshIcon;
  AnimationController animationController;

  int devicesPosition = 0;
  bool deviceExistOrNot = false;

  Device myDevice;

  PermissionStatus _permissionStatus = PermissionStatus.unknown;

  Widget mainWidgetScreen;

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: Colors.blue, width: 3),
      borderRadius: BorderRadius.circular(15),
    );
  }

  void readingNFCTags() async {
    NFCTagsManager nfcManager = NFCTagsManager();
    print(await nfcManager.checkNFCAvailibility());
    nfcManager.setContext(context);
    nfcManager.startNFCTask();
    print(nfcManager.nfcGetMessage());
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

  @override
  void initState() {
    print('init task');
    // TODO: implement initState
    super.initState();
    // initialise the animation
    animationRefreshIcon = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 3),
    );
    animationController = AnimationController(vsync: this, duration: Duration(seconds: 10));
    colorInfoQrCode = animationColor(Colors.red, Colors.transparent);
    animationController.forward();

    _listenForPermissionStatus();

    readingNFCTags();

    animationRefreshIcon.repeat();
    myUvcToast = ToastyMessage(toastContext: context);
    //checks bluetooth current state
    Future.delayed(const Duration(seconds: 1), () async {
      pinCodeAccess = await _readPINFile();
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

  Widget sleepWidget(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Center(
      child: Image.asset(
        'assets/logo_uv_c.png',
        height: heightScreen,
        width: widthScreen,
      ),
    );
  }

  Widget appWidget(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.blue[400],
      appBar: AppBar(
        title: const Text('Code PIN'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Builder(
          builder: (context) {
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Entrer le code de sécurité :',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: widthScreen * 0.04,
                      ),
                    ),
                    SizedBox(height: heightScreen * 0.05),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(flex: 1, child: SizedBox(height: heightScreen * 0.01)),
                        Expanded(
                          flex: 3,
                          child: Container(
                            margin: EdgeInsets.all(20),
                            padding: EdgeInsets.all(10),
                            child: PinPut(
                              fieldsCount: 4,
                              onSubmit: (String pin) => pinCode = pin,
                              focusNode: AlwaysDisabledFocusNode(),
                              controller: _pinPutController,
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: widthScreen * 0.04,
                              ),
                              submittedFieldDecoration: _pinPutDecoration.copyWith(borderRadius: BorderRadius.circular(20)),
                              selectedFieldDecoration: _pinPutDecoration,
                              followingFieldDecoration: _pinPutDecoration.copyWith(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Colors.grey[600].withOpacity(.5), width: 3),
                              ),
                            ),
                          ),
                        ),
                        Expanded(flex: 1, child: SizedBox(height: heightScreen * 0.01)),
                      ],
                    ),
                    SizedBox(height: heightScreen * 0.05),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buttonNumbers('0', context),
                        SizedBox(width: widthScreen * 0.003),
                        buttonNumbers('1', context),
                        SizedBox(width: widthScreen * 0.003),
                        buttonNumbers('2', context),
                        SizedBox(width: widthScreen * 0.003),
                        buttonNumbers('3', context),
                        SizedBox(width: widthScreen * 0.003),
                        buttonNumbers('4', context),
                        SizedBox(width: widthScreen * 0.003),
                        buttonNumbers('5', context),
                        SizedBox(width: widthScreen * 0.003),
                        buttonNumbers('6', context),
                        SizedBox(width: widthScreen * 0.003),
                        buttonNumbers('7', context),
                        SizedBox(width: widthScreen * 0.003),
                        buttonNumbers('8', context),
                        SizedBox(width: widthScreen * 0.003),
                        buttonNumbers('9', context),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/pin_settings', arguments: {
            'pinCodeAccess': pinCodeAccess,
          });
        },
        label: Text('Réglages'),
        icon: Icon(
          Icons.settings,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue[400],
      ),
    );
  }

  void screenSleep(BuildContext context) {
    setState(() {
      mainWidgetScreen = sleepWidget(context);
    });
  }

  bool firstDisplayMainWidget = true;

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    print('build task');
    if (firstDisplayMainWidget) {
      mainWidgetScreen = appWidget(context);
      firstDisplayMainWidget = false;
    }
    return GestureDetector(
      child: mainWidgetScreen,
      onTap: () => screenSleep(context),
    );
  }

  ButtonTheme buttonNumbers(String number, BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return ButtonTheme(
      minWidth: widthScreen * 0.09,
      height: heightScreen * 0.07,
      child: FlatButton(
        color: Colors.grey[400],
        child: Text(
          number,
          style: TextStyle(
            color: Colors.white,
            fontSize: widthScreen * 0.02,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        onPressed: () async {
          myPinCode += number;
          print(myPinCode);
          _pinPutController.text += '*';
          if (_pinPutController.text.length == 4) {
            _showSnackBar(myPinCode, context);
            myPinCode = '';
          }
        },
      ),
    );
  }

  Future<String> _readPINFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/my_pin_code.txt');
      String pinCode = await file.readAsString();
      return pinCode;
    } catch (e) {
      print("Couldn't read file");
      _savePINFile('1234');
      return '1234';
    }
  }

  _savePINFile(String pinCode) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/my_pin_code.txt');
    await file.writeAsString(pinCode);
    print('saved');
  }

  @override
  void dispose() {
    animationController.dispose();
    animationRefreshIcon.dispose();
    print('dispose task');
    super.dispose();
  }

  void _showSnackBar(String pin, BuildContext context) async {
    double widthScreen = MediaQuery.of(context).size.width;
    pinCodeAccess = await _readPINFile();
    String messagePin;
    Color messageColor;
    if (pin == pinCodeAccess && pin.isNotEmpty) {
      messagePin = 'Code valide';
      messageColor = Colors.green;
    } else {
      messagePin = 'Code non valide';
      messageColor = Colors.red;
    }
    _pinPutController.clear();
    final snackBar = SnackBar(
      duration: Duration(seconds: 2),
      content: Container(
          height: widthScreen * 0.1,
          child: Center(
            child: Text(
              messagePin,
              style: TextStyle(fontSize: 25.0),
            ),
          )),
      backgroundColor: messageColor,
      onVisible: () async {
        if (pin == pinCodeAccess && pin.isNotEmpty) {
          for (int i = 0; i < scanDevices.length; i++) {
            if (scanDevices.elementAt(i).id.toString().contains(macRobot)) {
              deviceExistOrNot = true;
              devicesPosition = i;
              break;
            } else {
              deviceExistOrNot = false;
            }
          }
          if (deviceExistOrNot) {
            qrCodeScanAccess = true;
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
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/profiles', arguments: {
                'myDevice': myDevice,
                'dataRead': myDevice.getReadCharMessage(),
              });
              //myDevice.disconnect();
            });
          } else {
            qrCodeScanAccess = false;
            myUvcToast.setToastDuration(3);
            myDevice = Device(device: scanDevices.elementAt(devicesPosition));
            myUvcToast.setToastMessage('Aucun dispositif UVC disponible !');
            myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
            flutterBlue.startScan(timeout: Duration(seconds: 5));
          }
        }
      },
    );
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
