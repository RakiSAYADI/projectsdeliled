import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_app.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_token.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';
import 'package:flutter_delismart_desktop_app/services/request_api.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

const String appName = 'DeliSmart';

String languageCode = 'fr';
int languageArrayIdentifier = 0;

enum Method { post, get, put, delete }

const String url = 'https://openapi.tuyaeu.com';
const String clientId = 'qdkwarm5edyqy7cpvx9d';
const String secret = 'dffb252cae434376a7ed10084d021130';
const String signMethod = 'HMAC-SHA256';
const String nonce = '';
const String schema = 'applicationsdelismartoemapp';

const emptyBodyEncrypted = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';

bool requestResponse = false;

String easySign = '';
String easyAccessToken = '';
String easyRefreshToken = '';

final TokenClass tokenClass = TokenClass();
final AppClass appClass = AppClass();

final APIRequest tokenAPIRequest = APIRequest();

int userIdentifier = 0;
int universeIdentifier = 0;
int roomIdentifier = 0;
int deviceIdentifier = 0;

void waitingRequestWidget() {
  //double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(Get.context!).size.height;
  Get.defaultDialog(
    title: requestMessageTextLanguageArray[languageArrayIdentifier],
    content: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SpinKitCircle(
          color: Colors.blue[600],
          size: screenHeight * 0.1,
        ),
      ],
    ),
  );
}

void exitRequestWidget() => Get.back();

void showToastMessage(String text) {
  showToastWidget(
    Container(
      decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(80.0), color: Colors.black),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: const TextStyle(decoration: TextDecoration.none, color: Colors.white, fontSize: 20, fontWeight: FontWeight.normal),
        ),
      ),
    ),
    duration: const Duration(seconds: 2),
    position: ToastPosition.bottom,
  );
}
