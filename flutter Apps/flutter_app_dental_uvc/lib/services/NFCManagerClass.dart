import 'dart:typed_data';

import 'package:nfc_manager/nfc_manager.dart';

class NFCTagsManager {
  Future<bool> checkNFCAvailibility() async {
    return await NfcManager.instance.isAvailable();
  }

  void tagRead() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      print(tag.data);
      //NfcManager.instance.stopSession();
    });
  }

  void ndefWrite(String text, String uri, String mime) {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      Ndef ndef = Ndef.from(tag);
      if (ndef == null || !ndef.isWritable) {
        print('Tag is not ndef writable');
        NfcManager.instance.stopSession(errorMessage: 'Tag is not ndef writable');
        return;
      }

      NdefMessage message = NdefMessage([
        NdefRecord.createText(text),
        NdefRecord.createUri(Uri.parse(uri)),
        NdefRecord.createMime(mime, Uint8List.fromList('Hello'.codeUnits)),
        NdefRecord.createExternal('com.example', 'mytype', Uint8List.fromList('mydata'.codeUnits)),
      ]);

      try {
        await ndef.write(message);
        print('Success to "Ndef Write');
        NfcManager.instance.stopSession();
      } catch (e) {
        NfcManager.instance.stopSession(errorMessage: e.toString());
        return;
      }
    });
  }

  void ndefWriteLock() {
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
  }
}
