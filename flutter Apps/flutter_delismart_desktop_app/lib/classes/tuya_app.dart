import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_user.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';

class AppClass {
  String name = '';
  int bizType = 0;
  int id = 0;
  int createTime = 0;
  List<UserClass> users = [];

  final String queryGetAppInfo = '/v1.1/apps/$schema';

  void getInfo() async {
    await tokenAPIRequest.sendRequest(getMethod, queryGetAppInfo);
    if (tokenAPIRequest.getResponse().isNotEmpty) {
      try {
        Map<String, dynamic> message = jsonDecode(tokenAPIRequest.getResponse());
        requestResponse = message['success'] as bool;
        if (requestResponse) {
          Map<String, dynamic> result = message['result'] as Map<String, dynamic>;
          bizType = result['app_biz_type'] as int;
          name = result['app_name'] as String;
          id = result['app_id'] as int;
          createTime = result['create_time'] as int;
        } else {
          requestResponse = false;
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }
}
