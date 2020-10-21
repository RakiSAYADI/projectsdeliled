import 'dart:async';

import 'package:nfc_in_flutter/nfc_in_flutter.dart';

//import 'package:nfc_manager/nfc_manager.dart';

class NFCTagsManager {
  Map<String, dynamic> _tagData;

  Future<bool> checkNFCAvailibility() async {
    return await true/*NfcManager.instance.isAvailable()*/;
  }

  void tagRead() {
// NFC.readNDEF returns a stream of NDEFMessage
    Stream<NDEFMessage> stream = NFC.readNDEF();
    stream.listen((NDEFMessage message) {
      print("id: ${message.id}");
      print("data: ${message.data}");
      print("payload: ${message.payload}");
      print("message type: ${message.messageType}");
      print("type: ${message.type}");
    });
/*    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      _tagData = tag.data;
      print(tag.handle);
      print(_tagData);
    });*/
  }

/*  Future<void> stopNFCTask() async {
    await NfcManager.instance.stopSession();
  }

  Map<String, dynamic> getTagData() {
    return _tagData;
  }

  Future<void> nDefWrite(String text) async {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      Ndef ndef = Ndef.from(tag);
      if (ndef == null || !ndef.isWritable) {
        print('Tag is not ndef writable');
        NfcManager.instance.stopSession(errorMessage: 'Tag is not ndef writable');
        return;
      }

      NdefMessage message = NdefMessage([
        NdefRecord.createText(text),
      ]);

      try {
        print('Writing to nfc');
        await ndef.write(message);
        print('Success to Ndef Write');
        NfcManager.instance.stopSession();
      } catch (e) {
        print('Failed to Ndef Write');
        NfcManager.instance.stopSession();
        return;
      }
    });
  }

  void nDefWriteLock() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      Ndef ndef = Ndef.from(tag);
      if (ndef == null) {
        NfcManager.instance.stopSession(errorMessage: 'Tag is not ndef');
        return;
      }

      try {
        await ndef.writeLock();
        print('Success to "Ndef Write Lock');
        NfcManager.instance.stopSession();
      } catch (e) {
        NfcManager.instance.stopSession(errorMessage: e.toString());
        return;
      }
    });
  }*/
}
