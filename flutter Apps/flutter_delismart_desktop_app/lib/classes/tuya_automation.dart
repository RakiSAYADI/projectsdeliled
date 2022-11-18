import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';

class AutomationClass {
  bool enabled = false;
  String id = '';
  String homeId = '';
  String name = '';
  int matchType = 0;
  String conditionRule = '';
  List<Map<String, dynamic>> actions = [];
  List<Map<String, dynamic>> conditions = [];
  List<Map<String, dynamic>> preconditions = [];

  AutomationClass(
      {required this.enabled,
      required this.conditionRule,
      required this.id,
      required this.homeId,
      required this.name,
      required this.matchType,
      required this.actions,
      required this.conditions,
      required this.preconditions});

  Future modifyAutomation(
    String name,
    String match,
    String rule,
    String background,
    List<Map<String, dynamic>> actions,
    List<Map<String, dynamic>> conditions,
    Map<String, dynamic> preconditions,
  ) async {
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
        case 'deviceGroupDpIssue':
          actionsData += "\n{\n" +
              (((element['executor_property'] as Map<String, dynamic>).values.single is String)
                  ? "\"executor_property\":{\n\"${(element['executor_property'] as Map<String, dynamic>).keys.single}\":\"${(element['executor_property'] as Map<String, dynamic>).values.single}\"\n},\n"
                  : "\"executor_property\":{\n\"${(element['executor_property'] as Map<String, dynamic>).keys.single}\":${(element['executor_property'] as Map<String, dynamic>).values.single}\n},\n") +
              "\"action_executor\":\"deviceGroupDpIssue\",\n"
                  "\"entity_id\":\"${element['entity_id']}\"\n"
                  "},";
          break;
        case 'ruleEnable':
        case 'ruleDisable':
        case 'ruleTrigger':
          actionsData += "\n{\n"
              "\"action_executor\":\"${element['action_executor']}\",\n"
              "\"entity_id\":\"${element['entity_id']}\"\n"
              "},";
          break;
      }
    }
    actionsData = actionsData.substring(0, actionsData.length - 1);
    actionsData += "\n]";
    String conditionsData = "[ ";
    for (var element in conditions) {
      switch (element['entity_type']) {
        case 1:
          conditionsData += "\n{\n"
                  "\"display\":{\n"
                  "\"code\":\"${(element['display'] as Map<String, dynamic>)['code']}\",\n"
                  "\"operator\":\"${(element['display'] as Map<String, dynamic>)['operator']}\",\n" +
              (((element['display'] as Map<String, dynamic>)['value'] is String)
                  ? "\"value\":\"${(element['display'] as Map<String, dynamic>)['value']}\"\n"
                  : "\"value\":${(element['display'] as Map<String, dynamic>)['value']}\n") +
              "},\n"
                  "\"entity_id\":\"${element['entity_id']}\",\n"
                  "\"entity_type\":\"${element['entity_type']}\",\n"
                  "\"order_num\":\"${element['order_num']}\"\n"
                  "},";
          break;
        case 3:
          conditionsData += "\n{\n"
                  "\"display\":{\n"
                  "\"code\":\"${(element['display'] as Map<String, dynamic>)['code']}\",\n"
                  "\"operator\":\"${(element['display'] as Map<String, dynamic>)['operator']}\",\n" +
              (((element['display'] as Map<String, dynamic>)['value'] is String)
                  ? "\"value\":\"${(element['display'] as Map<String, dynamic>)['value']}\"\n"
                  : "\"value\":${(element['display'] as Map<String, dynamic>)['value']}\n") +
              "},\n"
                  "\"entity_id\":\"${element['entity_id']}\",\n"
                  "\"entity_type\":\"${element['entity_type']}\",\n"
                  "\"order_num\":\"${element['order_num']}\"\n"
                  "},";
          break;
        case 6:
          conditionsData += "\n{\n"
              "\"display\":{\n"
              "\"date\":\"${(element['display'] as Map<String, dynamic>)['date']}\",\n"
              "\"loops\":\"${(element['display'] as Map<String, dynamic>)['loops']}\",\n"
              "\"time\":\"${(element['display'] as Map<String, dynamic>)['time']}\",\n"
              "\"timezone_id\":\"${(element['display'] as Map<String, dynamic>)['timezone_id']}\"\n"
              "},\n"
              "\"entity_id\":\"timer\",\n"
              "\"entity_type\":\"${element['entity_type']}\",\n"
              "\"order_num\":\"${element['order_num']}\"\n"
              "},";
          break;
        case 15:
          conditionsData += "\n{\n"
                  "\"display\":{\n"
                  "\"code\":\"${(element['display'] as Map<String, dynamic>)['code']}\",\n"
                  "\"operator\":\"${(element['display'] as Map<String, dynamic>)['operator']}\",\n" +
              (((element['display'] as Map<String, dynamic>)['value'] is String)
                  ? "\"value\":\"${(element['display'] as Map<String, dynamic>)['value']}\"\n"
                  : "\"value\":${(element['display'] as Map<String, dynamic>)['value']}\n") +
              "},\n"
                  "\"entity_type\":\"${element['entity_type']}\",\n"
                  "\"order_num\":\"${element['order_num']}\"\n"
                  "},";
          break;
      }
    }
    conditionsData = conditionsData.substring(0, conditionsData.length - 1);
    conditionsData += "\n]";
    String preconditionsData = "[ ";
    if (preconditions.isNotEmpty) {
      preconditionsData += "\n{\n"
          "\"display\":{\n"
          "\"start\":\"${(preconditions['display'] as Map<String, dynamic>)['start']}\",\n"
          "\"end\":\"${(preconditions['display'] as Map<String, dynamic>)['end']}\",\n"
          "\"loops\":\"${(preconditions['display'] as Map<String, dynamic>)['loops']}\",\n"
          "\"timezone_id\":\"${(preconditions['display'] as Map<String, dynamic>)['timezone_id']}\"\n"
          "},\n"
          "\"cond_type\":\"timeCheck\"\n"
          "},";
    }
    preconditionsData = preconditionsData.substring(0, preconditionsData.length - 1);
    preconditionsData += "\n]";
    final String _queryModifyScene = '/v1.0/homes/$homeId/automations/$id';
    await tokenAPIRequest.sendRequest(Method.put, _queryModifyScene,
        body: "{\n"
            "\"name\":\"$name\",\n"
            "\"background\":\"$background\",\n"
            "\"match_type\":$match,\n"
            "\"condition_rule\":\"$rule\",\n"
            "\"actions\":$actionsData,\n"
            "\"conditions\":$conditionsData,\n"
            "\"preconditions\":$preconditionsData\n"
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

  Future enableAutomation() async {
    waitingRequestWidget();
    final String _queryDeleteAutomation = '/v1.0/homes/$homeId/automations/$id/actions/enable';
    await tokenAPIRequest.sendRequest(Method.put, _queryDeleteAutomation);
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

  Future disableAutomation() async {
    waitingRequestWidget();
    final String _queryDeleteAutomation = '/v1.0/homes/$homeId/automations/$id/actions/disable';
    await tokenAPIRequest.sendRequest(Method.put, _queryDeleteAutomation);
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
    final String _queryDeleteAutomation = '/v1.0/homes/$homeId/automations/$id';
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
