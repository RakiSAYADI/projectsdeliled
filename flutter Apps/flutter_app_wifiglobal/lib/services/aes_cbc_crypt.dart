import 'package:encrypt/encrypt.dart';

class AESCbcCrypt {
  String keyString = '12345678901234567890123456789012';
  String IVString = '1234567890123456';
  String textString = 'test';

  String _crypt16String = 'test';
  String _decryptString = 'test';

  AESCbcCrypt(this.keyString, this.IVString, {required this.textString});

  setText(String text) => textString = text;

  String getCrypted16Text() => _crypt16String;

  String getDecryptedText() => _decryptString;

  bool encrypt() {
    try {
      final key = Key.fromUtf8(keyString);
      final iv = IV.fromUtf8(IVString);
      final encrypt = Encrypter(AES(key, mode: AESMode.cbc));
      final encrypted = encrypt.encrypt(textString, iv: iv);
      _crypt16String = encrypted.base16.toUpperCase();
      return true;
    } catch (e) {
      return false;
    }
  }

  bool decrypt() {
    try {
      final key = Key.fromUtf8(keyString);
      final iv = IV.fromUtf8(IVString);
      final encrypt = Encrypter(AES(key, mode: AESMode.cbc, padding: null));
      _decryptString = encrypt.decrypt16(textString, iv: iv);
      return true;
    } catch (e) {
      return false;
    }
  }
}
