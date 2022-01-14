import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_ambimaestro/services/animation_between_pages.dart';
import 'package:flutter_app_ambimaestro/services/ble_device_class.dart';
import 'package:flutter_app_ambimaestro/services/data_variables.dart';
import 'package:flutter_app_ambimaestro/services/device_ble_widget.dart';
import 'package:flutter_app_ambimaestro/services/language_data_base.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ScanListBle extends StatefulWidget {
  const ScanListBle({Key? key}) : super(key: key);

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
        debugPrint("Bluetooth is off");
      } else if (state == BluetoothState.on) {
        //if bluetooth is enabled then go ahead.
        //Make sure user's device gps is on.
        flutterBlue = FlutterBlue.instance;
        debugPrint("Bluetooth is on");
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
    flutterBlue.startScan(timeout: const Duration(seconds: 5));
    // Listen to scan results
    flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results) {
        debugPrint('${r.device.name} found! mac: ${r.device.id.toString()}');
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
    flutterBlue.startScan(timeout: const Duration(seconds: 5));
    // Listen to scan results
    flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results) {
        debugPrint('${r.device.name} found! mac: ${r.device.id.toString()}');
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
          if (snapshot.data!) {
            return FloatingActionButton(
              child: const Icon(Icons.stop),
              onPressed: () => flutterBlue.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: const Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    devices.clear();
                  });
                  scanIdentifiers.clear();
                  flutterBlue.startScan(timeout: const Duration(seconds: 4));
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
    waitingConnectionWidget(context, checkConnectionAlertDialogTextLanguageArray[languageArrayIdentifier]);
    // stop scanning and start connecting
    await flutterBlue.stopScan();
    bool resultConnection = false;
    while (true) {
      myDevice!.connect(autoConnection: false);
      await Future.delayed(const Duration(seconds: 3));
      resultConnection = myDevice!.getConnectionState();
      if (resultConnection) {
        break;
      }
      debugPrint('result of trying connection is $resultConnection');
      myDevice!.disconnect();
      await Future.delayed(const Duration(seconds: 1));
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
          dataCharAndroid1 = String.fromCharCodes(await characteristicSensors!.read());
          debugPrint(dataCharAndroid1);
          await Future.delayed(const Duration(milliseconds: 500));
          dataCharAndroid2 = String.fromCharCodes(await characteristicData!.read());
          debugPrint(dataCharAndroid2);
          // delete the waiting widget
          Navigator.of(context).pop();
          DateTime dateTime = DateTime.now();
          homePageState = true;
          await characteristicData!.write('{"Time":[${dateTime.millisecondsSinceEpoch ~/ 1000},${dateTime.timeZoneOffset.inSeconds}]}'.codeUnits);
          //createRoute(context, Home());
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
          await characteristicData!.write('{"IOS":1}'.codeUnits);
          await Future.delayed(const Duration(milliseconds: 300));
          dataCharIOS1p1 = await charDividedIOSRead(characteristicSensors!);
          dataCharIOS2p1 = await charDividedIOSRead(characteristicData!);
          dataCharIOS2p2 = await charDividedIOSRead(characteristicData!);
          dataCharIOS2p3 = await charDividedIOSRead(characteristicData!);
          // delete the waiting widget
          Navigator.of(context).pop();
          DateTime dateTime = DateTime.now();
          homePageState = true;
          await characteristicData!.write('{"Time":[${dateTime.millisecondsSinceEpoch ~/ 1000},${dateTime.timeZoneOffset.inSeconds}]}'.codeUnits);
          //createRoute(context, Home());
        });
      }
    }
  }
}
