import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:flutterappmicromaestro/services/peripheralBleWidget.dart';
import 'package:flutterappmicromaestro/services/uvcToast.dart';

class PairingDevice extends StatefulWidget {
  @override
  _PairingDeviceState createState() => _PairingDeviceState();
}

class _PairingDeviceState extends State<PairingDevice> {
  ToastyMessage myUvcToast;

  BleManager bleManager = BleManager();

  List<Peripheral> peripherals = [];
  List<String> scanIdentifiers = [];

  Stream<bool> isScanning = new Stream.value(false);

  @override
  void initState() {
    super.initState();
    bluetoothInitialState();
  }

  // We are using async callback for using await
  Future<void> bluetoothInitialState() async {
    await bleManager.createClient(); //ready to go!

    BluetoothState currentState = await bleManager.bluetoothState();
    bleManager.observeBluetoothState().listen((btState) {
      print('current bluetooth state : $btState');
      //do your BT logic, open different screen, etc.
    });
    print('initial bluetooth state : $currentState');
    scanPeripherals();
  }

  void scanPeripherals() {
    setState(() {
      peripherals.clear();
      scanIdentifiers.clear();
    });

    bleManager.startPeripheralScan().listen((scanResult) {
      //Scan peripherals
      print("Scanned Peripheral ${scanResult.peripheral.name}, RSSI ${scanResult.rssi}");
      if (scanIdentifiers.isEmpty) {
        scanIdentifiers.add(scanResult.peripheral.identifier);
        setState(() {
          peripherals.add(scanResult.peripheral);
        });
      } else {
        if (!scanIdentifiers.contains(scanResult.peripheral.identifier)) {
          scanIdentifiers.add(scanResult.peripheral.identifier);
          setState(() {
            peripherals.add(scanResult.peripheral);
          });
        }
      }
    });
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
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
            children: peripherals
                .map((peripheral) => PeripheralCard(
                    peripheral: peripheral,
                    connect: () async {
                      try {
                        await bleManager.stopPeripheralScan();
                        bool error;
                        if (error) {
                          print('no error');
                        }
                        // display Toast message
                        myUvcToast = ToastyMessage(toastContext: context);
                        myUvcToast.setToastDuration(5);
                        myUvcToast.setToastMessage('Connecting to ${peripheral.name} !');
                        myUvcToast.showToast(Colors.green, Icons.autorenew, Colors.white);
                      } catch (e) {
                        print('catch error');
                        scanPeripherals();
                      } finally {
                        print('finally');
                      }
                    }))
                .toList()),
      ),
    );
  }
}
