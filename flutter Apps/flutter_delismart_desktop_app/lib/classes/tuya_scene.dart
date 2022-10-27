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

  Future addScene(String name, String background, List<Map<String, dynamic>> actions) async {
    waitingRequestWidget();
    String actionsData = actions.toString().replaceAll(' ', '');
    actionsData = actionsData.replaceAll(',', '",\n"');
    actionsData = actionsData.replaceAll('[', '[\n');
    actionsData = actionsData.replaceAll(']', '\n]');
    debugPrint(actionsData);
    final String _queryAddScene = '/v1.0/homes/${homeId.toString()}/scenes';
    /*await tokenAPIRequest.sendRequest(Method.post, _queryAddScene,
        body: "{\n"
            "\"name\": \"$name\",\n"
            "\"background\": \"$background\",\n"
            "\"home_id\": \"${homeId.toString()}\",\n"
            "\"actions\": $actionsData\n"
            "\n}");*/
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
