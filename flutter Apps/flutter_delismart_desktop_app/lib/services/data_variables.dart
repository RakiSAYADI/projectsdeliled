import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_app.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_token.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';
import 'package:flutter_delismart_desktop_app/services/request_api.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

const String appName = 'DeliSmartConfig';

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

List<String> accessTypeUserList = [ordinaryMemberUserChoiceMessageTextLanguageArray[languageArrayIdentifier], administratorUserChoiceMessageTextLanguageArray[languageArrayIdentifier]];

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

void renameRoomRequestWidget(String roomName) {
  double screenWidth = MediaQuery.of(Get.context!).size.width;
  double screenHeight = MediaQuery.of(Get.context!).size.height;
  final myRoomName = TextEditingController(text: roomName);
  Get.defaultDialog(
    title: attentionMessageTextLanguageArray[languageArrayIdentifier],
    content: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          changeRoomNameMessageTextLanguageArray[languageArrayIdentifier],
          style: TextStyle(fontSize: screenHeight * 0.007 + screenWidth * 0.007, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: (screenHeight * 0.05)),
          child: TextField(
            textAlign: TextAlign.center,
            controller: myRoomName,
            maxLines: 1,
            style: TextStyle(
              fontSize: (screenWidth * 0.05),
            ),
            decoration: InputDecoration(
                hintText: 'exp: Cuisine',
                hintStyle: TextStyle(
                  fontSize: (screenWidth * 0.025 + screenHeight * 0.025),
                  color: Colors.grey,
                )),
          ),
        ),
      ],
    ),
    textConfirm: confirmButtonTextLanguageArray[languageArrayIdentifier],
    textCancel: cancelButtonTextLanguageArray[languageArrayIdentifier],
    onConfirm: () async {
      if (myRoomName.text.isNotEmpty) {
        await appClass.users[userIdentifier].universes[universeIdentifier].rooms[roomIdentifier].changeRoomName(myRoomName.text);
        if (!requestResponse) {
          showToastMessage('Error request');
        } else {
          showToastMessage('request is valid');
        }
      } else {
        showToastMessage('empty field text');
      }
      Get.back();
    },
  );
}

void addRoomRequestWidget() {
  double screenWidth = MediaQuery.of(Get.context!).size.width;
  double screenHeight = MediaQuery.of(Get.context!).size.height;
  final myRoomName = TextEditingController();
  Get.defaultDialog(
    title: attentionMessageTextLanguageArray[languageArrayIdentifier],
    content: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          changeRoomNameMessageTextLanguageArray[languageArrayIdentifier],
          style: TextStyle(fontSize: screenHeight * 0.007 + screenWidth * 0.007, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: (screenHeight * 0.05)),
          child: TextField(
            textAlign: TextAlign.center,
            controller: myRoomName,
            maxLines: 1,
            style: TextStyle(
              fontSize: (screenWidth * 0.05),
            ),
            decoration: InputDecoration(
                hintText: 'exp: Cuisine',
                hintStyle: TextStyle(
                  fontSize: (screenWidth * 0.025 + screenHeight * 0.025),
                  color: Colors.grey,
                )),
          ),
        ),
      ],
    ),
    textConfirm: confirmButtonTextLanguageArray[languageArrayIdentifier],
    textCancel: cancelButtonTextLanguageArray[languageArrayIdentifier],
    onConfirm: () async {
      if (myRoomName.text.isNotEmpty) {
        await appClass.users[userIdentifier].universes[universeIdentifier].addRoomUniverse(myRoomName.text);
        if (!requestResponse) {
          showToastMessage('Error request');
        } else {
          showToastMessage('request is valid');
        }
      } else {
        showToastMessage('empty field text');
      }
      Get.back();
    },
  );
}

