import 'package:flutter/material.dart';
import 'package:flutter_app_master_uvc/services/DataVariables.dart';
import 'package:flutter_app_master_uvc/services/languageDataBase.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_app_master_uvc/services/bleDeviceClass.dart';
import 'package:flutter_app_master_uvc/services/deviceBleWidget.dart';
import 'package:flutter_app_master_uvc/services/uvcToast.dart';

class ScanListBle extends StatefulWidget {
  @override
  _ScanListBleState createState() => _ScanListBleState();
}

class _ScanListBleState extends State<ScanListBle> with SingleTickerProviderStateMixin {
  List<Device> devices = [];

  ToastyMessage myUvcToast;

  final String robotUVCName = 'DEEPLIGHT';

  ///Initialisation and listening to device state

  BluetoothDevice device;
  BluetoothDeviceState deviceState;
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothCharacteristic characteristicRelays;

  AnimationController animationRefreshIcon;

  @override
  void initState() {
    super.initState();

    myUvcToast = ToastyMessage(toastContext: context);

    // initialise the animation
    animationRefreshIcon = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 3),
    );

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
        scanForDevices();
      }
    });
  }

  List<String> scanIdentifiers = [];

  void scanForDevices() {
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
            Text(startScanAlertDialogTitleTextLanguageArray[languageArrayIdentifier]),
            Image.asset(
              'assets/scan_qr_code.gif',
              height: screenHeight * 0.3,
              width: screenWidth * 0.8,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text(okTextLanguageArray[languageArrayIdentifier]),
            onPressed: () async {
              Navigator.pop(c, true);
              Navigator.pushNamed(context, '/qr_code_scan');
            },
          ),
          TextButton(
            child: Text(cancelTextLanguageArray[languageArrayIdentifier]),
            onPressed: () => Navigator.pop(c, false),
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
        title: Text(scanBLEListTitleTextLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
        backgroundColor: Color(0xFF554c9a),
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
                .map((device) => DeviceCard(
                    device: device,
                    connect: () async {
                      setState(() {
                        myDevice = Device(device: device.device);
                      });
                      animationRefreshIcon.repeat();
                      await Future.delayed(const Duration(milliseconds: 400));
                      myUvcToast.setAnimationIcon(animationRefreshIcon);
                      myUvcToast.setToastDuration(60);
                      myUvcToast.setToastMessage(checkConnectionAlertDialogTitleTextLanguageArray[languageArrayIdentifier]);
                      myUvcToast.showToast(Colors.green, Icons.autorenew, Colors.white);
                      // stop scanning and start connecting
                      while (true) {
                        myDevice.connect(false);
                        await Future.delayed(Duration(milliseconds: 2200));
                        print('result of trying connection is ${myDevice.getConnectionState()}');
                        if (myDevice.getConnectionState()) {
                          break;
                        } else {
                          myDevice.disconnect();
                          await Future.delayed(Duration(milliseconds: 2200));
                        }
                      }
                      if (myDevice.getConnectionState()) {
                        Future.delayed(const Duration(seconds: 2), () async {
                          // Read data from robot
                          await myDevice.readCharacteristic(0, 0);
                          // clear the remaining toast message
                          myUvcToast.clearAllToast();
                          flutterBlue.stopScan();
                          startScan(context);
                        });
                      }
                    }))
                .toList()),
      ),
    );
  }
}
