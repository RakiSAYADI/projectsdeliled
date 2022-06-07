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

  List<bool> autoDaysState = [false, false, false, false, false, false, false];
  List<int> autoDaysTrigTime = [0, 0, 0, 0, 0, 0, 0];
  List<int> autoDaysDisinfectionTime = [10, 10, 10, 10, 10, 10, 10];
  List<int> autoDaysActivationTime = [30, 30, 30, 30, 30, 30, 30];

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

  Future<bool> setEncryption() async {
    await _tcpSocket.sendMessage(this, '{\"mode\":\"ENCRYPT\"}');
    final bool result = await checkData(_tcpSocket.getMessage());
    return result;
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

  Future<bool> getDeviceAutoData() async {
    await _tcpSocket.sendMessage(this, 'GETINFO_2.1');
    final bool result = await checkData(_tcpSocket.getMessage());
    return result;
  }

  Future<bool> setAutoUvcData() async {
    String disinfectionData = '{\"mode\":\"AUTOUVC\",'
        '\"Mon\":[${boolToInt(autoDaysState[1])},${autoDaysTrigTime[1]},${autoDaysDisinfectionTime[1]},${autoDaysActivationTime[1]}],'
        '\"Tue\":[${boolToInt(autoDaysState[2])},${autoDaysTrigTime[2]},${autoDaysDisinfectionTime[2]},${autoDaysActivationTime[2]}],'
        '\"Wed\":[${boolToInt(autoDaysState[3])},${autoDaysTrigTime[3]},${autoDaysDisinfectionTime[3]},${autoDaysActivationTime[3]}],'
        '\"Thu\":[${boolToInt(autoDaysState[4])},${autoDaysTrigTime[4]},${autoDaysDisinfectionTime[4]},${autoDaysActivationTime[4]}],'
        '\"Fri\":[${boolToInt(autoDaysState[5])},${autoDaysTrigTime[5]},${autoDaysDisinfectionTime[5]},${autoDaysActivationTime[5]}],'
        '\"Sat\":[${boolToInt(autoDaysState[6])},${autoDaysTrigTime[6]},${autoDaysDisinfectionTime[6]},${autoDaysActivationTime[6]}],'
        '\"Sun\":[${boolToInt(autoDaysState[0])},${autoDaysTrigTime[0]},${autoDaysDisinfectionTime[0]},${autoDaysActivationTime[0]}]}';
    await _tcpSocket.sendMessage(this, disinfectionData);
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
      'state': state,
      'autoMonday': [autoDaysState[1], autoDaysTrigTime[1], autoDaysDisinfectionTime[1], autoDaysActivationTime[1]],
      'autoTuesday': [autoDaysState[2], autoDaysTrigTime[2], autoDaysDisinfectionTime[2], autoDaysActivationTime[2]],
      'autoWednesday': [autoDaysState[3], autoDaysTrigTime[3], autoDaysDisinfectionTime[3], autoDaysActivationTime[3]],
      'autoThursday': [autoDaysState[4], autoDaysTrigTime[4], autoDaysDisinfectionTime[4], autoDaysActivationTime[4]],
      'autoFriday': [autoDaysState[5], autoDaysTrigTime[5], autoDaysDisinfectionTime[5], autoDaysActivationTime[5]],
      'autoSaturday': [autoDaysState[6], autoDaysTrigTime[6], autoDaysDisinfectionTime[6], autoDaysActivationTime[6]],
      'autoSunday': [autoDaysState[0], autoDaysTrigTime[0], autoDaysDisinfectionTime[0], autoDaysActivationTime[0]]
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
          //enableAESEncryption = intToBool(mapData['encrypt']);
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
        case 'AUTO':
          deviceName = mapData['name'];
          _checkAutoUvcDay(mapData, 'Mon', 1);
          _checkAutoUvcDay(mapData, 'Tue', 2);
          _checkAutoUvcDay(mapData, 'Wed', 3);
          _checkAutoUvcDay(mapData, 'Thu', 4);
          _checkAutoUvcDay(mapData, 'Fri', 5);
          _checkAutoUvcDay(mapData, 'Sat', 6);
          _checkAutoUvcDay(mapData, 'Sun', 0);
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

  void _checkAutoUvcDay(Map<String, dynamic> data, String day, int dayId) {
    autoDaysState[dayId] = intToBool(data[day][0]);
    autoDaysTrigTime[dayId] = data[day][1];
    autoDaysDisinfectionTime[dayId] = data[day][2];
    autoDaysActivationTime[dayId] = data[day][3];
  }
}
