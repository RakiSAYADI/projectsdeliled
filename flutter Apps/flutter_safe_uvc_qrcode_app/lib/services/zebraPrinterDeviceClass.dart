import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/Image_To_ZPL.dart';
import 'package:flutter_zebra_sdk/flutter_zebra_sdk.dart';

final ZPLConverter _zplConverter = new ZPLConverter();

class ZebraWifiPrinter {
  String name;
  String address;
  int port;

  ZebraWifiPrinter({@required this.name, @required this.address, @required this.port});

  Future<bool> printFile(File fileToPrint, bool compressEnable, int Blackness) async {
    _zplConverter.setCompressHex(compressEnable);
    _zplConverter.setBlacknessLimitPercentage(Blackness);
    String dataSPL = await _zplConverter.convertImgToZpl(await fileToPrint.readAsBytes());
    bool result = false;
    try {
      await ZebraSdk.printZPLOverTCPIP(address, port: port, data: dataSPL).then((message) {
        print(message);
        if (Platform.isAndroid) {
          if (message.contains('success=true') && message.contains('message=Successfully!')) {
            result = true;
          }
        }
        if (Platform.isIOS) {
          Map<String, dynamic> response = jsonDecode(message);
          if (response['success'] && (response['message'].toString() == 'Successfully!')) {
            result = true;
          }
        }
      });
    } catch (e) {
      result = false;
      print(e);
    }
    return result;
  }
}

class ZebraBLEPrinter {
  BluetoothDevice zebraPrinter;
  List<BluetoothService> _zebraPrinterServices;
  bool _isConnected = false;

  ZebraBLEPrinter({@required this.zebraPrinter});

  void _connectionState() {
    zebraPrinter.state.listen((state) {
      switch (state) {
        case BluetoothDeviceState.connected:
          _isConnected = true;
          break;
        case BluetoothDeviceState.disconnected:
          _isConnected = false;
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

  Future<bool> printFile(File fileToPrint, bool compressEnable, int Blackness) async {
    _zplConverter.setCompressHex(compressEnable);
    _zplConverter.setBlacknessLimitPercentage(Blackness);
    String dataSPL = await _zplConverter.convertImgToZpl(await fileToPrint.readAsBytes());
    bool result = false;
    _connectionState();
    try {
      if (Platform.isIOS) {
        zebraPrinter.connect(timeout: Duration(seconds: 1));
        await Future.delayed(Duration(seconds: 1));
        if (_isConnected) {
          _zebraPrinterServices = await zebraPrinter.discoverServices();
          print('printer is connected');
          await Future.delayed(Duration(milliseconds: 500));
          if (dataSPL.length > 180) {
            int dataSentProgress = 0;
            double numberOfSend = dataSPL.length / 180;
            for (int i = 0; i < numberOfSend.round(); i++) {
              if (i == numberOfSend.round() - 1) {
                _writeCharacteristic(1, 1, dataSPL.substring(dataSentProgress));
              } else {
                _writeCharacteristic(1, 1, dataSPL.substring(dataSentProgress, dataSentProgress + 180));
                dataSentProgress += 180;
              }
              await Future.delayed(Duration(milliseconds: 300));
            }
          } else {
            _writeCharacteristic(1, 1, dataSPL);
          }
          await Future.delayed(Duration(seconds: 3));
          await zebraPrinter.disconnect();
          print('disconnected');
          result = true;
        } else {
          result = false;
        }
      }
      if (Platform.isAndroid) {
        zebraPrinter.connect(timeout: Duration(seconds: 1));
        await Future.delayed(Duration(seconds: 2));
        if (_isConnected) {
          await zebraPrinter.requestMtu(512);
          final mtu = await zebraPrinter.mtu.first;
          print(mtu);
          await Future.delayed(Duration(milliseconds: 500));
          _zebraPrinterServices = await zebraPrinter.discoverServices();
          print('printer is connected');
          await Future.delayed(Duration(seconds: 1));
          if (dataSPL.length > mtu) {
            int dataSentProgress = 0;
            double numberOfSend = dataSPL.length / mtu;
            for (int i = 0; i < numberOfSend.round(); i++) {
              if (i == numberOfSend.round() - 1) {
                _writeCharacteristic(3, 1, dataSPL.substring(dataSentProgress));
              } else {
                _writeCharacteristic(3, 1, dataSPL.substring(dataSentProgress, dataSentProgress + mtu));
                dataSentProgress += mtu;
              }
              await Future.delayed(Duration(seconds: 1));
            }
          } else {
            _writeCharacteristic(3, 1, dataSPL);
          }
          await Future.delayed(Duration(seconds: 3));
          await zebraPrinter.disconnect();
          print('disconnected');
          result = true;
        } else {
          result = false;
        }
      }
    } catch (e) {
      result = false;
      await zebraPrinter.disconnect();
      print('disconnected');
      print(e);
    }
    return result;
  }

  Future<int> _writeCharacteristic(int servicePosition, int charPosition, String data) async {
    // checking Connection
    if (_isConnected) {
      // writing characteristic after 1 second
      await Future.delayed(const Duration(seconds: 1), () async {
        List<int> messageToBytes = data.codeUnits;
        await _zebraPrinterServices.elementAt(servicePosition).characteristics.elementAt(charPosition).write(messageToBytes);
      });
      return 0;
    } else {
      return -1;
    }
  }
}
