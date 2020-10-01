import 'dart:io';

import 'package:path_provider/path_provider.dart';

class UVCDataFile {

  String uvcDefaultData = 'Update time (with timestamp) ;Temperature(C) ;Humidity(percent) ;';

  String uvcDataFileName='UVC_DATA.txt';

  Future<String> _readUVCDATA() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$uvcDataFileName');
      String text = await file.readAsString();
      print(text);
      return text;
    } catch (e) {
      print("Couldn't read file");
      _saveUVCDATA(uvcDefaultData);
      return uvcDefaultData;
    }
  }

  _saveUVCDATA(String uvcData) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$uvcDataFileName');
    await file.writeAsString(uvcData);
    print('saved');
  }
}
