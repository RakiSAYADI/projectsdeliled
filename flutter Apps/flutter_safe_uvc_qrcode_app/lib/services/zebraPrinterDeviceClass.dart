import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/Image_To_ZPL.dart';
import 'package:zsdk/zsdk.dart';

class ZebraWifiPrinter {
  String name;
  String address;
  int port;
  Map<String, dynamic> _state;

  final _zsdk = new ZSDK();

  final ZPLConverter _zplConverter = new ZPLConverter();

  ZebraWifiPrinter({@required this.name, @required this.address, @required this.port});

  Future<bool> printerPing() async => await _zsdk.doManualCalibrationOverTCPIP(address: address, port: port).then((value) {
        bool response = false;
        try {
          final printerResponse = PrinterResponse.fromMap(value);
          Status status = printerResponse.statusInfo.status;
          if (printerResponse.errorCode == ErrorCode.SUCCESS) {
            if (status.name == 'READY_TO_PRINT') {
              print(status);
              response = true;
            }
          } else {
            Cause cause = printerResponse.statusInfo.cause;
            print(cause);
          }
        } catch (e) {
          response = false;
        }
        return response;
      });

  Future<bool> checkPrinterState() async {
    bool state = false;
    await _zsdk.checkPrinterStatusOverTCPIP(address: address, port: port).then((value) {
      try {
        final printerResponse = PrinterResponse.fromMap(value);
        Status status = printerResponse.statusInfo.status;
        if (printerResponse.errorCode == ErrorCode.SUCCESS) {
          if (status.name == 'READY_TO_PRINT') {
            print(status);
            state = true;
          }
        } else {
          Cause cause = printerResponse.statusInfo.cause;
          print(cause);
        }
      } catch (e) {
        state = false;
      }
    });
    return state;
  }

  Future<bool> getPrinterSettings() async {
    bool state = false;
    await _zsdk.getPrinterSettingsOverTCPIP(address: address, port: port).then((value) {
      try {
        final printerSettings = PrinterResponse.fromMap(value).settings;
        print(printerSettings.toMap());
        _state = printerSettings.toMap();
        print(_state);
        state = true;
      } catch (e) {
        state = false;
      }
    });
    return state;
  }

  Future<bool> setPrinterSettings(
      {double darkness,
      double printSpeed,
      int tearOff,
      MediaType mediaType,
      PrintMethod printMethod,
      int printWidth,
      int labelLength,
      double labelLengthMax,
      ZPLMode zplMode,
      PowerUpAction powerUpAction,
      HeadCloseAction headCloseAction,
      int labelTop,
      int leftPosition,
      PrintMode printMode,
      ReprintMode reprintMode}) async {
    bool response = false;
    await _zsdk
        .setPrinterSettingsOverTCPIP(
            address: address,
            port: port,
            settings: PrinterSettings(
                darkness: darkness,
                printSpeed: printSpeed,
                tearOff: tearOff,
                mediaType: mediaType,
                printMethod: printMethod,
                printWidth: printWidth,
                labelLength: labelLength,
                labelLengthMax: labelLengthMax,
                zplMode: zplMode,
                powerUpAction: powerUpAction,
                headCloseAction: headCloseAction,
                labelTop: labelTop,
                leftPosition: leftPosition,
                printMode: printMode,
                reprintMode: reprintMode))
        .then((value) async {
      try {
        final printerResponse = PrinterResponse.fromMap(value);
        if (printerResponse.errorCode == ErrorCode.SUCCESS) {
          response = true;
          await this.getPrinterSettings();
        } else {
          Status status = printerResponse.statusInfo.status;
          print(status);
          Cause cause = printerResponse.statusInfo.cause;
          print(cause);
          response = false;
        }
      } catch (e) {
        response = false;
      }
    });
    return response;
  }

  Future<bool> printFile(File fileToPrint, bool compressEnable, int Blackness) async {
    _zplConverter.setCompressHex(compressEnable);
    _zplConverter.setBlacknessLimitPercentage(Blackness);
    String dataSPL = await _zplConverter.convertImgToZpl(await fileToPrint.readAsBytes());
    bool result = false;
    await _zsdk.printZplDataOverTCPIP(data: dataSPL, address: address, port: port).then((value) {
      try {
        final printerResponse = PrinterResponse.fromMap(value);
        Status status = printerResponse.statusInfo.status;
        if (printerResponse.errorCode == ErrorCode.SUCCESS) {
          print(status);
          result = true;
          //Do something
        } else {
          Cause cause = printerResponse.statusInfo.cause;
          print(cause);
          result = false;
        }
      } catch (e) {
        result = false;
      }
    });
    return result;
  }
}

class ZebraBLEPrinter {
  String name;
  String macAddress;
  final ZPLConverter _zplConverter = new ZPLConverter();

  ZebraBLEPrinter({@required this.name, @required this.macAddress});
}
