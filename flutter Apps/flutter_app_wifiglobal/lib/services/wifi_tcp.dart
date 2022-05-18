import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:wifiglobalapp/services/data_variables.dart';
import 'package:wifiglobalapp/services/uvc_device.dart';

class TCPScan {
  final _plainText = '\$discover HuBBoX DELILED\t\n';

  List<Device> _listOfDevices = [];

  List<Device> getScanList() => _listOfDevices;

  TCPScan();

  Device selectDevice(int element) {
    return _listOfDevices.elementAt(element);
  }

  Future<bool> checkWifiConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> scanTCP({bool noAllScan = false}) async {
    _listOfDevices.clear();
    //message to check the network
    for (int i = 1; i < 256; i++) {
      try {
        if (Platform.isIOS) {
          Socket socket = await Socket.connect('192.168.2.$i', port, timeout: const Duration(seconds: 1));
          await _communicationTCP(socket, i);
        }
        if (Platform.isAndroid) {
          Socket socket = await Socket.connect('192.168.2.$i', port, timeout: const Duration(seconds: 2));
          await _communicationTCP(socket, i);
        }
      } catch (e) {
        debugPrint(e.toString());
      }
      // for the moment we will connect to HuBBoX so no network scanning
      if (noAllScan) {
        break;
      }
    }
  }

  Future<void> _communicationTCP(Socket socket, int i) async {
    // send crypt message
    socket.write(_plainText);
    debugPrint('we have good connection => 192.168.2.$i');
    Map<String, dynamic> dataInfo;
    // listen to the received data event stream
    socket.listen((List<int> message) {
      try {
        debugPrint('message received : ${utf8.decode(message)}');
        dataInfo = jsonDecode(utf8.decode(message));
        debugPrint('MAC : ${dataInfo['mac']} , manufacture : ${dataInfo['man']} , device name : ${dataInfo['name']} , serial number : ${dataInfo['sn']}');
        _listOfDevices.add(Device(socket.address.address, macDevice: dataInfo['mac'], manufacture: dataInfo['man'], nameDevice: dataInfo['name'], serialNumberDevice: dataInfo['sn']));
      } catch (e) {
        debugPrint(e.toString());
      }
    });
    // .. and close the socket
    socket.close();
    debugPrint('disconnected');
    if (Platform.isIOS) {
      await Future.delayed(Duration(milliseconds: 500));
    }
    if (Platform.isAndroid) {
      await Future.delayed(Duration(seconds: 1));
    }
  }
}
