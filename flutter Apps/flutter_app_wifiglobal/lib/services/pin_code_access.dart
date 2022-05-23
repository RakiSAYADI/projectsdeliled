import 'dart:io';

import 'package:path_provider/path_provider.dart';

class PINCode {
  final String _defaultPIN = '1234';
  final String _filePIN = 'my_pin_code.txt';

  PINCode();

  Future<String> readPINFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_filePIN');
      String pinCode = await file.readAsString();
      return pinCode;
    } catch (e) {
      print("Couldn't read file");
      savePINFile(_defaultPIN);
      return _defaultPIN;
    }
  }

  savePINFile(String pinCode) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_filePIN');
    await file.writeAsString(pinCode);
    print('saved');
  }
}
