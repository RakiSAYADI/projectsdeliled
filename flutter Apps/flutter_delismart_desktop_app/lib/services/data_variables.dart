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

const String deletePassword = '1234';

String easySign = '';
String easyAccessToken = '';
String easyRefreshToken = '';

final TokenClass tokenClass = TokenClass();
final AppClass appClass = AppClass();

final APIRequest tokenAPIRequest = APIRequest();

int userIdentifier = 0;
int universeIdentifier = 0;
int roomIdentifier = 0;
int sceneIdentifier = 0;
int automationIdentifier = 0;
int deviceIdentifier = 0;

int matchType = 1;
String conditionRule = '';

List<Map<String, dynamic>> sceneActions = [];
List<Map<String, dynamic>> automationActions = [];
List<Map<String, dynamic>> automationConditions = [];
Map<String, dynamic> automationPreconditions = {};

Map<String, dynamic> cityInfo = {};

enum ElementType { universe, device }

List<String> accessTypeUserList = [ordinaryMemberUserChoiceMessageTextLanguageArray[languageArrayIdentifier], administratorUserChoiceMessageTextLanguageArray[languageArrayIdentifier]];

List<String> conditions = [andTextLanguageArray[languageArrayIdentifier], orTextLanguageArray[languageArrayIdentifier]];

List<String> workModeList = ['white', 'colour', 'scene', 'music', 'scene_1', 'scene_2', 'scene_3', 'scene_4'];

List<String> switchValueList = ['single_click', 'double_click', 'long_press'];

List<String> switchModeList = ['click', 'double_click', 'press'];

List<String> relayStateList = ['power_on', 'power_off', 'last'];

List<String> relayStateTDQList = ['0', '1', '2'];

List<String> doorBellVolumeList = ['low', 'middle', 'high', 'mute'];

List<String> doorBellRingtoneList = ['1', '2', '3', '4', '5'];

List<String> lightModeList = ['none', 'relay', 'pos'];

List<String> sceneHour = ['00', '01', '02', '03', '04', '05'];

List<String> automationYear = ['2022', '2023', '2024', '2025', '2026', '2027', '2028', '2029', '2030'];

List<String> automationMonth = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'];

List<String> automationDay = [
  '01',
  '02',
  '03',
  '04',
  '05',
  '06',
  '07',
  '08',
  '09',
  '10',
  '11',
  '12',
  '13',
  '14',
  '15',
  '16',
  '17',
  '18',
  '19',
  '20',
  '21',
  '22',
  '23',
  '24',
  '25',
  '26',
  '27',
  '28',
  '29',
  '30',
  '31'
];

List<String> hour = [
  '00',
  '01',
  '02',
  '03',
  '04',
  '05',
  '06',
  '07',
  '08',
  '09',
  '10',
  '11',
  '12',
  '13',
  '14',
  '15',
  '16',
  '17',
  '18',
  '19',
  '20',
  '21',
  '22',
  '23',
  '24',
];

List<String> minute = [
  '00',
  '01',
  '02',
  '03',
  '04',
  '05',
  '06',
  '07',
  '08',
  '09',
  '10',
  '11',
  '12',
  '13',
  '14',
  '15',
  '16',
  '17',
  '18',
  '19',
  '20',
  '21',
  '22',
  '23',
  '24',
  '25',
  '26',
  '27',
  '28',
  '29',
  '30',
  '31',
  '32',
  '33',
  '34',
  '35',
  '36',
  '37',
  '38',
  '39',
  '40',
  '41',
  '42',
  '43',
  '44',
  '45',
  '46',
  '47',
  '48',
  '49',
  '50',
  '51',
  '52',
  '53',
  '54',
  '55',
  '56',
  '57',
  '58',
  '59'
];

List<String> second = [
  '00',
  '01',
  '02',
  '03',
  '04',
  '05',
  '06',
  '07',
  '08',
  '09',
  '10',
  '11',
  '12',
  '13',
  '14',
  '15',
  '16',
  '17',
  '18',
  '19',
  '20',
  '21',
  '22',
  '23',
  '24',
  '25',
  '26',
  '27',
  '28',
  '29',
  '30',
  '31',
  '32',
  '33',
  '34',
  '35',
  '36',
  '37',
  '38',
  '39',
  '40',
  '41',
  '42',
  '43',
  '44',
  '45',
  '46',
  '47',
  '48',
  '49',
  '50',
  '51',
  '52',
  '53',
  '54',
  '55',
  '56',
  '57',
  '58',
  '59'
];

bool intToBool(int i) => i == 1 ? true : false;

int boolToInt(bool b) => b == true ? 1 : 0;

bool charToBool(String c) => c == '0' ? false : true;

String boolToChar(bool b) => b == false ? '0' : '1';

