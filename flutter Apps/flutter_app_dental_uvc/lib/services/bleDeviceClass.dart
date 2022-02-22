import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterappdentaluvc/services/DataVariables.dart';
import 'package:flutterappdentaluvc/services/languageDataBase.dart';
import 'package:get/get.dart';

class Device {
  BluetoothDevice device;

  Device({this.device});

  int _connectionState;
  List<BluetoothService> _services;
  String _readCharMessage;

  bool _readIsReady = false;
  bool _connectionError = false;

  FlutterBlue _flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> _scanDevices = [];

  Future<void> connect(bool autoConnection) async {
    // Not available for reading
    _readIsReady = false;
    // defining the methods
    void checkConnectionState() {
      device.state.listen((state) {
        _connectionState = state.index;
      });
    }

    // connect
    await device.connect(autoConnect: autoConnection);
    // Discover services
    _services = await device.discoverServices();
    // setting MTU
    await mtuRequest();
    // setting connection state after 1 second
    checkConnectionState();
    Future.delayed(const Duration(seconds: 1), () async {
      // available for reading
      _readIsReady = true;
      _connectionError = true;
      // listen if the state connexion is changed or not
      if (connectionOnce) {
        _checkBLEConnectionState(device);
        connectionOnce = false;
      }
    });
  }

  Future<void> mtuRequest() async {
    if (Platform.isAndroid) {
      final mtu = await device.mtu.first;
      print(mtu);
      if (mtu < 512) {
        await device.requestMtu(512);
      }
    }
    print('the mtu is changed');
  }

  bool getConnectionState() {
    if (_connectionState == BluetoothDeviceState.connected.index) {
      return true;
    } else {
      return false;
    }
  }

  void disconnect() {
    // disconnect
    device.disconnect();
    // Not available for reading
    _readIsReady = false;
    _connectionError = false;
  }

  String getReadCharMessage() {
    return this._readCharMessage;
  }

  Future<int> writeCharacteristic(int servicePosition, int charPosition, String data) async {
    // Not available for reading
    _readIsReady = false;
    // checking Connection
    if (_connectionState == BluetoothDeviceState.connected.index) {
      // checking MTU
      if (Platform.isAndroid) {
        final mtu = await device.mtu.first;
        if (mtu < 512) {
          await device.requestMtu(512);
        }
      }
      // writing characteristic after 1 second
      await Future.delayed(const Duration(seconds: 1), () async {
        List<int> messageToBytes = data.codeUnits;
        await _services.elementAt(servicePosition).characteristics.elementAt(charPosition).write(messageToBytes);
        // available for reading
        _readIsReady = true;
      });
      return 0;
    } else {
      return -1;
    }
  }

  Future<int> readCharacteristic(int servicePosition, int charPosition) async {
    // checking Connection
    if (_connectionState == BluetoothDeviceState.connected.index) {
      // checking MTU
      if (Platform.isAndroid) {
        final mtu = await device.mtu.first;
        if (mtu < 512) {
          await device.requestMtu(512);
        }
      }
      // checking if the write is not on process
      if (_readIsReady) {
        // reading characteristic after 1 second
        await Future.delayed(const Duration(seconds: 1), () async {
          List<int> messageToBytes;
          messageToBytes = await _services.elementAt(servicePosition).characteristics.elementAt(charPosition).read();
          _readCharMessage = String.fromCharCodes(messageToBytes);
        });
        return 0;
      } else {
        return -1;
      }
    } else {
      return -2;
    }
  }