void deleteRoomRequestWidget(String roomID) {
  double screenWidth = MediaQuery.of(Get.context!).size.width;
  double screenHeight = MediaQuery.of(Get.context!).size.height;
  Get.defaultDialog(
    title: attentionMessageTextLanguageArray[languageArrayIdentifier],
    content: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          roomDeleteTextLanguageArray[languageArrayIdentifier],
          style: TextStyle(fontSize: screenHeight * 0.007 + screenWidth * 0.007, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      ],
    ),
    textConfirm: confirmButtonTextLanguageArray[languageArrayIdentifier],
    textCancel: cancelButtonTextLanguageArray[languageArrayIdentifier],
    onConfirm: () async {
      await appClass.users[userIdentifier].universes[universeIdentifier].rooms[roomIdentifier].deleteRoom(roomID);
      if (!requestResponse) {
        showToastMessage('Error request');
      } else {
        showToastMessage('request is valid');
      }
      Get.back();
    },
  );
}

void deleteUniverseRequestWidget(String universeID) {
  double screenWidth = MediaQuery.of(Get.context!).size.width;
  double screenHeight = MediaQuery.of(Get.context!).size.height;
  Get.defaultDialog(
    title: attentionMessageTextLanguageArray[languageArrayIdentifier],
    content: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          universeDeleteTextLanguageArray[languageArrayIdentifier],
          style: TextStyle(fontSize: screenHeight * 0.007 + screenWidth * 0.007, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      ],
    ),
    textConfirm: confirmButtonTextLanguageArray[languageArrayIdentifier],
    textCancel: cancelButtonTextLanguageArray[languageArrayIdentifier],
    onConfirm: () async {
      await appClass.users[userIdentifier].deleteUniverse(universeID);
      if (!requestResponse) {
        showToastMessage('Error request');
      } else {
        showToastMessage('request is valid');
      }
      Get.back();
    },
  );
}

void deleteDeviceRoomRequestWidget(String deviceID) {
  double screenWidth = MediaQuery.of(Get.context!).size.width;
  double screenHeight = MediaQuery.of(Get.context!).size.height;
  Get.defaultDialog(
    title: attentionMessageTextLanguageArray[languageArrayIdentifier],
    content: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          roomDeviceDeleteTextLanguageArray[languageArrayIdentifier],
          style: TextStyle(fontSize: screenHeight * 0.007 + screenWidth * 0.007, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      ],
    ),
    textConfirm: confirmButtonTextLanguageArray[languageArrayIdentifier],
    textCancel: cancelButtonTextLanguageArray[languageArrayIdentifier],
    onConfirm: () async {
      await appClass.users[userIdentifier].universes[universeIdentifier].rooms[roomIdentifier].deleteDevice(deviceID);
      if (!requestResponse) {
        showToastMessage('Error request');
      } else {
        showToastMessage('request is valid');
      }
      Get.back();
    },
  );
}

void moveDeviceRoomRequestWidget(String deviceId) {
  double screenWidth = MediaQuery.of(Get.context!).size.width;
  double screenHeight = MediaQuery.of(Get.context!).size.height;
  List<String> roomList = [];
  int roomPosition = 0;
  for (var room in appClass.users[userIdentifier].universes[universeIdentifier].rooms) {
    roomList.add(room.name);
  }
  String roomNameData = roomList.elementAt(roomIdentifier);
  Get.defaultDialog(
    title: attentionMessageTextLanguageArray[languageArrayIdentifier],
    content: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          stateUserChoiceMessageTextLanguageArray[languageArrayIdentifier],
          style: TextStyle(fontSize: screenHeight * 0.007 + screenWidth * 0.007, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
          child: StatefulBuilder(builder: (BuildContext context, StateSetter dropDownState) {
            return DropdownButton<String>(
              value: roomNameData,
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.grey[800], fontSize: 18),
              underline: Container(
                height: 2,
                color: Colors.blue[300],
              ),
              onChanged: (String? data) {
                dropDownState(() {
                  roomNameData = data!;
                });
                roomPosition = roomList.indexOf(roomNameData);
              },
              items: roomList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            );
          }),
        ),
      ],
    ),
    textConfirm: confirmButtonTextLanguageArray[languageArrayIdentifier],
    textCancel: cancelButtonTextLanguageArray[languageArrayIdentifier],
    onConfirm: () async {
      await appClass.users[userIdentifier].universes[universeIdentifier].rooms[roomPosition].moveDevice(deviceId);
      if (!requestResponse) {
        showToastMessage('Error request');
      } else {
        showToastMessage('request is valid');
      }
      Get.back();
    },
  );
}

