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
  final String queryGetUserList = '/v1.0/apps/$schema/users?page_no=1&page_size=100';

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
          for (int i = 0; i < list.length; i++) {
            if (list[i].containsKey('email')) {
              email = list[i]['email'];
            }
            _usersEmail.add(email);
            users.add(UserClass(userName: list[i]['username'], email: email, createTime: list[i]['create_time'], uid: list[i]['uid'], updateTime: list[i]['update_time']));
          }
        }
      } catch (e) {
        requestResponse = false;
        debugPrint(e.toString());
      }
    }
  }
}
