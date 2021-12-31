import 'dart:convert';
import 'dart:io';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/DataVariables.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/Image_To_ZPL.dart';
import 'package:flutter_zebra_sdk/flutter_zebra_sdk.dart';

class ZebraWifiPrinter {
  String name;
  String address;
  int port;

  Map<String, dynamic> _state;

  final ZPLConverter _zplConverter = new ZPLConverter();

  ZebraWifiPrinter({@required this.name, @required this.address, @required this.port});

  Future<bool> checkPrinterState() async {
    bool state = false;
    try {
      await ZebraSdk.isPrinterConnected(address, port: port).then((isConnected) {
        print(isConnected);
        Map<String, dynamic> response = jsonDecode(isConnected);
        if (response['success'] && (response['message'].toString() == 'Connected!')) {
          state = true;
        }
      });
    } catch (e) {
      state = false;
      print(e);
    }
    return state;
  }

  Future<bool> getPrinterSettings() async {
    bool state = false;
    try {
      await ZebraSdk.onGetPrinterInfo(address, port: port).then((info) {
        _state = info;
      });
    } catch (e) {
      state = false;
      print(e);
    }
    return state;
  }

  Future<bool> printFile(File fileToPrint, bool compressEnable, int Blackness) async {
    _zplConverter.setCompressHex(compressEnable);
    _zplConverter.setBlacknessLimitPercentage(Blackness);
    String dataSPL = await _zplConverter.convertImgToZpl(await fileToPrint.readAsBytes());
    bool result = false;
    try {
      await ZebraSdk.printZPLOverTCPIP(address, port: port, data: dataSPL).then((message) {
        print(message);
        Map<String, dynamic> response = jsonDecode(message);
        if (response['success'] && (response['message'].toString() == 'Connected!')) {
          result = true;
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
  final ZPLConverter _zplConverter = new ZPLConverter();

  ZebraBLEPrinter({@required this.zebraPrinter});

  Future<bool> printBluetooth(File fileToPrint, bool compressEnable, int Blackness) async {
    _zplConverter.setCompressHex(compressEnable);
    _zplConverter.setBlacknessLimitPercentage(Blackness);
    String dataSPL = await _zplConverter.convertImgToZpl(await fileToPrint.readAsBytes());
    bool result = false;
    try {
      await ZebraSdk.printZPLOverBluetooth(zebraPrinter.address, data: dataSPL).then((message) {
        print(message);
        Map<String, dynamic> response = jsonDecode(message);
        if (response['success'] && (response['message'].toString() == 'Connected!')) {
          result = true;
        }
      });
    } catch (e) {
      result = false;
      print(e);
    }
    return result;
  }
}
