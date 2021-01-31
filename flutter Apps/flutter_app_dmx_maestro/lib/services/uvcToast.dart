import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastyMessage {
  AnimationController animationRefreshIcon;
  FlutterToast flutterToast;
  BuildContext toastContext;
  String toastMessage;
  int toastDuration;

  ToastyMessage({this.toastContext});

  void setToastMessage(String message) {
    this.toastMessage = message;
  }

  void setToastDuration(int duration) {
    this.toastDuration = duration;
  }

  void setAnimationIcon(AnimationController animationController) {
    this.animationRefreshIcon = animationController;
  }

  void showToast(Color toastColor, IconData messageIcon, Color toastMessageColor) {
    this.flutterToast = FlutterToast(this.toastContext);
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
            Container(
                child: new AnimatedBuilder(
              animation: animationRefreshIcon,
              child: Icon(messageIcon, color: Colors.white),
              builder: (BuildContext context, Widget _widget) {
                return new Transform.rotate(
                  angle: animationRefreshIcon.value * 6.3,
                  child: _widget,
                );
              },
            )),
            SizedBox(
              width: 12.0,
            ),
            Flexible(
              child: Text(
                this.toastMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
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
              width: 12.0,
            ),
            Flexible(
              child: Text(
                this.toastMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: toastMessageColor,
                ),
              ),
            ),
          ],
        ),
      );
    }
    this.flutterToast.showToast(
          child: toast,
          gravity: ToastGravity.BOTTOM,
          toastDuration: Duration(seconds: this.toastDuration),
        );
  }

  void clearAllToast() {
    this.flutterToast.removeQueuedCustomToasts();
    this.animationRefreshIcon.stop();
  }

  void clearCurrentToast() {
    this.animationRefreshIcon.stop();
    this.flutterToast.removeCustomToast();
  }
}
