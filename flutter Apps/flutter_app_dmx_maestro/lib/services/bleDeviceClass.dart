import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';

class Device {
  BluetoothDevice device;

  Device({@required this.device});

  int _connectionState;
  List<BluetoothService> _services;
  String _readCharMessage;

  bool _readIsReady = false;
  bool _userDisconnected = false;

  StreamSubscription _subscription;

  Future<bool> connect({bool autoConnection}) async {
    // Not available for reading
    _readIsReady = false;
    //defining the methods
    void checkConnectionState() {
      _subscription = device.state.listen((state) {
        _connectionState = state.index;
        switch (state) {
          case BluetoothDeviceState.connected:
            debugPrint('connected');
            break;
          case BluetoothDeviceState.disconnected:
            debugPrint('disconnected');
            if (_userDisconnected) {
              Get.defaultDialog(
                title: 'Attention',
                barrierDismissible: false,
                content: Text('Connexion avec le dispositif perdue, reconnection en cours',
                    style: TextStyle(
                      fontSize: 14,
                    )),
                actions: [
                  TextButton(
                    child: Text(
                      'Compris',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    onPressed: () {
                      Get.toNamed('/');
                      Get.resetRootNavigator();
                      disconnect();
                    },
                  ),
                ],
              );
              _userDisconnected = false;
            }
            break;
          case BluetoothDeviceState.connecting:
            debugPrint('connecting');
            break;
          case BluetoothDeviceState.disconnecting:
            debugPrint('disconnecting');
            break;
        }
      });
    }

    Future<void> mtuRequest() async {
      if (Platform.isAndroid) {
        final mtu = await device.mtu.first;
        if (mtu < 512) {
          await device.requestMtu(512);
        }
      }
      debugPrint('the mtu is changed');
    }

    _userDisconnected = true;

    try {
      // connect
      await device.connect(autoConnect: autoConnection);
      checkConnectionState();
      await Future.delayed(const Duration(milliseconds: 500));
      if (_connectionState == BluetoothDeviceState.connected.index) {
        //Discover services
        _services = await device.discoverServices();
        // setting MTU
        await mtuRequest();
        //setting connection state after 1 second
        await Future.delayed(const Duration(seconds: 1), () async {
          // Not available for reading
          _readIsReady = true;
        });
        return true;
      } else {
        return false;
      }
    } on TimeoutException catch (e) {
      debugPrint('this should not be reached if the exception is raised $e');
    } on Exception catch (e) {
      debugPrint('exception: $e');
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

  Future<void> disconnect() async {
    _userDisconnected = false;
    _subscription.cancel();
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
