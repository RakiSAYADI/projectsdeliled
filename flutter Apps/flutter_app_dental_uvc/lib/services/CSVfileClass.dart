import 'dart:io';

import 'package:path_provider/path_provider.dart';

class UVCDataFile {
  String _uvcDefaultDataString = 'Nom du robot ;Utilisateur ;Entreprise ;Chambre ;Temp D\'activation ;Durée de disinfection ;Etat ;\n';

  String _uvcDataFileName = 'UVC_DATA.csv';

  List<List<String>> _uvcDefaultData = [
    ['Nom du robot', 'Utilisateur', 'Entreprise', 'Chambre', 'Temp D\'activation', 'Durée de disinfection', 'Etat']
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
          print('we have /n');
          print(textuvcrows);
          textuvc.add(textuvcrows);
          textuvcrows = ['default'];
          textuvcrows.length = 0;
        } else if (text[i] == ';') {
          print(column);
          textuvcrows.add(column);
          column = '';
        } else {
          column += text[i];
        }
      }
      print(textuvc);
      return textuvc;
    } catch (e) {
      print("Couldn't read file");
      saveUVCDATA(_uvcDefaultDataString);
      return _uvcDefaultData;
    }
  }

  saveUVCDATA(String uvcData) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_uvcDataFileName');
    await file.writeAsString(uvcData);
    print('saved');
  }
}
