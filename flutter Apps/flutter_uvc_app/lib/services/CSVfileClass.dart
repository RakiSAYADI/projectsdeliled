import 'dart:io';

import 'package:flutteruvcapp/services/DataVariables.dart';
import 'package:flutteruvcapp/services/languageDataBase.dart';
import 'package:path_provider/path_provider.dart';

class UVCDataFile {
  final String _uvcDataFileName = 'RapportUVC.csv';

  final String _uvcUserEmailFileName = 'User_email.txt';

  Future<List<List<String>>> readUVCDATA() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_uvcDataFileName');
      String text = await file.readAsString();
      String column = '';
      List<List<String>> textuvc = [
        ['default']
      ];
      textuvc.length = 0;
      List<String> textuvcrows = ['default'];
      textuvcrows.length = 0;
      for (int i = 0; i < text.length; i++) {
        if (text[i] == '\n') {
          textuvcrows.add(column);
          column = '';
          textuvc.add(textuvcrows);
          textuvcrows = ['default'];
          textuvcrows.length = 0;
        } else if (text[i] == ';') {
          textuvcrows.add(column);
          column = '';
        } else {
          column += text[i];
        }
      }
      //print(textuvc);
      return textuvc;
    } catch (e) {
      print("Couldn't read file");
      await saveStringUVCDATA(uvcDefaultDataString[languageArrayIdentifier]);
      return uvcDefaultData[languageArrayIdentifier];
    }
  }

  Future<bool> fileExist(String path) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$path');
      await file.readAsString();
      return true;
    } catch (e) {
      print("Couldn't read file");
      return false;
    }
  }

  Future<void> saveStringUVCDATA(String uvcData) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_uvcDataFileName');
    await file.writeAsString(uvcData);
    print('saveStringUVCDATA : saved');
  }

  Future<void> saveUVCDATA(List<List<String>> uvcData) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_uvcDataFileName');
    String uvcDATA = '';
    for (int j = 0; j < uvcData.length; j++) {
      for (int i = 0; i < uvcData.elementAt(j).length; i++) {
        if (i == uvcData.elementAt(j).length - 1) {
          uvcDATA += '${uvcData.elementAt(j).elementAt(i)} ';
        } else {
          uvcDATA += '${uvcData.elementAt(j).elementAt(i)} ;';
        }
      }
      uvcDATA += '\n';
    }
    await file.writeAsString(uvcDATA);
    print('saveUVCDATA : saved');
  }

  Future<String> readUserEmailDATA() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_uvcUserEmailFileName');
      String email = await file.readAsString();
      return email;
    } catch (e) {
      print("Couldn't read file");
      await saveStringUVCEmailDATA('');
      return '';
    }
  }

  Future<void> saveStringUVCEmailDATA(String userEmail) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_uvcUserEmailFileName');
    await file.writeAsString(userEmail);
    print('saveStringUVCEmailDATA : saved');
  }
}
