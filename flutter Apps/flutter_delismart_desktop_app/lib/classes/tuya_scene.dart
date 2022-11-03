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

  Future triggerScene() async {
    waitingRequestWidget();
    final String _queryTriggerScene = '/v1.0/homes/${homeId.toString()}/scenes/$id/trigger';
    await tokenAPIRequest.sendRequest(Method.post, _queryTriggerScene);
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

  Future modifyScene(String name, String background, List<Map<String, dynamic>> actions) async {
    waitingRequestWidget();
    String actionsData = "[ ";
    String dpIssueData = '';
    for (var element in actions) {
      switch (element['action_executor']) {
        case 'delay':
          actionsData += "\n{\n"
              "\"executor_property\":{\n"
              "\"hours\":\"${(element['executor_property'] as Map<String, dynamic>)['hours']}\",\n"
              "\"minutes\":\"${(element['executor_property'] as Map<String, dynamic>)['minutes']}\",\n"
              "\"seconds\":\"${(element['executor_property'] as Map<String, dynamic>)['seconds']}\"\n"
              "},\n"
              "\"action_executor\":\"delay\"\n"
              "},";
          break;
        case 'dpIssue':
          (element['executor_property'] as Map<String, dynamic>).forEach((key, value) {
            if (value is String) {
              dpIssueData = "\"$key\":\"$value\"\n";
            } else {
              dpIssueData = "\"$key\":$value\n";
            }
            actionsData += "\n{\n"
                "\"executor_property\":{\n$dpIssueData},\n"
                "\"action_executor\":\"dpIssue\",\n"
                "\"entity_id\":\"${element['entity_id']}\"\n"
                "},";
          });
          break;
      }
    }
    actionsData = actionsData.substring(0, actionsData.length - 1);
    actionsData += "\n]";
    final String _queryModifyScene = '/v1.0/homes/${homeId.toString()}/scenes/$id';
    await tokenAPIRequest.sendRequest(Method.put, _queryModifyScene,
        body: "{\n"
            "\"name\":\"$name\",\n"
            "\"background\":\"$background\",\n"
            "\"actions\":$actionsData\n"
            "}");
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
