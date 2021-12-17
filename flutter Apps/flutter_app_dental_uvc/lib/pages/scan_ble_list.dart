import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutterappdentaluvc/services/CSVfileClass.dart';
import 'package:flutterappdentaluvc/services/DataVariables.dart';
import 'package:flutterappdentaluvc/services/bleDeviceClass.dart';
import 'package:flutterappdentaluvc/services/deviceBleWidget.dart';
import 'package:flutterappdentaluvc/services/languageDataBase.dart';
import 'package:flutterappdentaluvc/services/uvcToast.dart';

class ScanListBle extends StatefulWidget {
  @override
  _ScanListBleState createState() => _ScanListBleState();
}

class _ScanListBleState extends State<ScanListBle> with SingleTickerProviderStateMixin {
  List<Device> devices = [];

  ToastyMessage myUvcToast;

  final String robotUVCMAC = '70:B3:D5:01:8';
  final String robotUVCName = 'DEEPLIGHT';

  ///Initialisation and listening to device state

  BluetoothDevice device;
  BluetoothDeviceState deviceState;
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothCharacteristic characteristicRelays;

  AnimationController animationRefreshIcon;

  UVCDataFile uvcDataFile;

  @override
  void initState() {
    super.initState();
    // initialise the animation
    animationRefreshIcon = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 3),
    );

    checkingNameRobot();

    //checks bluetooth current state
    flutterBlue.state.listen((state) {
      if (state == BluetoothState.off) {
        //Alert user to turn on bluetooth.
        print("Bluetooth is off");
        myUvcToast = ToastyMessage(toastContext: context);
        myUvcToast.setToastDuration(5);
        myUvcToast.setToastMessage(bluetoothToastLanguageArray[languageArrayIdentifier]);
        myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
      } else if (state == BluetoothState.on) {
        //if bluetooth is enabled then go ahead.
        //Make sure user's device gps is on.
        flutterBlue = FlutterBlue.instance;
        print("Bluetooth is on");
        if (Platform.isAndroid) {
          scanForDevicesAndroid();
        }
        if (Platform.isIOS) {
          scanForDevicesIos();
        }
      }
    });
  }

  void checkingNameRobot() async {
    uvcDataFile = UVCDataFile();
    robotsNamesData = await uvcDataFile.readRobotsNameDATA();
    try {
      json.decode(robotsNamesData);
    } catch (e) {
      print('error in name');
    }
  }

  List<String> scanIdentifiers = [];

  void scanForDevicesAndroid() {
    // Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 5));
    // Listen to scan results
    flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results) {
        print('${r.device.name} found! mac: ${r.device.id.toString()}');
        if (r.device.id.id.contains(robotUVCMAC)) {
          if (scanIdentifiers.isEmpty) {
            scanIdentifiers.add(r.device.id.toString());
            setState(() {
              devices.add(Device(device: r.device));
            });
          } else {
            if (!scanIdentifiers.contains(r.device.id.toString())) {
              scanIdentifiers.add(r.device.id.toString());
              setState(() {
                devices.add(Device(device: r.device));
              });
            }
          }
        }
      }
    });
  }

  void scanForDevicesIos() {
    // Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 5));
    // Listen to scan results
    flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results) {
        print('${r.device.name} found! mac: ${r.device.id.toString()}');
        if (r.device.name.contains(robotUVCName)) {
          if (scanIdentifiers.isEmpty) {
            scanIdentifiers.add(r.device.id.toString());
            setState(() {
              devices.add(Device(device: r.device));
            });
          } else {
            if (!scanIdentifiers.contains(r.device.id.toString())) {
              scanIdentifiers.add(r.device.id.toString());
              setState(() {
                devices.add(Device(device: r.device));
              });
            }
          }
        }
      }
    });
  }

  Future<void> startBindAndroid(BuildContext context, String uvcDeviceMac) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  saveDeviceMessageTextLanguageArray[languageArrayIdentifier],
                  style: TextStyle(fontSize: (screenWidth * 0.02)),
                ),
                SizedBox(height: screenHeight * 0.1),
                Image.asset(
                  'assets/connexion_dispositif.gif',
                  height: screenHeight * 0.3,
                  width: screenWidth * 0.5,
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text(
              yesTextLanguageArray[languageArrayIdentifier],
              style: TextStyle(fontSize: (screenWidth * 0.02)),
            ),
            onPressed: () async {
              try {
                myDevice.disconnect();
              } catch (e) {}
              Navigator.pop(c, true);
              UVCDataFile uvcDataFile = UVCDataFile();
              uvcDataFile.saveUVCDevice(uvcDeviceMac);
              Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
            },
          ),
          TextButton(
            child: Text(
              noTextLanguageArray[languageArrayIdentifier],
              style: TextStyle(fontSize: (screenWidth * 0.02)),
            ),
            onPressed: () {
              setState(() {
                devices.clear();
              });
              scanIdentifiers.clear();
              flutterBlue.startScan(timeout: Duration(seconds: 4));
              Navigator.pop(c, false);
            },
          ),
        ],
      ),
    );
  }

  Future<void> startBindIOS(BuildContext context, String uvcDeviceMac) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  saveDeviceMessageTextLanguageArray[languageArrayIdentifier],
                  style: TextStyle(fontSize: (screenWidth * 0.02)),
                ),
                SizedBox(height: screenHeight * 0.1),
                Image.asset(
                  'assets/connexion_dispositif.gif',
                  height: screenHeight * 0.3,
                  width: screenWidth * 0.5,
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text(
              yesTextLanguageArray[languageArrayIdentifier],
              style: TextStyle(fontSize: (screenWidth * 0.02)),
            ),
            onPressed: () async {
              try {
                myDevice.disconnect();
              } catch (e) {}
              Navigator.pop(c, true);
              UVCDataFile uvcDataFile = UVCDataFile();
              uvcDataFile.saveUVCDeviceIOS(uvcDeviceMac);
              Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
            },
          ),
          TextButton(
            child: Text(
              noTextLanguageArray[languageArrayIdentifier],
              style: TextStyle(fontSize: (screenWidth * 0.02)),
            ),
            onPressed: () {
              setState(() {
                devices.clear();
              });
              scanIdentifiers.clear();
              flutterBlue.startScan(timeout: Duration(seconds: 4));
              Navigator.pop(c, false);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(devicesListTitleTextLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: flutterBlue.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => flutterBlue.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    devices.clear();
                  });
                  scanIdentifiers.clear();
                  flutterBlue.startScan(timeout: Duration(seconds: 4));
                });
          }
        },
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
            children: devices
                .map(
                  (device) => DeviceCard(
                      device: device,
                      connect: () async {
                        if (Platform.isAndroid) {
                          startBindAndroid(context, device.device.id.id);
                        }
                        if (Platform.isIOS) {
                          startBindIOS(context, device.device.name);
                        }
                      }),
                )
                .toList()),
      ),
    );
  }
}
