import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wifiglobalapp/services/aes_cbc_crypt.dart';
import 'package:wifiglobalapp/services/data_variables.dart';
import 'package:wifiglobalapp/services/uvc_device.dart';
import 'package:wifiglobalapp/services/wifi_tcp.dart';

class TCPCommunication {
  String _messageReceived = '';
  Socket? _socket;

  TCPCommunication();

  String getMessage() => _messageReceived;

  Future<bool> sendMessage(Device device, String message) async {
    try {
      if (device.macDevice.isEmpty) {
        TCPScan _tcpScan = TCPScan();
        await _tcpScan.scanTCP(noAllScan: true);
        if (_tcpScan.getScanList().isNotEmpty) {
          myDevice = _tcpScan.selectDevice(0);
          device = myDevice;
        } else {
          return false;
        }
      }
      _socket = await Socket.connect(device.deviceAddress, port);
      debugPrint('connected');

      AESCbcCrypt _aesCbcCrypt = AESCbcCrypt(device.macDevice, textString: '');
      _aesCbcCrypt.setKeysEnvironment();

      // listen to the received data event stream
      _socket!.listen((List<int> message) {
        try {
          debugPrint('message received : ${utf8.decode(message)}');
          _aesCbcCrypt.setText(utf8.decode(message).toLowerCase());
          _aesCbcCrypt.decrypt();
          debugPrint(_aesCbcCrypt.getDecryptedText());
          _messageReceived = _aesCbcCrypt.getDecryptedText();
        } catch (e) {
          debugPrint('device tcp read : ${e.toString()}');
          _messageReceived = 'NULL';
        }
      });

      // send crypt message
      _aesCbcCrypt.setText(message);
      _aesCbcCrypt.encrypt();
      debugPrint(_aesCbcCrypt.getCrypted16Text());
      _socket!.write(_aesCbcCrypt.getCrypted16Text());

      // .. and close the socket
      _socket!.close();
      debugPrint('disconnected');
      if (Platform.isIOS) {
        await Future.delayed(Duration(milliseconds: 500));
      }
      if (Platform.isAndroid) {
        await Future.delayed(Duration(seconds: 1));
      }
      return true;
    } catch (e) {
      debugPrint('device tcp write : ${e.toString()}');
      _messageReceived = 'NULL';
      return false;
    }
  }
}
