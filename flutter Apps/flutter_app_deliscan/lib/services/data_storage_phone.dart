import 'dart:io';

import 'package:path_provider/path_provider.dart';

class UVCDataFile {
  final String _uvcUserEmailFileName = 'User_email.txt';

  Future<String> readUserEmailDATA() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_uvcUserEmailFileName');
      String email = await file.readAsString();
      return email;
    } catch (e) {
      print("Couldn't read file");
      await saveUserEmailDATA('');
      return '';
    }
  }

  Future<void> saveUserEmailDATA(String userEmail) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_uvcUserEmailFileName');
    await file.writeAsString(userEmail);
    print('saveStringUVCEmailDATA : saved');
  }
}
