import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_bispectrum/pages/Home.dart';
import 'package:flutter_app_bispectrum/services/DataVariables.dart';
import 'package:flutter_app_bispectrum/services/animation_between_pages.dart';
import 'package:flutter_app_bispectrum/services/bleDeviceClass.dart';
import 'package:flutter_app_bispectrum/services/deviceBleWidget.dart';
import 'package:flutter_app_bispectrum/services/languageDataBase.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ScanListBle extends StatefulWidget {
  @override
  _ScanListBleState createState() => _ScanListBleState();
}

class _ScanListBleState extends State<ScanListBle> {
  List<Device> devices = [];

  final String robotUVCMAC = '70:B3:D5:01:8';
  final String robotUVCName = 'HUB-';

  List<String> scanIdentifiers = [];

  ///Initialisation and listening to device state

  FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  void initState() {
    super.initState();
    //checks bluetooth current state
    flutterBlue.state.listen((state) {
      if (state == BluetoothState.off) {
        //Alert user to turn on bluetooth.
        print("Bluetooth is off");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(scanBLETitleLanguageArray[languageArrayIdentifier]),
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
                .map((device) => DeviceCard(
                    device: device,
                    connect: () {
                      startConnect(context, device.device);
                    }))
                .toList()),
      ),
    );
  }

  void startConnect(BuildContext context, BluetoothDevice thisDevice) async {
    myDevice = Device(device: thisDevice);
    waitingConnectionWidget(context, connexionTextLanguageArray[languageArrayIdentifier]);
    // stop scanning and start connecting
    await flutterBlue.stopScan();
    bool resultConnection = false;
    while (true) {
      myDevice.connect(autoConnection: false);
      await Future.delayed(Duration(seconds: 3));
      resultConnection = myDevice.getConnectionState();
      if (resultConnection) {
        break;
      }
      print('result of trying connection is $resultConnection');
      myDevice.disconnect();
      await Future.delayed(Duration(seconds: 1));
    }

    if (resultConnection) {
      //Discover services
      List<BluetoothService> services = await thisDevice.discoverServices();
      BluetoothService service;
      if (Platform.isAndroid) {
        service = services.elementAt(2);
        // Read the first characteristic
        characteristicSensors = service.characteristics[0];
        // Read the second characteristic
        characteristicData = service.characteristics[1];
        // reading the characteristic after 1 second
        Future.delayed(const Duration(seconds: 1), () async {
          dataCharAndroid1 = String.fromCharCodes(await characteristicSensors.read());
          print(dataCharAndroid1);
          await Future.delayed(Duration(milliseconds: 500));
          dataCharAndroid2 = String.fromCharCodes(await characteristicData.read());
          print(dataCharAndroid2);
          // delete the waiting widget
          Navigator.of(context).pop();
          DateTime dateTime = DateTime.now();
          homePageState = true;
          await characteristicData.write('{\"Time\":[${dateTime.millisecondsSinceEpoch ~/ 1000},\"$embeddedTimeZone\",${dateTime.timeZoneOffset.inSeconds}]}'.codeUnits);
          createRoute(context, Home());
        });
      }
      if (Platform.isIOS) {
        service = services.elementAt(0);
        // Read the first characteristic
        characteristicSensors = service.characteristics[0];
        // Read the second characteristic
        characteristicData = service.characteristics[1];
        // reading the characteristic after 1 second
        Future.delayed(const Duration(seconds: 1), () async {
          await characteristicData.write('{\"IOS\":1}'.codeUnits);
          await Future.delayed(Duration(milliseconds: 300));
          dataCharIOS1p1 = await charDividedIOSRead(characteristicSensors);
          dataCharIOS2p1 = await charDividedIOSRead(characteristicData);
          dataCharIOS2p2 = await charDividedIOSRead(characteristicData);
          dataCharIOS2p3 = await charDividedIOSRead(characteristicData);
          // delete the waiting widget
          Navigator.of(context).pop();
          DateTime dateTime = DateTime.now();
          homePageState = true;
          await characteristicData.write('{\"Time\":[${dateTime.millisecondsSinceEpoch ~/ 1000},\"$embeddedTimeZone\",${dateTime.timeZoneOffset.inSeconds}]}'.codeUnits);
          createRoute(context, Home());
        });
      }
    }
  }
}
