import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';

class SceneClass {
  bool enabled = false;
  String homeId = '';
  String id = '';
  String name = '';
  String background = '';
  List<Map<String, dynamic>> actions = [];

  SceneClass({required this.enabled, required this.homeId, required this.id, required this.name, required this.background, required this.actions});

  Future deleteScene() async {
    waitingRequestWidget();
    final String _queryDeleteScene = '/v1.0/homes/${homeId.toString()}/scenes/$id';
    await tokenAPIRequest.sendRequest(Method.delete, _queryDeleteScene);
    if (tokenAPIRequest.getResponse().isNotEmpty) {
      try {
        Map<String, dynamic> message = tokenAPIRequest.getResponse();
        requestResponse = message['success'] as bool;
      } catch (e) {
        requestResponse = false;
        debugPrint(e.toString());
      }
    }
    exitRequestWidget();
  }
}
