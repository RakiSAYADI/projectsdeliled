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
  }

  Future<void> writeCharacteristic(
      int servicePosition, int charPosition) async {
    // checking MTU
    // checking Connection
    // writing characteristic
  }

  Future<void> readCharacteristic(int servicePosition, int charPosition) async {
    // checking MTU
    // checking Connection
    // reading characteristic
  }

  Future<void> writeDescriptor(
      int servicePosition, int charPosition, int descPosition) async {
    // checking MTU
    // checking Connection
    // writing descriptor
  }

  Future<void> readDescriptor(
      int servicePosition, int charPosition, int descPosition) async {
    // checking MTU
    // checking Connection
    // reading descriptor
  }
}
