import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_bispectrum/services/DataVariables.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';

class Device {
  BluetoothDevice device;

  Device({this.device});

  int _connectionState;
  List<BluetoothService> _services;
  String _readCharMessage;

  bool _readIsReady = false;

  bool _connectionOnce = true;

  Future<void> connect({bool autoConnection}) async {
    // Not available for reading
    _readIsReady = false;
    // defining the methods
    void checkConnectionState() {
      device.state.listen((state) {
        _connectionState = state.index;
      });
    }

    Future<void> mtuRequest() async {
      if (Platform.isAndroid) {
        final mtu = await device.mtu.first;
        if (mtu < 512) {
          await device.requestMtu(512);
        }
      }
      print('the mtu is changed');
    }

    // connect
    await device.connect(autoConnect: autoConnection);
    // Discover services
    _services = await device.discoverServices();
    // setting MTU
    await mtuRequest();
    // setting connection state after 1 second
    Future.delayed(const Duration(seconds: 1), () async {
      checkConnectionState();
      // available for reading
      _readIsReady = true; // listen if the state connexion is changed or not
      if (_connectionOnce) {
        _checkBLEConnectionState(device);
        _connectionOnce = false;
      }
    });
  }

  void _checkBLEConnectionState(BluetoothDevice blueDevice) {
    blueDevice.state.listen((event) async {
      switch (event) {
        case BluetoothDeviceState.connected:
          print('connected');
          break;
        case BluetoothDeviceState.disconnected:
          print('disconnected');
          if (homePageState) {
            Get.defaultDialog(
              title: 'Attention',
              barrierDismissible: false,
              content: Text('La connexion est perdue avec votre dispositif, vous allez être reconnecté', style: TextStyle(fontSize: 14)),
              actions: [
                TextButton(
                  child: Text('Compris', style: TextStyle(fontSize: 14)),
                  onPressed: () {
                    Get.clearRouteTree();
                    myDevice.disconnect();
                    homePageState = false;
                    Get.toNamed('/');
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

  bool getConnectionState() {
    if (_connectionState == BluetoothDeviceState.connected.index) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> disconnect() async {
    // disconnect
    await device.disconnect();
    // Not available for reading
    _readIsReady = false;
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
}
