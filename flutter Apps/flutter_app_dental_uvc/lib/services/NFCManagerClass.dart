import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterappdentaluvc/services/uvcToast.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';

class NFCTagsManager {
  StreamSubscription<NDEFMessage> _stream;
  String _nfcMessage;
  bool _appIsConnected = false;
  BuildContext _context;
  ToastyMessage myUvcToast ;

  void setContext(BuildContext context) {
    this._context = context;
  }

  Future<bool> checkNFCAvailibility() async {
    return await NFC.isNDEFSupported;
  }

  Future<void> stopNFCTask() async {
    _appIsConnected = true;
    await _stream.cancel();
  }

  void startNFCTask() async {
    myUvcToast = ToastyMessage(toastContext: _context);
    _appIsConnected = false;
    // NFC.readNDEF returns a stream of NDEFMessage
    _stream = await NFC
        .readNDEF(
      throwOnUserCancel: false,
    )
        .listen((NDEFMessage message) {
      if (!_appIsConnected) {
        print("id: ${message.id}");
        print("data: ${message.data}");
        print("payload: ${message.payload}");
        print("message type: ${message.messageType}");
        print("type: ${message.type}");
        try {
          if (message.data.contains('Deliled')) {
            myUvcToast.setToastDuration(2);
            myUvcToast.setToastMessage('Le Tag est correcte!');
            myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
            print('its our tags');
            _nfcMessage = message.data.substring(8);
            //stopNFCTask();
          } else {
            print('its not our tags');
          }
        } catch (e) {
          myUvcToast.setToastDuration(2);
          myUvcToast.setToastMessage('Le Tag est vide!');
          myUvcToast.showToast(Colors.red, Icons.thumb_down, Colors.white);
          print('its not our tags and its empty');
        }
      }
    }, onError: (e) {
      // Check error handling guide below
    });
  }

  String nfcGetMessage() {
    return _nfcMessage;
  }
}
