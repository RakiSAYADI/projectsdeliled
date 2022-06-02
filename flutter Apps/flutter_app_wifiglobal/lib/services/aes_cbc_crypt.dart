import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart' hide Key;

class AESCbcCrypt {
  String textString = 'test';
  String macAddress = '';

  String _crypt16String = '';
  String _decryptString = '';
  String _keyString = '12345678901234567890123456789012';
  String _IVString = '1234567890123456';

  AESCbcCrypt(this.macAddress, {required this.textString});

  setText(String text) => textString = text;

  setKeysEnvironment() {
    _keyString = 'DELI' + (macAddress.toUpperCase()) + 'LE' + ((int.parse(macAddress, radix: 16) + 3).toRadixString(16).toUpperCase()) + 'FR';
    _IVString = 'DL' + (macAddress.toUpperCase()) + 'FR';
    debugPrint(_keyString);
    debugPrint(_IVString);
  }

  String getCrypted16Text() => _crypt16String;

  String getDecryptedText() => _decryptString;

  bool encrypt() {
    try {
      final key = Key.fromUtf8(_keyString);
      final iv = IV.fromUtf8(_IVString);
      final encrypt = Encrypter(AES(key, mode: AESMode.cbc));
      final encrypted = encrypt.encrypt(textString, iv: iv);
      _crypt16String = encrypted.base16.toUpperCase();
      return true;
    } catch (e) {
      debugPrint('aes encrypt : ${e.toString()}');
      return false;
    }
  }

  bool decrypt() {
    try {
      final key = Key.fromUtf8(_keyString);
      final iv = IV.fromUtf8(_IVString);
      final encrypt = Encrypter(AES(key, mode: AESMode.cbc, padding: null));
      _decryptString = encrypt.decrypt16(textString, iv: iv);
      return true;
    } catch (e) {
      debugPrint('aes decrypt : ${e.toString()}');
      return false;
    }
  }
}
