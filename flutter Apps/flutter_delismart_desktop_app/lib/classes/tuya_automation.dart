import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';

class AutomationClass {
  bool enabled = false;
  String id = '';
  String homeId = '';
  String name = '';
  int matchType = 0;
  List<Map<String, dynamic>> actions = [];
  List<Map<String, dynamic>> conditions = [];
  List<Map<String, dynamic>> preconditions = [];

  AutomationClass(
      {required this.enabled, required this.id, required this.homeId, required this.name, required this.matchType, required this.actions, required this.conditions, required this.preconditions});

  Future addAnimation(String name, String background, List<Map<String, dynamic>> actions, List<Map<String, dynamic>> conditions) async {
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
          });
          actionsData += "\n{\n"
              "\"executor_property\":{\n$dpIssueData},\n"
              "\"action_executor\":\"dpIssue\",\n"
              "\"entity_id\":\"${element['entity_id']}\"\n"
              "},";
          break;
      }
    }
    actionsData = actionsData.substring(0, actionsData.length - 1);
    actionsData += "\n]";
    final String _queryAddScene = '/v1.0/homes/${id.toString()}/automations';
    await tokenAPIRequest.sendRequest(Method.post, _queryAddScene,
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

  Future deleteAutomation() async {
    waitingRequestWidget();
    final String _queryDeleteAutomation = '/v1.0/homes/${homeId.toString()}/automations/$id';
    await tokenAPIRequest.sendRequest(Method.delete, _queryDeleteAutomation);
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
