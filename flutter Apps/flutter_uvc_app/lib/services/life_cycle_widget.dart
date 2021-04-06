import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback resumeCallBack;
  final AsyncCallback inactiveCallBack;
  final AsyncCallback pauseCallBack;
  final AsyncCallback suspendingCallBack;

  LifecycleEventHandler({this.resumeCallBack, this.suspendingCallBack, this.pauseCallBack, this.inactiveCallBack});

  Future<void> removeLifeCycleState() async {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (resumeCallBack != null) {
          await resumeCallBack();
        }
        break;
      case AppLifecycleState.inactive:
        if (inactiveCallBack != null) {
          await inactiveCallBack();
        }
        break;
      case AppLifecycleState.paused:
        if (pauseCallBack != null) {
          await pauseCallBack();
        }
        break;
      case AppLifecycleState.detached:
        if (suspendingCallBack != null) {
          await suspendingCallBack();
        }
        break;
    }
  }
}
