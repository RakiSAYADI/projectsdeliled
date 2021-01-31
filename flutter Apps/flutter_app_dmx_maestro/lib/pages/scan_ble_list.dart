import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_app_dmx_maestro/services/bleDeviceClass.dart';
import 'package:flutter_app_dmx_maestro/services/deviceBleWidget.dart';
import 'package:flutter_app_dmx_maestro/services/uvcToast.dart';

class ScanListBle extends StatefulWidget {
  @override
  _ScanListBleState createState() => _ScanListBleState();
}

class _ScanListBleState extends State<ScanListBle> with SingleTickerProviderStateMixin {
  List<Device> devices = [];

  ToastyMessage myUvcToast;

  ///Initialisation and listening to device state

  BluetoothDevice device;
  BluetoothDeviceState deviceState;
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice myDevice;
  BluetoothCharacteristic characteristicRelays;

  AnimationController animationRefreshIcon;

  @override
  void initState() {
    super.initState();

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
    });
  }

  int boolToInt(bool a) => a == true ? 1 : 0;

  bool intToBool(int a) => a == 1 ? true : false;

  Future<void> mtuRequest() async {
    if (Platform.isAndroid) {
      final mtu = await myDevice.mtu.first;
      print(mtu);
      await myDevice.requestMtu(512);
    }
    print('the mtu is changed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Liste des UVC-LIGHT :'),
        centerTitle: true,
        backgroundColor: Colors.indigo[700],
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
                        myDevice = device.device;
                      });
                      // display Toast message
                      animationRefreshIcon.repeat();
                      myUvcToast = ToastyMessage(toastContext: context);
                      myUvcToast.setAnimationIcon(animationRefreshIcon);
                      myUvcToast.setToastDuration(60);
                      String deviceName = myDevice.name;
                      myUvcToast.setToastMessage('Connecting to $deviceName !');
                      myUvcToast.showToast(Colors.green, Icons.autorenew, Colors.white);
                      // stop scanning and start connecting
                      await flutterBlue.stopScan();
                      await myDevice.connect();
                      //Discover services
                      List<BluetoothService> services = await myDevice.discoverServices();
                      BluetoothService service;
                      service = services.elementAt(2);
                      // Read the first characteristic
                      characteristicRelays = service.characteristics[0];
                      // setting MTU
                      await mtuRequest();
                      // reading the characteristic after 1 second
                      Future.delayed(const Duration(seconds: 1), () async {
                        List<int> relaysValues = await characteristicRelays.read();
                        print(relaysValues);
                        //print('get the ${device.getConnectionState()}');
                        // clear the remaining toast message
                        myUvcToast.clearCurrentToast();
                        Navigator.pushNamed(context, '/scan_qrcode', arguments: {
                          'bleCharacteristic': characteristicRelays,
                          'bleDevice': myDevice,
                        });
                      });
                    }))
                .toList()),
      ),
    );
  }
}
