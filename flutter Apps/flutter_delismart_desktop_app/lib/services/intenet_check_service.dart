import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CheckInternet {
  bool _serviceState = false;

  void startChecking() async {
    _serviceState = true;
    while (_serviceState) {
      await Future.delayed(const Duration(seconds: 5));
      try {
        final result = await InternetAddress.lookup('google.com');
        result.isNotEmpty && result[0].rawAddress.isNotEmpty;
        debugPrint('connection is good');
      } on SocketException catch (_) {
        _serviceState = false;
        Get.defaultDialog(
          title: 'Attention',
          barrierDismissible: false,
          content: const Text('Connexion internet perdue', style: TextStyle(fontSize: 14)),
          actions: [
            TextButton(
              child: const Text('Reconnecter', style: TextStyle(fontSize: 14)),
              onPressed: () {
                Get.back();
                startChecking();
              },
            ),
          ],
        );
      }
    }
  }

  void stopChecking() {
    _serviceState = false;
  }
}