  void _checkBLEConnectionState(BluetoothDevice blueDevice) {
    blueDevice.state.listen((event) async {
      switch (event) {
        case BluetoothDeviceState.connected:
          print('connected');
          break;
        case BluetoothDeviceState.disconnected:
          print('disconnected');
          if (_connectionError) {
            Get.defaultDialog(
              title: attentionTextLanguageArray[languageArrayIdentifier],
              barrierDismissible: false,
              content: Text(lostConnexionTextLanguageArray[languageArrayIdentifier],
                  style: TextStyle(
                    fontSize: 14,
                  )),
              actions: [
                TextButton(
                  child: Text(
                    understoodTextLanguageArray[languageArrayIdentifier],
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  onPressed: () async {
                    Get.back();
                    print(savedDevice.id.id);
                    _connectionError = false;
                    _scanForDevices();
                  },
                ),
              ],
            );
          }
          break;
        case BluetoothDeviceState.connecting:
          print('connecting');
          break;
        case BluetoothDeviceState.disconnecting:
          print('disconnecting');
          break;
      }
    });
  }

  void _scanForDevices() async {
    Get.defaultDialog(
      title: deviceSearchMessageTextLanguageArray[languageArrayIdentifier],
      barrierDismissible: false,
      content: SpinKitCircle(
        color: Colors.green,
        size: 100,
      ),
    );
    // Start scanning
    _flutterBlue.startScan(timeout: Duration(seconds: 10));
    // Listen to scan results
    _flutterBlue.scanResults.listen((results) {
      _scanDevices.clear();
      // do something with scan results
      for (ScanResult r in results) {
        print('${r.device.name} found! mac: ${r.device.id.toString()} with rssi ${r.rssi}');
        if (_scanDevices.isEmpty) {
          _scanDevices.add(r.device);
        } else {
          if (!_scanDevices.contains(r.device)) {
            _scanDevices.add(r.device);
          }
        }
      }
    });
    await Future.delayed(const Duration(seconds: 10));
    _flutterBlue.stopScan();
    _deviceState();
  }

  void _deviceState() {
    int devicesPosition = 0;
    bool deviceExistOrNot = false;
    for (int i = 0; i < _scanDevices.length; i++) {
      if (_scanDevices.elementAt(i).id.toString().contains(savedDevice.id.id)) {
        deviceExistOrNot = true;
        devicesPosition = i;
        break;
      } else {
        deviceExistOrNot = false;
      }
    }
    Get.back();
    if (deviceExistOrNot) {
      Get.snackbar(congratulationMessageTextLanguageArray[languageArrayIdentifier], findDeviceMessageTextLanguageArray[languageArrayIdentifier],
          icon: Icon(Icons.assignment_turned_in, color: Colors.green));
      _connectUVCDevice(devicesPosition);
    } else {
      Get.snackbar(congratulationMessageTextLanguageArray[languageArrayIdentifier], noFindDeviceMessageTextLanguageArray[languageArrayIdentifier],
          icon: Icon(Icons.assignment_late, color: Colors.red));
      connectionOnce = true;
      Get.toNamed('/');
      Get.resetRootNavigator();
    }
  }

  void _connectUVCDevice(int devicesPosition) async {
    await Future.delayed(const Duration(seconds: 2));
    Get.defaultDialog(
      title: connexionDeviceMessageTextLanguageArray[languageArrayIdentifier],
      barrierDismissible: false,
      content: SpinKitCircle(
        color: Colors.green,
        size: 100,
      ),
    );
    myDevice.disconnect();
    savedDevice = _scanDevices.elementAt(devicesPosition);
    myDevice = Device(device: _scanDevices.elementAt(devicesPosition));
    // stop scanning and start connecting
    while (true) {
      while (true) {
        myDevice.connect(false);
        await Future.delayed(Duration(seconds: 3));
        print('result of trying connection is ${myDevice.getConnectionState()}');
        if (myDevice.getConnectionState()) {
          break;
        } else {
          myDevice.disconnect();
        }
      }
      if (myDevice.getConnectionState()) {
        if (Platform.isAndroid) {
          await myDevice.readCharacteristic(2, 0);
        }
        if (Platform.isIOS) {
          await myDevice.readCharacteristic(0, 0);
        }
        await Future.delayed(const Duration(seconds: 1));
        try {
          if (myDevice.getReadCharMessage().isNotEmpty) {
            Future.delayed(Duration(seconds: 1), () async {
              _flutterBlue.stopScan();
              Get.back();
              await Future.delayed(const Duration(milliseconds: 500));
              Get.snackbar(congratulationMessageTextLanguageArray[languageArrayIdentifier], havingConnexionDeviceMessageTextLanguageArray[languageArrayIdentifier],
                  icon: Icon(Icons.assignment_turned_in, color: Colors.green));
              _connectionError = true;
            });
            break;
          } else {
            myDevice.disconnect();
          }
        } catch (e) {
          print(e);
          myDevice.disconnect();
        }
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}
