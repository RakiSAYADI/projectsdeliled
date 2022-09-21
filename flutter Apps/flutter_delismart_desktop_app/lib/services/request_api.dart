import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:http/http.dart' as http;

class APIRequest {
  String _signStr = '';
  String _response = '';

  String getResponse() => _response;

  Future<void> sendRequest(String method, String query, {String body = ''}) async {
    DateTime dateTime = DateTime.now();
    String timestamp = (dateTime.millisecondsSinceEpoch).toString();
    var headers = {
      'client_id': clientId,
      'sign': '',
      't': timestamp,
      'sign_method': signMethod,
      'nonce': nonce,
      'stringToSign': '',
    };
    var request = http.Request(method.toUpperCase(), Uri.parse(url + query));
    var hMacSha256 = Hmac(sha256, utf8.encode(secret));
    _signStr = _stringToSign(hMacSha256, method, body, headers, query);
    String str = clientId + timestamp + nonce + _signStr;
    var digest = hMacSha256.convert(utf8.encode(str));
    if (body.isNotEmpty) {
      request.body = body;
    }
    headers['sign'] = digest.toString().toUpperCase();
    request.headers.addAll(headers);
    try {
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        _response = await response.stream.bytesToString();
        debugPrint(_response);
      } else {
        _response = response.reasonPhrase!;
        debugPrint(_response);
      }
    } catch (e) {
      _response = '';
      debugPrint('API request ' + e.toString());
    }
  }

  String _stringToSign(Hmac hMac, String method, String body, Map headers, String query) {
    String bodyCrypt = '';
    if (body.isNotEmpty) {
      var digest = hMac.convert(utf8.encode(body));
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
    return method + '\n' + bodyCrypt + '\n' + headersStr + '\n' + query;
  }
}
