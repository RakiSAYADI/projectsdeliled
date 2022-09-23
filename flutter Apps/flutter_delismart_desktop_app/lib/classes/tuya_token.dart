import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';

class TokenClass {
  final String queryGetToken = '/v1.0/token?grant_type=1';
  final String queryRefreshToken = '/v1.0/token/$easyRefreshToken';
  int _timeExpired = 0;

  void init({bool first = true}) async {
    await tokenAPIRequest.sendRequest(getMethod, queryGetToken);
    if (tokenAPIRequest.getResponse().isNotEmpty) {
      try {
        Map<String, dynamic> message = jsonDecode(tokenAPIRequest.getResponse());
        requestResponse = message['success'] as bool;
        if (requestResponse) {
          Map<String, dynamic> result = message['result'] as Map<String, dynamic>;
          _timeExpired = result['expire_time'] as int;
          easyRefreshToken = result['refresh_token'];
          easyAccessToken = result['access_token'];
          debugPrint(easyRefreshToken);
          debugPrint(easyAccessToken);
          if (first) {
            _verifyExpireTime();
          }
        } else {
          requestResponse = false;
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  void _refreshToken() async {
    await tokenAPIRequest.sendRequest(getMethod, queryRefreshToken);
    if (tokenAPIRequest.getResponse().isNotEmpty) {
      try {
        Map<String, dynamic> message = jsonDecode(tokenAPIRequest.getResponse());
        requestResponse = message['success'] as bool;
        if (requestResponse) {
          Map<String, dynamic> result = message['result'] as Map<String, dynamic>;
          _timeExpired = result['expire_time'] as int;
          easyRefreshToken = result['refresh_token'];
          easyAccessToken = result['access_token'];
        } else {
          requestResponse = false;
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  void _verifyExpireTime() async {
    while (true) {
      if (_timeExpired <= 10) {
        init(first: false);
      } else {
        _timeExpired--;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}
