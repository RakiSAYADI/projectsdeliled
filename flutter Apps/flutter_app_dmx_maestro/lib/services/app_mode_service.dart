import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_dmx_maestro/services/DataVariables.dart';
import 'package:path_provider/path_provider.dart';

class AppMode {
  final String _appModeFileName = 'appMode';

  Future<bool> readAppModeDATA() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_appModeFileName');
      String stateString = await file.readAsString();
      var parsedJson = json.decode(stateString);
      appMode = intToBool(parsedJson['mode']);
      return appMode;
    } catch (e) {
      debugPrint("Couldn't read file");
      await saveAppModeDATA(true);
      return true;
    }
  }

  Future<void> saveAppModeDATA(bool state) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_appModeFileName');
    await file.writeAsString('{\"mode\": ${boolToInt(state)}}');
    debugPrint('saveAppModeDATA : saved');
  }
}