void modifyUserUniverseRequestWidget(bool state, String userID) {
  double screenWidth = MediaQuery.of(Get.context!).size.width;
  double screenHeight = MediaQuery.of(Get.context!).size.height;
  String accessTypeUserData = state ? administratorUserChoiceMessageTextLanguageArray[languageArrayIdentifier] : ordinaryMemberUserChoiceMessageTextLanguageArray[languageArrayIdentifier];
  Get.defaultDialog(
    title: attentionMessageTextLanguageArray[languageArrayIdentifier],
    content: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          stateUserChoiceMessageTextLanguageArray[languageArrayIdentifier],
          style: TextStyle(fontSize: screenHeight * 0.007 + screenWidth * 0.007, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
          child: StatefulBuilder(builder: (BuildContext context, StateSetter dropDownState) {
            return DropdownButton<String>(
              value: accessTypeUserData,
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.grey[800], fontSize: 18),
              underline: Container(
                height: 2,
                color: Colors.blue[300],
              ),
              onChanged: (String? data) {
                dropDownState(() {
                  accessTypeUserData = data!;
                });
              },
              items: accessTypeUserList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            );
          }),
        ),
      ],
    ),
    textConfirm: confirmButtonTextLanguageArray[languageArrayIdentifier],
    textCancel: cancelButtonTextLanguageArray[languageArrayIdentifier],
    onConfirm: () async {
      await appClass.users[userIdentifier].universes[universeIdentifier].changeStateUserUniverse(accessTypeUserList.indexOf(accessTypeUserData) == 0 ? false : true, userID);
      if (!requestResponse) {
        showToastMessage('Error request');
      } else {
        showToastMessage('request is valid');
      }
      Get.back();
    },
  );
}

void deleteUniverseWarningWidget(String universeID) {
  double screenWidth = MediaQuery.of(Get.context!).size.width;
  double screenHeight = MediaQuery.of(Get.context!).size.height;
  final myPassword = TextEditingController();
  Get.defaultDialog(
    title: attentionMessageTextLanguageArray[languageArrayIdentifier],
    content: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          deleteUniverseSecurityMessageTextLanguageArray[languageArrayIdentifier],
          style: TextStyle(fontSize: screenHeight * 0.007 + screenWidth * 0.007, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: (screenHeight * 0.05)),
          child: TextField(
            textAlign: TextAlign.center,
            controller: myPassword,
            maxLines: 1,
            style: TextStyle(
              fontSize: (screenWidth * 0.05),
            ),
            decoration: InputDecoration(
                hintText: '****',
                hintStyle: TextStyle(
                  fontSize: (screenWidth * 0.025 + screenHeight * 0.025),
                  color: Colors.grey,
                )),
          ),
        ),
      ],
    ),
    textConfirm: confirmButtonTextLanguageArray[languageArrayIdentifier],
    textCancel: cancelButtonTextLanguageArray[languageArrayIdentifier],
    onConfirm: () {
      Get.back();
      if (myPassword.text == '1234') {
        deleteUniverseRequestWidget(universeID);
      } else {
        showToastMessage('wrong code');
      }
    },
  );
}

void deleteUniverseUserRequestWidget(String userId) {
  double screenWidth = MediaQuery.of(Get.context!).size.width;
  double screenHeight = MediaQuery.of(Get.context!).size.height;
  Get.defaultDialog(
    title: attentionMessageTextLanguageArray[languageArrayIdentifier],
    content: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          universeUserDeleteTextLanguageArray[languageArrayIdentifier],
          style: TextStyle(fontSize: screenHeight * 0.007 + screenWidth * 0.007, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      ],
    ),
    textConfirm: confirmButtonTextLanguageArray[languageArrayIdentifier],
    textCancel: cancelButtonTextLanguageArray[languageArrayIdentifier],
    onConfirm: () async {
      await appClass.users[userIdentifier].universes[universeIdentifier].deleteUserUniverse(userId);
      if (!requestResponse) {
        showToastMessage('Error request');
      } else {
        showToastMessage('request is valid');
      }
      Get.back();
    },
  );
}

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
