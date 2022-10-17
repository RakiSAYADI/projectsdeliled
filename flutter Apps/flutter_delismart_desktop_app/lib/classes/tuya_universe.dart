import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_automation.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_device.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_home_user.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_room.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_scene.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';

class UniverseClass {
  String geoName = '';
  int homeId = 0;
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
  String _queryGetAutomationsList = '';

  UniverseClass({required this.geoName, required this.homeId, this.lat = 0.0, this.lon = 0.0, required this.name, required this.role});

  Future addUserUniverse(bool state, String userName, String userId) async {
    waitingRequestWidget();
    final String _queryChangeStateUserUniversesList = '/v1.0/homes/${homeId.toString()}/members';
    await tokenAPIRequest.sendRequest(Method.post, _queryChangeStateUserUniversesList,
        body: "{\n"
            "\"app_schema\": ${state.toString()},\n"
            "\"member\": {\n"
            "\"country_code\": 33,\n"
            "\"member_account\": $userId,\n"
            "\"admin\": ${state.toString()},\n"
            "\"name\": $userName"
            "\n}"
            "\n}");
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

  Future changeStateUserUniverse(bool state, String userId) async {
    waitingRequestWidget();
    final String _queryChangeStateUserUniversesList = '/v1.0/homes/${homeId.toString()}/members/$userId';
    await tokenAPIRequest.sendRequest(Method.put, _queryChangeStateUserUniversesList,
        body: "{\n"
            "\"admin\": ${state.toString()}"
            "\n}");
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

  Future getScenes() async {
    waitingRequestWidget();
    _queryGetScenesList = '/v1.0/homes/$homeId/scenes';
    await tokenAPIRequest.sendRequest(Method.get, _queryGetScenesList);
    if (tokenAPIRequest.getResponse().isNotEmpty) {
      try {
        Map<String, dynamic> message = tokenAPIRequest.getResponse();
        requestResponse = message['success'] as bool;
        if (requestResponse) {
          List<dynamic> result = message['result'] as List<dynamic>;
          for (int i = 0; i < result.length; i++) {
            scenes.add(SceneClass(
              name: result[i]['name'],
              background: (result[i] as Map).containsKey('background') ? result[i]['background'] : '',
              enabled: result[i]['enabled'] as bool,
              sceneId: result[i]['scene_id'],
              actions: _getListMapFromApi(result[i]['actions']),
            ));
          }
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
    _queryGetAutomationsList = '/v1.0/homes/$homeId/automations';
    await tokenAPIRequest.sendRequest(Method.get, _queryGetAutomationsList);
    if (tokenAPIRequest.getResponse().isNotEmpty) {
      try {
        Map<String, dynamic> message = tokenAPIRequest.getResponse();
        requestResponse = message['success'] as bool;
        if (requestResponse) {
          List<dynamic> result = message['result'] as List<dynamic>;
          for (int i = 0; i < result.length; i++) {
            automations.add(AutomationClass(
              name: result[i]['name'],
              enabled: result[i]['enabled'] as bool,
              matchType: result[i]['match_type'] as int,
              automationId: result[i]['automation_id'],
              actions: _getListMapFromApi(result[i]['actions']),
              conditions: _getListMapFromApi(result[i]['conditions']),
              preconditions: _getListMapFromApi(result[i]['preconditions']),
            ));
          }
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
    _queryGetMembersList = '/v1.0/homes/$homeId/members';
    await tokenAPIRequest.sendRequest(Method.get, _queryGetMembersList);
    if (tokenAPIRequest.getResponse().isNotEmpty) {
      try {
        Map<String, dynamic> message = tokenAPIRequest.getResponse();
        requestResponse = message['success'] as bool;
        if (requestResponse) {
          List<dynamic> result = message['result'] as List<dynamic>;
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
    _queryGetDevicesList = '/v1.0/homes/$homeId/devices';
    await tokenAPIRequest.sendRequest(Method.get, _queryGetDevicesList);
    if (tokenAPIRequest.getResponse().isNotEmpty) {
      try {
        Map<String, dynamic> message = tokenAPIRequest.getResponse();
        requestResponse = message['success'] as bool;
        if (requestResponse) {
          List<dynamic> result = message['result'] as List<dynamic>;
          for (int i = 0; i < result.length; i++) {
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
              ownerId: result[i]['owner_id'],
              productId: result[i]['product_id'],
              productName: result[i]['product_name'],
              sub: result[i]['sub'] as bool,
              timeZone: result[i]['time_zone'],
              uid: result[i]['uid'],
              updateTime: int.parse(result[i]['update_time'].toString()),
              uuid: result[i]['uuid'],
            ));
          }
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
