import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';

class APIRequest {
  String _signStr = '';
  Map<String, dynamic> _response = {};

  Dio? _dio;

  Map<String, dynamic> getResponse() => _response;

  Future<void> sendRequest(Method method, String query, {String body = ''}) async {
    DateTime dateTime = DateTime.now();
    String timestamp = (dateTime.millisecondsSinceEpoch).toString();
    Map<String, String> headers;
    if (query.contains('/v1.0/token')) {
      headers = {
        'client_id': clientId,
        'sign': '',
        't': timestamp,
        'sign_method': signMethod,
        'nonce': nonce,
        'stringToSign': '',
      };
    } else {
      headers = {
        'client_id': clientId,
        'access_token': easyAccessToken,
        'sign': '',
        't': timestamp,
        'sign_method': signMethod,
      };
    }
    if (body.isNotEmpty) {
      headers.addAll({'Content-Type': 'application/json'});
    }
    _signStr = _stringToSign(method, body, headers, query);
    String str;
    if (query.contains('/v1.0/token')) {
      str = clientId + timestamp + nonce + _signStr;
    } else {
      str = clientId + easyAccessToken + timestamp + nonce + _signStr;
    }
    var hMacSha256 = Hmac(sha256, utf8.encode(secret));
    var digest = hMacSha256.convert(utf8.encode(str));
    headers['sign'] = digest.toString().toUpperCase();
    _dio = Dio(BaseOptions(baseUrl: url, headers: headers));
    try {
      Response response;
      switch (method) {
        case Method.get:
          response = await _dio!.get(query);
          break;
        case Method.post:
          response = await _dio!.post(query, data: body);
          break;
        case Method.put:
          response = await _dio!.put(query, data: body);
          break;
        case Method.delete:
          response = await _dio!.delete(query);
          break;
      }
      _response = response.data as Map<String, dynamic>;
      debugPrint(response.data.toString());
      _dio!.close();
    } catch (e) {
      _response = {};
      debugPrint('API request ' + e.toString());
    }
  }

  String _stringToSign(Method method, String body, Map headers, String query) {
    String bodyCrypt = '';
    if (body.isNotEmpty) {
      var digest = sha256.convert(utf8.encode(body));
      bodyCrypt = digest.toString();
    } else {
      bodyCrypt = emptyBodyEncrypted;
    }
    String headersStr = '';
    if (headers.containsKey('Signature-Headers')) {
      String signHeaders = headers['Signature-Headers'];
      final signHeadersKeys = signHeaders.split(':');
      for (var item in signHeadersKeys) {
        var value = '';
        if (headers.containsKey(item)) {
          value = headers[item];
        }
        headersStr += item + ':' + value + '\n';
      }
    }
    String methodString = '';
    switch (method) {
      case Method.get:
        methodString = 'GET';
        break;
      case Method.post:
        methodString = 'POST';
        break;
      case Method.put:
        methodString = 'PUT';
        break;
      case Method.delete:
        methodString = 'DELETE';
        break;
    }
    return methodString + '\n' + bodyCrypt + '\n' + headersStr + '\n' + query;
  }
}