String changeCharState(String c) => c == '0' ? '1' : '0';

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

void renameDeviceRequestWidget(String deviceName, String deviceID) {
  double screenWidth = MediaQuery.of(Get.context!).size.width;
  double screenHeight = MediaQuery.of(Get.context!).size.height;
  final myDeviceName = TextEditingController(text: deviceName);
  Get.defaultDialog(
    title: attentionMessageTextLanguageArray[languageArrayIdentifier],
    content: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          changeDeviceNameMessageTextLanguageArray[languageArrayIdentifier],
          style: TextStyle(fontSize: screenHeight * 0.007 + screenWidth * 0.007, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: (screenHeight * 0.05)),
          child: TextField(
            textAlign: TextAlign.center,
            controller: myDeviceName,
            maxLines: 1,
            style: TextStyle(
              fontSize: (screenWidth * 0.05),
            ),
            decoration: InputDecoration(
                hintText: 'exp: Robot 1',
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
      if (myDeviceName.text.isNotEmpty) {
        await appClass.renameDevice(myDeviceName.text, deviceID);
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

void addAutomationConditionsRequestWidget() {
  double screenWidth = MediaQuery.of(Get.context!).size.width;
  double screenHeight = MediaQuery.of(Get.context!).size.height;
  Get.defaultDialog(
    title: attentionMessageTextLanguageArray[languageArrayIdentifier],
    content: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton.icon(
          onPressed: () {
            Get.back();
            Get.toNamed('/device_condition_automation_add');
          },
          icon: Icon(Icons.devices, size: screenHeight * 0.01 + screenWidth * 0.01, color: Colors.blue),
          label: Text(
            devicesButtonTextLanguageArray[languageArrayIdentifier],
            style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01, color: Colors.blue),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            Get.back();
            Get.toNamed('/timer_condition_automation_add');
          },
          icon: Icon(Icons.timer, size: screenHeight * 0.01 + screenWidth * 0.01, color: Colors.green),
          label: Text(
            timerTextLanguageArray[languageArrayIdentifier],
            style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01, color: Colors.green),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            Get.back();
            addWeatherConditionsParametersRequestWidget();
          },
          icon: Icon(Icons.cloud, size: screenHeight * 0.01 + screenWidth * 0.01, color: Colors.black),
          label: Text(
            weatherTextLanguageArray[languageArrayIdentifier],
            style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01, color: Colors.black),
          ),
        ),
      ],
    ),
  );
}

void addWeatherConditionsParametersRequestWidget() {
  double screenWidth = MediaQuery.of(Get.context!).size.width;
  double screenHeight = MediaQuery.of(Get.context!).size.height;
  Get.defaultDialog(
    title: attentionMessageTextLanguageArray[languageArrayIdentifier],
    content: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton.icon(
          onPressed: () {
            Get.back();
            Get.toNamed('/condition_automation_temperature_add');
          },
          icon: Image.asset('assets/temperature.png', height: screenHeight * 0.03, width: screenWidth * 0.03),
          label: Text(
            temperatureTextLanguageArray[languageArrayIdentifier],
            style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01, color: Colors.black),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            Get.back();
            Get.toNamed('/condition_automation_humidity_add');
          },
          icon: Image.asset('assets/humidity.png', height: screenHeight * 0.03, width: screenWidth * 0.03),
          label: Text(
            humidityTextLanguageArray[languageArrayIdentifier],
            style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01, color: Colors.black),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            Get.back();
            Get.toNamed('/condition_automation_weather_add');
          },
          icon: Icon(Icons.wb_auto, size: screenHeight * 0.01 + screenWidth * 0.01, color: Colors.black),
          label: Text(
            weatherTextLanguageArray[languageArrayIdentifier],
            style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01, color: Colors.black),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            Get.back();
            Get.toNamed('/condition_automation_sun_add');
          },
          icon: Icon(Icons.wb_twighlight, size: screenHeight * 0.01 + screenWidth * 0.01, color: Colors.black),
          label: Text(
            sunTextLanguageArray[languageArrayIdentifier],
            style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01, color: Colors.black),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            Get.back();
            Get.toNamed('/condition_automation_wind_speed_add');
          },
          icon: Image.asset('assets/windsock.png', height: screenHeight * 0.03, width: screenWidth * 0.03),
          label: Text(
            windTextLanguageArray[languageArrayIdentifier],
            style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01, color: Colors.black),
          ),
        ),
      ],
    ),
  );
}

