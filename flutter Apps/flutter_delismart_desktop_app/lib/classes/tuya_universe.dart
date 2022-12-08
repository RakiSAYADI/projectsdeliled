import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_automation.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_device.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_home_user.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_room.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_scene.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';

class UniverseClass {
  String geoName = '';
  int id = 0;
  double lat = 0;
  double lon = 0;
  String name = '';
  String role = '';
  List<RoomClass> rooms = [];
  List<DeviceClass> devices = [];
  List<UniverseUserClass> users = [];
  List<SceneClass> scenes = [];
  List<AutomationClass> automations = [];

  String _queryGetDevicesList = '';
  String _queryGetMembersList = '';
  String _queryGetScenesList = '';
  String _queryGetRoomsList = '';
  String _queryGetAutomationsList = '';
  String _queryGetSupportedMethodsList = '';

  UniverseClass({required this.geoName, required this.id, this.lat = 0.0, this.lon = 0.0, required this.name, required this.role});

  Future addAutomation(
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
          });
          actionsData += "\n{\n"
              "\"executor_property\":{\n$dpIssueData},\n"
              "\"action_executor\":\"dpIssue\",\n"
              "\"entity_id\":\"${element['entity_id']}\"\n"
              "},";
          break;
        case 'deviceGroupDpIssue':
          actionsData += "\n{\n"
              "\"executor_property\":{\n${element['executor_property']}},\n"
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
    final String _queryAddScene = '/v1.0/homes/${id.toString()}/automations';
    if (name.contains('"') || name.contains('\'')) {
      name = name.replaceAll('"', '');
      name = name.replaceAll('\'', '');
    }
    await tokenAPIRequest.sendRequest(Method.post, _queryAddScene,
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
        if (!requestResponse) {
          apiMessage = message['msg'] as String;
        }
      } catch (e) {
        requestResponse = false;
        debugPrint(e.toString());
      }
    }
    exitRequestWidget();
  }

  Future addScene(String name, String background, List<Map<String, dynamic>> actions) async {
    waitingRequestWidget();
    String actionsData = "[ ";
    String dpIssueData = '';
    debugPrint(actions.length.toString());
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
        case 'deviceGroupDpIssue':
          actionsData += "\n{\n"
              "\"executor_property\":{\n${element['executor_property']}},\n"
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
    final String _queryAddScene = '/v1.0/homes/${id.toString()}/scenes';
    if (name.contains('"') || name.contains('\'')) {
      name = name.replaceAll('"', '');
      name = name.replaceAll('\'', '');
    }
    debugPrint("{\n"
        "\"name\":\"$name\",\n"
        "\"background\":\"$background\",\n"
        "\"actions\":$actionsData\n"
        "}");
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
        if (!requestResponse) {
          apiMessage = message['msg'] as String;
        }
      } catch (e) {
        requestResponse = false;
        debugPrint(e.toString());
      }
    }
    exitRequestWidget();
  }

  Future getSupportedLMethods() async {
    waitingRequestWidget();
    _queryGetSupportedMethodsList = '/v1.0/homes/$id/enable-linkage/codes';
    await tokenAPIRequest.sendRequest(Method.get, _queryGetSupportedMethodsList);
    if (tokenAPIRequest.getResponse().isNotEmpty) {
      try {
        Map<String, dynamic> message = tokenAPIRequest.getResponse();
        requestResponse = message['success'] as bool;
        if (requestResponse) {
          List<dynamic> result = message['result'] as List<dynamic>;
          for (Map<String, dynamic> device in result) {
            devices.any((deviceUniverse) {
              if (deviceUniverse.id == device['device_id']) {
                List<Map<String, dynamic>> conditions = [];
                for (var function in device['status']) {
                  conditions.add(function);
                }
                List<Map<String, dynamic>> functions = [];
                for (var function in device['functions']) {
                  functions.add(function);
                }
                deviceUniverse.addSupportedConditions(conditions);
                deviceUniverse.addSupportedFunctions(functions);
                return true;
              } else {
                return false;
              }
            });
          }
        } else {
          apiMessage = message['msg'] as String;
        }
      } catch (e) {
        requestResponse = false;
        debugPrint(e.toString());
      }
    }
    exitRequestWidget();
  }

  Future deleteUserUniverse(String userId) async {
    waitingRequestWidget();
    final String _queryDeleteUserUniverse = '/v1.0/homes/${id.toString()}/members/$userId';
    await tokenAPIRequest.sendRequest(Method.delete, _queryDeleteUserUniverse);
    if (tokenAPIRequest.getResponse().isNotEmpty) {
      try {
        Map<String, dynamic> message = tokenAPIRequest.getResponse();
        requestResponse = message['success'] as bool;
        if (!requestResponse) {
          apiMessage = message['msg'] as String;
        }
      } catch (e) {
        requestResponse = false;
        debugPrint(e.toString());
      }
    }
    exitRequestWidget();
  }

  Future addUserUniverse(bool state, String userName, String userEmail) async {
    waitingRequestWidget();
    final String _queryChangeStateUserUniverse = '/v1.0/homes/${id.toString()}/members';
    await tokenAPIRequest.sendRequest(Method.post, _queryChangeStateUserUniverse,
        body: "{\n"
            "\"app_schema\": \"$schema\",\n"
            "\"member\": {\n"
            "\"country_code\": \"33\",\n"
            "\"member_account\": \"$userEmail\",\n"
            "\"admin\": ${state.toString()},\n"
            "\"name\": \"$userName\""
            "\n}"
            "\n}");
    if (tokenAPIRequest.getResponse().isNotEmpty) {
      try {
        Map<String, dynamic> message = tokenAPIRequest.getResponse();
        requestResponse = message['success'] as bool;
        if (!requestResponse) {
          apiMessage = message['msg'] as String;
        }
      } catch (e) {
        requestResponse = false;
        debugPrint(e.toString());
      }
    }
    exitRequestWidget();
  }

  Future addRoomUniverse(String name) async {
    waitingRequestWidget();
    final String _queryAddRoomUniverse = '/v1.0/homes/${id.toString()}/room';
    await tokenAPIRequest.sendRequest(Method.post, _queryAddRoomUniverse,
        body: "{\n"
            "\"name\": \"$name\""
            "\n}");
    if (tokenAPIRequest.getResponse().isNotEmpty) {
      try {
        Map<String, dynamic> message = tokenAPIRequest.getResponse();
        requestResponse = message['success'] as bool;
        if (!requestResponse) {
          apiMessage = message['msg'] as String;
        }
      } catch (e) {
        requestResponse = false;
        debugPrint(e.toString());
      }
    }
    exitRequestWidget();
  }

  Future modifyUniverse(String name, String address, String lon, String lat) async {
    waitingRequestWidget();
    final String _queryModifyUniverse = '/v1.0/homes/${id.toString()}';
    await tokenAPIRequest.sendRequest(Method.put, _queryModifyUniverse,
        body: "{\n"
            "\"name\": \"$name\",\n"
            "\"geo_name\": \"$address\",\n"
            "\"lat\": $lat,\n"
            "\"lon\": $lon"
            "\n}");
    if (tokenAPIRequest.getResponse().isNotEmpty) {
      try {
        Map<String, dynamic> message = tokenAPIRequest.getResponse();
        requestResponse = message['success'] as bool;
        if (!requestResponse) {
          apiMessage = message['msg'] as String;
        }
      } catch (e) {
        requestResponse = false;
        debugPrint(e.toString());
      }
    }
    exitRequestWidget();
  }

  Future changeStateUserUniverse(bool state, String userId) async {
    waitingRequestWidget();
    final String _queryChangeStateUserUniverse = '/v1.0/homes/${id.toString()}/members/$userId';
    await tokenAPIRequest.sendRequest(Method.put, _queryChangeStateUserUniverse,
        body: "{\n"
            "\"admin\": ${state.toString()}"
            "\n}");
    if (tokenAPIRequest.getResponse().isNotEmpty) {
      try {
        Map<String, dynamic> message = tokenAPIRequest.getResponse();
        requestResponse = message['success'] as bool;
        if (!requestResponse) {
          apiMessage = message['msg'] as String;
        }
      } catch (e) {
        requestResponse = false;
        debugPrint(e.toString());
      }
    }
    exitRequestWidget();
  }

  Future getScenes() async {
    waitingRequestWidget();
    _queryGetScenesList = '/v1.0/homes/$id/scenes';
    await tokenAPIRequest.sendRequest(Method.get, _queryGetScenesList);
    if (tokenAPIRequest.getResponse().isNotEmpty) {
      try {
        Map<String, dynamic> message = tokenAPIRequest.getResponse();
        requestResponse = message['success'] as bool;
        if (requestResponse) {
          List<dynamic> result = message['result'] as List<dynamic>;
          scenes.clear();
          for (int i = 0; i < result.length; i++) {
            scenes.add(SceneClass(
              name: result[i]['name'],
              homeId: id.toString(),
              background: (result[i] as Map).containsKey('background') ? result[i]['background'] : '',
              enabled: result[i]['enabled'] as bool,
              id: result[i]['scene_id'],
              actions: _getListMapFromApi(result[i]['actions']),
            ));
          }
        } else {
          apiMessage = message['msg'] as String;
        }
      } catch (e) {
        requestResponse = false;
        debugPrint(e.toString());
      }
    }
    exitRequestWidget();
  }

  Future getRooms() async {
    waitingRequestWidget();
    _queryGetRoomsList = '/v1.0/homes/$id/rooms';
    await tokenAPIRequest.sendRequest(Method.get, _queryGetRoomsList);
    if (tokenAPIRequest.getResponse().isNotEmpty) {
      try {
        Map<String, dynamic> message = tokenAPIRequest.getResponse();
        requestResponse = message['success'] as bool;
        if (requestResponse) {
          Map<String, dynamic> result = message['result'] as Map<String, dynamic>;
          List<dynamic> resultRooms = result['rooms'] as List<dynamic>;
          rooms.clear();
          for (int i = 0; i < resultRooms.length; i++) {
            rooms.add(RoomClass(
              name: resultRooms[i]['name'],
              id: resultRooms[i]['room_id'],
              homeId: result['home_id'],
            ));
          }
        } else {
          apiMessage = message['msg'] as String;
        }
      } catch (e) {
        requestResponse = false;
        debugPrint(e.toString());
      }
    }
    exitRequestWidget();
  }

  Future getAutomations() async {
    waitingRequestWidget();
    _queryGetAutomationsList = '/v1.0/homes/$id/automations';
    await tokenAPIRequest.sendRequest(Method.get, _queryGetAutomationsList);
    if (tokenAPIRequest.getResponse().isNotEmpty) {
      try {
        Map<String, dynamic> message = tokenAPIRequest.getResponse();
        requestResponse = message['success'] as bool;
        if (requestResponse) {
          List<dynamic> result = message['result'] as List<dynamic>;
          automations.clear();
          for (int i = 0; i < result.length; i++) {
            automations.add(AutomationClass(
              name: result[i]['name'],
              enabled: result[i]['enabled'] as bool,
              matchType: result[i]['match_type'] as int,
              conditionRule: (result[i] as Map<String, dynamic>).containsKey('condition_rule') ? result[i]['condition_rule'] : '',
              id: result[i]['automation_id'],
              homeId: id.toString(),
              actions: _getListMapFromApi(result[i]['actions']),
              conditions: _getListMapFromApi(result[i]['conditions']),
              preconditions: _getListMapFromApi(result[i]['preconditions']),
            ));
          }
        } else {
          apiMessage = message['msg'] as String;
        }
      } catch (e) {
        requestResponse = false;
        debugPrint(e.toString());
      }
    }
    exitRequestWidget();
  }

  Future getUsers() async {
    waitingRequestWidget();
    _queryGetMembersList = '/v1.0/homes/$id/members';
    await tokenAPIRequest.sendRequest(Method.get, _queryGetMembersList);
    if (tokenAPIRequest.getResponse().isNotEmpty) {
      try {
        Map<String, dynamic> message = tokenAPIRequest.getResponse();
        requestResponse = message['success'] as bool;
        if (requestResponse) {
          List<dynamic> result = message['result'] as List<dynamic>;
          users.clear();
          for (int i = 0; i < result.length; i++) {
            users.add(UniverseUserClass(
              admin: result[i]['admin'] as bool,
              avatarImage: result[i]['avatar'],
              countryCode: result[i]['country_code'],
              memberAccount: result[i]['member_account'],
              name: result[i]['name'],
              owner: result[i]['owner'] as bool,
              uid: result[i]['uid'],
            ));
          }
        } else {
          apiMessage = message['msg'] as String;
        }
      } catch (e) {
        requestResponse = false;
        debugPrint(e.toString());
      }
    }
    exitRequestWidget();
  }

  Future getDevices() async {
    waitingRequestWidget();
    _queryGetDevicesList = '/v1.0/homes/$id/devices';
    await tokenAPIRequest.sendRequest(Method.get, _queryGetDevicesList);
    if (tokenAPIRequest.getResponse().isNotEmpty) {
      try {
        Map<String, dynamic> message = tokenAPIRequest.getResponse();
        requestResponse = message['success'] as bool;
        if (requestResponse) {
          List<dynamic> result = message['result'] as List<dynamic>;
          devices.clear();
          for (int i = 0; i < result.length; i++) {
            List<Map<String, dynamic>> functions = [];
            for (var function in result[i]['status']) {
              functions.add(function);
            }
            devices.add(DeviceClass(
                activeTime: int.parse(result[i]['active_time'].toString()),
                bizType: int.parse(result[i]['biz_type'].toString()),
                category: result[i]['category'],
                createTime: int.parse(result[i]['create_time'].toString()),
                imageUrl: result[i]['icon'],
                id: result[i]['id'],
                ip: result[i]['ip'],
                lat: result[i]['lat'],
                lon: result[i]['lon'],
                model: result[i]['model'],
                name: result[i]['name'],
                online: result[i]['online'] as bool,
                homeId: id.toString(),
                ownerId: result[i]['owner_id'],
                productId: result[i]['product_id'],
                productName: result[i]['product_name'],
                sub: result[i]['sub'] as bool,
                timeZone: result[i]['time_zone'],
                uid: result[i]['uid'],
                updateTime: int.parse(result[i]['update_time'].toString()),
                uuid: result[i]['uuid'],
                functions: functions));
          }
        } else {
          apiMessage = message['msg'] as String;
        }
      } catch (e) {
        requestResponse = false;
        debugPrint(e.toString());
      }
    }
    exitRequestWidget();
  }

  List<Map<String, dynamic>> _getListMapFromApi(List<dynamic> data) {
    List<Map<String, dynamic>> argument = [];
    for (int i = 0; i < data.length; i++) {
      argument.add(data[i] as Map<String, dynamic>);
    }
    return argument;
  }
}
