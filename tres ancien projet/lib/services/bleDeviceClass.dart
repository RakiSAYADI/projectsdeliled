import 'dart:io';

import 'package:flutter_blue/flutter_blue.dart';

class Device {
  BluetoothDevice device;

  Device({this.device});

  int _connectionState;
  List<BluetoothService> _services;

  Future<void> connect(bool autoConnection) async {
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
    //Discover services
    _services = await device.discoverServices();
    // setting MTU
    await mtuRequest();
    //setting connection state after 1 second
    Future.delayed(const Duration(seconds: 1), () async {
      checkConnectionState();
    });
  }

  void disconnect() {
    // disconnect
    device.disconnect();
  }

  Future<int> writeCharacteristic(
      int servicePosition, int charPosition, String data) async {
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
        await _services
            .elementAt(servicePosition)
            .characteristics
            .elementAt(charPosition)
            .write(messageToBytes);
      });
      return 0;
    } else {
      return -1;
    }
  }

  Future<void> readCharacteristic(int servicePosition, int charPosition) async {
    // checking Connection
    if (_connectionState == BluetoothDeviceState.connected.index) {
      // checking MTU
      if (Platform.isAndroid) {
        final mtu = await device.mtu.first;
        if (mtu < 512) {
          await device.requestMtu(512);
        }
      }
      // reading characteristic after 1 second
      await Future.delayed(const Duration(seconds: 1), () async {
        List<int> messageToBytes ;
        messageToBytes=await _services
            .elementAt(servicePosition)
            .characteristics
            .elementAt(charPosition)
            .read();
        print('the message is ${messageToBytes.toString()}');
      });
      return 0;
    } else {
      return -1;
    }
  }
}
