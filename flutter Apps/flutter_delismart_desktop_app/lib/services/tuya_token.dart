import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/request_api.dart';

class TokenRequest {
  final String queryGetToken = '/v1.0/token?grant_type=1';
  final APIRequest tokenAPIRequest = APIRequest();
  DateTime _dateTime = DateTime.now();

  void refreshToken() {}

  void getToken() async {
    await tokenAPIRequest.sendRequest(getMethod, queryGetToken);
    if (tokenAPIRequest.getResponse().isNotEmpty) {
      try {
        Map<String, dynamic> message = jsonDecode(tokenAPIRequest.getResponse());
        Map<String, dynamic> result = message['result'] as Map<String, dynamic>;
        bool success = result['success'] as bool;
        easyAccessToken = result['access_token'];
        easyRefreshToken = result['refresh_token'];

      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  bool verifyExpireTime(){
    DateTime dateTimeNow = DateTime.now();

  }
}