void addAutomationActionsRequestWidget() {
  double screenWidth = MediaQuery.of(Get.context!).size.width;
  double screenHeight = MediaQuery.of(Get.context!).size.height;
  Get.defaultDialog(
    title: attentionMessageTextLanguageArray[languageArrayIdentifier],
    content: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton.icon(
          onPressed: () {
            Get.back();
            Get.toNamed('/device_automation_add');
          },
          icon: Icon(Icons.devices, size: screenHeight * 0.01 + screenWidth * 0.01, color: Colors.blue),
          label: Text(
            devicesButtonTextLanguageArray[languageArrayIdentifier],
            style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01, color: Colors.blue),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            Get.back();
            Get.toNamed('/timer_automation_add');
          },
          icon: Icon(Icons.timer, size: screenHeight * 0.01 + screenWidth * 0.01, color: Colors.green),
          label: Text(
            timerTextLanguageArray[languageArrayIdentifier],
            style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01, color: Colors.green),
          ),
        ),
      ],
    ),
  );
}

void addSceneElementRequestWidget() {
  double screenWidth = MediaQuery.of(Get.context!).size.width;
  double screenHeight = MediaQuery.of(Get.context!).size.height;
  Get.defaultDialog(
    title: attentionMessageTextLanguageArray[languageArrayIdentifier],
    content: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton.icon(
          onPressed: () {
            Get.back();
            Get.toNamed('/device_scene_add');
          },
          icon: Icon(Icons.devices, size: screenHeight * 0.01 + screenWidth * 0.01, color: Colors.blue),
          label: Text(
            devicesButtonTextLanguageArray[languageArrayIdentifier],
            style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01, color: Colors.blue),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            Get.back();
            Get.toNamed('/timer_scene_add');
          },
          icon: Icon(Icons.timer, size: screenHeight * 0.01 + screenWidth * 0.01, color: Colors.green),
          label: Text(
            timerTextLanguageArray[languageArrayIdentifier],
            style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01, color: Colors.green),
          ),
        ),
      ],
    ),
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

void deleteSceneRequestWidget() {
  double screenWidth = MediaQuery.of(Get.context!).size.width;
  double screenHeight = MediaQuery.of(Get.context!).size.height;
  Get.defaultDialog(
    title: attentionMessageTextLanguageArray[languageArrayIdentifier],
    content: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          sceneDeleteTextLanguageArray[languageArrayIdentifier],
          style: TextStyle(fontSize: screenHeight * 0.007 + screenWidth * 0.007, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      ],
    ),
    textConfirm: confirmButtonTextLanguageArray[languageArrayIdentifier],
    textCancel: cancelButtonTextLanguageArray[languageArrayIdentifier],
    onConfirm: () async {
      await appClass.users[userIdentifier].universes[universeIdentifier].scenes[sceneIdentifier].deleteScene();
      if (!requestResponse) {
        showToastMessage('Error request');
      } else {
        showToastMessage('request is valid');
      }
      Get.back();
    },
  );
}

void deleteAutomationRequestWidget() {
  double screenWidth = MediaQuery.of(Get.context!).size.width;
  double screenHeight = MediaQuery.of(Get.context!).size.height;
  Get.defaultDialog(
    title: attentionMessageTextLanguageArray[languageArrayIdentifier],
    content: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          automationDeleteTextLanguageArray[languageArrayIdentifier],
          style: TextStyle(fontSize: screenHeight * 0.007 + screenWidth * 0.007, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      ],
    ),
    textConfirm: confirmButtonTextLanguageArray[languageArrayIdentifier],
    textCancel: cancelButtonTextLanguageArray[languageArrayIdentifier],
    onConfirm: () async {
      await appClass.users[userIdentifier].universes[universeIdentifier].automations[automationIdentifier].deleteAutomation();
      if (!requestResponse) {
        showToastMessage('Error request');
      } else {
        showToastMessage('request is valid');
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
      await appClass.users[userIdentifier].universes[universeIdentifier].rooms[roomIdentifier].deleteRoom();
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

void deleteDeviceRequestWidget(String deviceID) {
  double screenWidth = MediaQuery.of(Get.context!).size.width;
  double screenHeight = MediaQuery.of(Get.context!).size.height;
  Get.defaultDialog(
    title: attentionMessageTextLanguageArray[languageArrayIdentifier],
    content: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          deviceDeleteTextLanguageArray[languageArrayIdentifier],
          style: TextStyle(fontSize: screenHeight * 0.007 + screenWidth * 0.007, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      ],
    ),
    textConfirm: confirmButtonTextLanguageArray[languageArrayIdentifier],
    textCancel: cancelButtonTextLanguageArray[languageArrayIdentifier],
    onConfirm: () async {
      await appClass.removeDevice(deviceID);
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

void deleteWarningWidget(String id, ElementType element) {
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
      if (myPassword.text == deletePassword) {
        switch (element) {
          case ElementType.universe:
            deleteUniverseRequestWidget(id);
            break;
          case ElementType.device:
            deleteDeviceRequestWidget(id);
            break;
        }
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
