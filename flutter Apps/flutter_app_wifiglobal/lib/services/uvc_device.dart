import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wifiglobalapp/services/data_variables.dart';
import 'package:wifiglobalapp/services/device_tcp.dart';
import 'package:wifiglobalapp/services/wifi_tcp.dart';

class Device {
  String macDevice = '';
  String manufacture = '';
  String nameDevice = '';
  String serialNumberDevice = '';
  String deviceAddress = ipAddressDevice;

  String deviceName = '';
  String deviceCompanyName = '';
  String deviceOperatorName = '';
  String deviceRoomName = '';

  String deviceAPSSID = '';
  String deviceAPPassword = '';

  int activationTime = 0;
  int disinfectionTime = 0;
  int state = 0;

  TCPScan _tcpScan = TCPScan();

  TCPCommunication _tcpSocket = TCPCommunication();

  Device(this.deviceAddress, {required this.macDevice, required this.manufacture, required this.nameDevice, required this.serialNumberDevice});

  Future<bool> checkConnection() async {
    try {
      if (await _tcpScan.checkWifiConnection()) {
        return true;
      } else {
        throw Exception('No DELILED device has been found !');
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> setDeviceToStop() async {
    await _tcpSocket.sendMessage(this, '{\"mode\":\"STOP\"}');
    final bool result = await checkData(_tcpSocket.getMessage());
    return result;
  }

  Future<bool> getDeviceConnectionState() async {
    await _tcpSocket.sendMessage(this, '{\"mode\":\"PING\"}');
    final bool result = await checkData(_tcpSocket.getMessage());
    return result;
  }

  Future<bool> getDeviceData() async {
    await _tcpSocket.sendMessage(this, 'GETINFO_1.1');
    final bool result = await checkData(_tcpSocket.getMessage());
    return result;
  }

  Future<bool> setDisinfectionProcess() async {
    String disinfectionData = '{\"mode\":\"SETDISINFECT\",\"Time\":[$disinfectionTime,$activationTime],\"data\":[\"$deviceCompanyName\",\"$deviceOperatorName\",\"$deviceRoomName\"]}';
    await _tcpSocket.sendMessage(this, disinfectionData);
    final bool result = await checkData(_tcpSocket.getMessage());
    return result;
  }

  Future<bool> startDisinfectionProcess() async {
    String disinfectionData = '{\"mode\":\"START\"}';
    await _tcpSocket.sendMessage(this, disinfectionData);
    return await checkData(_tcpSocket.getMessage());
  }

  Future<bool> setDeviceTime() async {
    DateTime dateTime = DateTime.now();
    String timeData = '{\"mode\":\"SETTIME\",\"Time\":[${dateTime.millisecondsSinceEpoch ~/ 1000},\"$embeddedTimeZone\",${dateTime.timeZoneOffset.inSeconds}]}';
    await _tcpSocket.sendMessage(this, timeData);
    final bool result = await checkData(_tcpSocket.getMessage());
    return result;
  }

  Map<String, dynamic> getData() {
    return {
      'name': deviceName,
      'wifi': [deviceAPSSID, deviceAPPassword],
      'timeDYS': [disinfectionTime, activationTime],
      'dataDYS': [deviceCompanyName, deviceOperatorName, deviceRoomName],
      'state': state
    };
  }

  Future<bool> checkData(String dataMessage) {
    String data = dataMessage.replaceAll('\'', '\"');
    Map<String, dynamic> mapData;
    // subtract data
    try {
      //eliminate the unwanted space inside data
      String finalData = data.substring(0, data.indexOf('}'));
      finalData = '$finalData}';
      debugPrint(finalData);
      // JSON data
      mapData = jsonDecode(finalData);
      bool result = true;
      switch (mapData['data'].toString()) {
        case 'INFO':
          deviceName = mapData['name'];
          List<int> timeList = List<int>.from(mapData['timeDYS']);
          List<String> wifiList = List<String>.from(mapData['wifi']);
          List<String> dataList = List<String>.from(mapData['dataDYS']);
          deviceCompanyName = dataList.first;
          deviceOperatorName = dataList.elementAt(1);
          deviceRoomName = dataList.last;
          disinfectionTime = timeList.first;
          activationTime = timeList.last;
          deviceAPSSID = wifiList.first;
          deviceAPPassword = wifiList.last;
          //state = mapData['state'];
          switch (mapData['state']) {
            case 'NONE':
              state = 0;
              break;
            case 'LOADING':
              state = 1;
              break;
            case 'ERROR':
              state = 2;
              break;
            case 'STARTING':
              state = 3;
              break;
            case 'UVC':
              state = 4;
              break;
            case 'IDLE':
              state = 5;
              break;
            default:
              state = -1;
              break;
          }
          break;
        case 'START':
          debugPrint(mapData['timeSTAMP']);
          debugPrint('Disinfection Started');
          break;
        case 'success':
          debugPrint('DATA is correct and well received');
          break;
        case 'PONG':
          debugPrint('we have PONG from device');
          break;
        default:
          result = false;
          break;
      }
      return Future<bool>.value(result);
    } catch (e) {
      debugPrint('uvc device : ${e.toString()}');
      return Future<bool>.value(false);
    }
  }
}
