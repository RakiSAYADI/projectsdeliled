import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_deliscan/services/DataVariables.dart';
import 'package:flutter_app_deliscan/services/languageDataBase.dart';
import 'package:get/get.dart';

class MyConnectivity {
  MyConnectivity._();

  static final _instance = MyConnectivity._();

  static MyConnectivity get instance => _instance;
  final _connectivity = Connectivity();
  final _controller = StreamController.broadcast();

  Stream get myStream => _controller.stream;

  void initialise() async {
    ConnectivityResult result = await _connectivity.checkConnectivity();
    _checkStatus(result);
    _connectivity.onConnectivityChanged.listen((result) {
      _checkStatus(result);
    });
    _verifyConnection();
  }

  void _verifyConnection() async {
    this.myStream.listen((source) {
      connectionSource = source;
      switch (source.keys.toList()[0]) {
        case ConnectivityResult.mobile:
        case ConnectivityResult.wifi:
          print("we have connection");
          break;
        case ConnectivityResult.none:
        default:
          Get.defaultDialog(
            title: attentionTextLanguageArray[languageArrayIdentifier],
            barrierDismissible: false,
            content: Text(checkConnectionMessageTextLanguageArray[languageArrayIdentifier], textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
            actions: [
              TextButton(
                child: Text(understoodTextLanguageArray[languageArrayIdentifier], style: TextStyle(fontSize: 14)),
                onPressed: () {
                  Get.clearRouteTree();
                  this.disposeStream();
                  Get.toNamed('/');
                },
              ),
            ],
          );
          break;
      }
    });
  }

  void _checkStatus(ConnectivityResult result) async {
    bool isOnline = false;
    try {
      final result = await InternetAddress.lookup('google.com');
      isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      isOnline = false;
    }
    _controller.sink.add({result: isOnline});
  }

  void disposeStream() => _controller.close();
}
