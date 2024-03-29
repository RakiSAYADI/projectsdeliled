import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class Device {
  BluetoothDevice device;

  Device({@required this.device});

  int _connectionState;
  List<BluetoothService> _services;
  String _readCharMessage;

  bool _readIsReady = false;

  Future<bool> connect({bool autoConnect}) async {
    // Not available for reading
    _readIsReady = false;
    //defining the methods

    Future<void> mtuRequest() async {
      if (Platform.isAndroid) {
        final mtu = await device.mtu.first;
        if (mtu < 512) {
          await device.requestMtu(512);
        }
      }
      print('the mtu is changed');
    }

    void checkConnectionState() {
      device.state.listen((state) {
        _connectionState = state.index;
        switch (state) {
          case BluetoothDeviceState.connected:
            print('connected');
            // setting MTU
            mtuRequest();
            break;
          case BluetoothDeviceState.disconnected:
            print('disconnected');
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

    try {
      // connect
      await device.connect(autoConnect: autoConnect);
      checkConnectionState();
      await Future.delayed(const Duration(milliseconds: 500));
      if (_connectionState == BluetoothDeviceState.connected.index) {
        //Discover services
        _services = await device.discoverServices();
        //setting connection state after 1 second
        await Future.delayed(const Duration(seconds: 1), () async {
          // Not available for reading
          _readIsReady = true;
        });
        return true;
      } else {
        return false;
      }
    } on TimeoutException catch(e) {
      print('this should not be reached if the exception is raised $e');
    } on Exception catch(e) {
      print('exception: $e');
    }
    return false;
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
      // Checking if the write is not on process
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
