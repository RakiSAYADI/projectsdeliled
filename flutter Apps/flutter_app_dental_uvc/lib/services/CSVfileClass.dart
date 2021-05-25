import 'dart:io';

import 'package:path_provider/path_provider.dart';

class UVCDataFile {
  final String _uvcDefaultDataString =
      'Dispositif UVC ;Utilisateur ;Etablissement ;Pi\èce ;Heure d\'activation ;Date d\'activation ;Temps de disinfection (en secondes) ;Etat \n';

  final String _uvcDataFileName = 'RapportUVC.csv';

  final String _uvcUserEmailFileName = 'User_email.txt';

  final String _uvcDeviceFileName = 'UVC_Device.txt';

  final String _uvcAutoDataFileName = 'UVC_Auto_Data.txt';

  final List<List<String>> _uvcDefaultData = [
    [
      'Dispositif UVC',
      'Utilisateur',
      'Etablissement',
      'Pi\èce',
      'Heure D\'activation',
      'Date D\'activation',
      'Temps de disinfection (en secondes)',
      'Etat'
    ]
  ];

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
      print("uvc csv file Readed");
      print(textuvc);
      return textuvc;
    } catch (e) {
      print("Couldn't read file");
      await saveStringUVCDATA(_uvcDefaultDataString);
      print(_uvcDefaultDataString);
      return _uvcDefaultData;
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
      print("email file Readed");
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

  Future<String> readUVCDevice() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_uvcDeviceFileName');
      String uvcDevice = await file.readAsString();
      print("uvc device file Readed");
      return uvcDevice;
    } catch (e) {
      print("Couldn't read file");
      await saveUVCDevice('');
      return '';
    }
  }

  Future<void> saveUVCDevice(String uvcDevice) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_uvcDeviceFileName');
    await file.writeAsString(uvcDevice);
    print('saveUVCDevice : saved');
  }

  Future<String> readUVCAutoData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_uvcAutoDataFileName');
      String uvcAutoData = await file.readAsString();
      print('uvc auto file Readed');
      return uvcAutoData;
    } catch (e) {
      print("Couldn't read file");
      String autoDataDefault = '{'
          '\"Monday\":[0,0,0,0,0,0],'
          '\"Tuesday\":[0,0,0,0,0,0],'
          '\"Wednesday\":[0,0,0,0,0,0],'
          '\"Thursday\":[0,0,0,0,0,0],'
          '\"Friday\":[0,0,0,0,0,0],'
          '\"Saturday\":[0,0,0,0,0,0],'
          '\"Sunday\":[0,0,0,0,0,0]'
          '}';
      await saveUVCAutoData(autoDataDefault);
      return autoDataDefault;
    }
  }

  Future<void> saveUVCAutoData(String uvcAutoData) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_uvcAutoDataFileName');
    await file.writeAsString(uvcAutoData);
    print('saveUVCAutoData saved');
  }
}
