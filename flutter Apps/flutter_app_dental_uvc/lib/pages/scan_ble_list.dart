import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutterappdentaluvc/services/CSVfileClass.dart';
import 'package:flutterappdentaluvc/services/bleDeviceClass.dart';
import 'package:flutterappdentaluvc/services/deviceBleWidget.dart';
import 'package:flutterappdentaluvc/services/uvcToast.dart';

class ScanListBle extends StatefulWidget {
  @override
  _ScanListBleState createState() => _ScanListBleState();
}

class _ScanListBleState extends State<ScanListBle> with SingleTickerProviderStateMixin {
  List<Device> devices = [];

  Device myDevice;

  ToastyMessage myUvcToast;

  final String robotUVCMAC = '70:B3:D5:01:8';
  final String robotUVCName = 'DEEPLIGHT';

  ///Initialisation and listening to device state

  BluetoothDevice device;
  BluetoothDeviceState deviceState;
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothCharacteristic characteristicRelays;

  AnimationController animationRefreshIcon;

  Map scanUVCDevicesData = {};

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
        myUvcToast.setToastMessage('Le Bluetooth (BLE) n\'est pas activé sur votre téléphone !');
        myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
      } else if (state == BluetoothState.on) {
        //if bluetooth is enabled then go ahead.
        //Make sure user's device gps is on.
        flutterBlue = FlutterBlue.instance;
        print("Bluetooth is on");
        if(Platform.isAndroid){
          scanForDevicesAndroid();
        }
        if(Platform.isIOS){
          scanForDevicesIos();
        }
      }
    });
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

  Future<void> startScan(BuildContext context,String uvcDeviceMac) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    scanUVCDevicesData = scanUVCDevicesData.isNotEmpty ? scanUVCDevicesData : ModalRoute.of(context).settings.arguments;
    myDevice = scanUVCDevicesData['myDevice'];
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Voulez vous vraiment enregistrer ce dispositif ?'),
            Image.asset(
              'assets/scan_qr_code.gif',
              height: screenHeight * 0.3,
              width: screenWidth * 0.8,
            ),
          ],
        ),
        actions: [
          FlatButton(
            child: Text('Oui'),
            onPressed: () async {
              try{
                myDevice.disconnect();
              }catch(e){

              }
              Navigator.pop(c, true);
              UVCDataFile uvcDataFile = UVCDataFile();
              uvcDataFile.saveUVCDevice(uvcDeviceMac);
              Phoenix.rebirth(context);
              //Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
            },
          ),
          FlatButton(
            child: Text('Non'),
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
        title: Text('Liste des UVC-LIGHT :'),
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
                    connect: () async {
                      startScan(context,device.device.id.id);
                    }))
                .toList()),
      ),
    );
  }
}
