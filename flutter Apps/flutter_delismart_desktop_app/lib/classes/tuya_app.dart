import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_user.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';

class AppClass {
  String name = '';
  int bizType = 0;
  int id = 0;
  int createTime = 0;
  List<UserClass> users = [];

  List<String> _usersEmail = [];

  final String queryGetAppInfo = '/v1.1/apps/$schema';
  final String queryPostCreateUser = '/v1.0/apps/$schema/user';
  final String queryGetUserList = '/v1.0/apps/$schema/users?page_no=1&page_size=$maxUsers';

  Future removeDevice(String deviceId) async {
    waitingRequestWidget();
    final String queryPostDeleteUser = '/v1.0/devices/$deviceId';
    await tokenAPIRequest.sendRequest(Method.delete, queryPostDeleteUser);
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

  Future renameDevice(String deviceName, String deviceID) async {
    waitingRequestWidget();
    final String _queryChangeDeviceName = '/v1.0/devices/$deviceID';
    await tokenAPIRequest.sendRequest(Method.put, _queryChangeDeviceName,
        body: "{\n"
            "\"name\": \"$deviceName\""
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

  Future getCityInfo({String lon = '0.0', String lat = '0.0'}) async {
    waitingRequestWidget();
    const String queryGetCityInfo = '/v1.0/iot-03/cities/positions?lat=43.866636&lon=5.908065';
    await tokenAPIRequest.sendRequest(Method.get, queryGetCityInfo);
    if (tokenAPIRequest.getResponse().isNotEmpty) {
      try {
        Map<String, dynamic> message = tokenAPIRequest.getResponse();
        requestResponse = message['success'] as bool;
        if (requestResponse) {
          cityInfo = message['result'] as Map<String, dynamic>;
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

  void getInfo() async {
    await tokenAPIRequest.sendRequest(Method.get, queryGetAppInfo);
    if (tokenAPIRequest.getResponse().isNotEmpty) {
      try {
        Map<String, dynamic> message = tokenAPIRequest.getResponse();
        requestResponse = message['success'] as bool;
        if (requestResponse) {
          Map<String, dynamic> result = message['result'] as Map<String, dynamic>;
          bizType = result['app_biz_type'] as int;
          name = result['app_name'] as String;
          id = result['app_id'] as int;
          createTime = result['create_time'] as int;
        } else {
          apiMessage = message['msg'] as String;
        }
      } catch (e) {
        requestResponse = false;
        debugPrint(e.toString());
      }
    }
  }

  List<String> getUsersEmail() => _usersEmail;

  Future getUserList() async {
    await tokenAPIRequest.sendRequest(Method.get, queryGetUserList);
    if (tokenAPIRequest.getResponse().isNotEmpty) {
      try {
        Map<String, dynamic> message = tokenAPIRequest.getResponse();
        requestResponse = message['success'] as bool;
        if (requestResponse) {
          Map<String, dynamic> result = message['result'] as Map<String, dynamic>;
          List<dynamic> list = result['list'] as List<dynamic>;
          bool hasMore = result['has_more'] as bool; // will check it out with Windy
          int total = result['total'] as int;
          String email = '';
          users.clear();
          for (int i = 0; i < list.length; i++) {
            if (list[i].containsKey('email')) {
              email = list[i]['email'];
            }
            _usersEmail.add(email.toLowerCase());
            users.add(UserClass(userName: list[i]['username'], email: email, createTime: list[i]['create_time'], uid: list[i]['uid'], updateTime: list[i]['update_time']));
          }
        } else {
          apiMessage = message['msg'] as String;
        }
      } catch (e) {
        requestResponse = false;
        debugPrint(e.toString());
      }
    }
  }

  Future postCreateUser(String email, String password, String name) async {
    waitingRequestWidget();
    await tokenAPIRequest.sendRequest(Method.post, queryPostCreateUser,
        body: "{\n"
            "\"country_code\": \"33\", \n"
            "\"username\": \"$email\", \n"
            "\"password\": \"$password\", \n"
            "\"nick_name\": \"$name\", \n"
            "\"username_type\": \"2\"\n"
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

  Future postDeleteUser(String uid) async {
    waitingRequestWidget();
    final String queryPostDeleteUser = '/v1.0/users/$uid/actions/pre-delete';
    await tokenAPIRequest.sendRequest(Method.post, queryPostDeleteUser);
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
}
