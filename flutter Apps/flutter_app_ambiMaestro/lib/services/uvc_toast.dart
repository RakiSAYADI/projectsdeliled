import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastyMessage {
  AnimationController? animationRefreshIcon;
  FToast? flutterToast;
  BuildContext? toastContext;
  String? toastMessage;
  int? toastDuration;

  ToastyMessage({this.toastContext});

  void setToastMessage(String message) {
    toastMessage = message;
  }

  void setToastDuration(int duration) {
    toastDuration = duration;
  }

  void setAnimationIcon(AnimationController animationController) {
    animationRefreshIcon = animationController;
  }

  void showToast(Color toastColor, IconData messageIcon, Color toastMessageColor) {
    flutterToast = FToast(/*this.toastContext*/);
    flutterToast!.init(toastContext!);
    Widget toast;

    if (animationRefreshIcon != null) {
      toast = Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: toastColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: animationRefreshIcon!,
              child: Icon(
                messageIcon,
                color: Colors.white,
                size: MediaQuery.of(toastContext!).size.width * 0.04,
              ),
              builder: (BuildContext context, Widget? _widget) {
                return Transform.rotate(
                  angle: animationRefreshIcon!.value * 6.3,
                  child: _widget,
                );
              },
            ),
            SizedBox(
              width: MediaQuery.of(toastContext!).size.width * 0.01,
            ),
            Flexible(
              child: Text(
                toastMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: MediaQuery.of(toastContext!).size.width * 0.017,
                  color: toastMessageColor,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      toast = Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: toastColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(messageIcon, color: Colors.white),
            SizedBox(
              width: MediaQuery.of(toastContext!).size.width * 0.01,
            ),
            Flexible(
              child: Text(
                toastMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: MediaQuery.of(toastContext!).size.width * 0.017,
                  color: toastMessageColor,
                ),
              ),
            ),
          ],
        ),
      );
    }
    flutterToast!.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: toastDuration!),
    );
  }

  void clearAllToast() {
    flutterToast!.removeQueuedCustomToasts();
    if (animationRefreshIcon != null) {
      animationRefreshIcon!.stop();
    }
  }

  void clearCurrentToast() {
    if (animationRefreshIcon != null) {
      animationRefreshIcon!.stop();
    }
    flutterToast!.removeCustomToast();
  }
}
