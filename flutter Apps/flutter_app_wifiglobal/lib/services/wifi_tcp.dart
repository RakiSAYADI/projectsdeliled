import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wifiglobalapp/services/aes_cbc_crypt.dart';
import 'package:wifiglobalapp/services/data_variables.dart';
import 'package:wifiglobalapp/services/uvc_device.dart';

class TCPSocket {
  List<String> _ipDevices = ['192.168.2.1'];
  Device _myDevice = Device('', macDevice: '', manufacture: '', nameDevice: '', serialNumberDevice: '');
  final _plainText = '\$discover HuBBoX DELILED\t\n';
  Socket? _socket;
  String _messageReceived = '';

  TCPSocket();

  Future<void> scanForDevices() async {
    _ipDevices.clear();
    listOfDevices.clear();
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
      break;
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
        listOfDevices.add(Device(socket.address.address, macDevice: dataInfo['mac'], manufacture: dataInfo['man'], nameDevice: dataInfo['name'], serialNumberDevice: dataInfo['sn']));
      } catch (e) {
        debugPrint(e.toString());
      }
    });
    _ipDevices.add(socket.address.address);
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

  void setDevice(Device device) => _myDevice = device;

  Device getDevice() => _myDevice;

  String getMessage() => _messageReceived;

  List<String> getScanList() => _ipDevices;

  Future<bool> sendMessage(String message) async {
    try {
      _socket = await Socket.connect(_myDevice.deviceAddress, port);
      debugPrint('connected');

      aesCbcCrypt = AESCbcCrypt(_myDevice.macDevice, textString: _plainText);
      aesCbcCrypt.setKeysEnvironment();

      // listen to the received data event stream
      _socket!.listen((List<int> message) {
        try {
          debugPrint('message received : ${utf8.decode(message)}');
          aesCbcCrypt.setText(utf8.decode(message).toLowerCase());
          aesCbcCrypt.decrypt();
          debugPrint(aesCbcCrypt.getDecryptedText());
          _messageReceived = aesCbcCrypt.getDecryptedText();
        } catch (e) {
          debugPrint(e.toString());
          _messageReceived = 'NULL';
        }
      });

      // send crypt message
      aesCbcCrypt.setText(message);
      aesCbcCrypt.encrypt();
      debugPrint(aesCbcCrypt.getCrypted16Text());
      _socket!.write(aesCbcCrypt.getCrypted16Text());

      // .. and close the socket
      _socket!.close();
      if (Platform.isIOS) {
        await Future.delayed(Duration(milliseconds: 500));
      }
      if (Platform.isAndroid) {
        await Future.delayed(Duration(seconds: 1));
      }
      return true;
    } catch (e) {
      debugPrint(e.toString());
      _messageReceived = 'NULL';
      return false;
    }
  }
}
