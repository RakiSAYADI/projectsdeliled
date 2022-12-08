import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';

class DeviceClass {
  int activeTime = 0;
  int bizType = 0;
  String category = '';
  int createTime = 0;
  String imageUrl = '';
  String id = '';
  String ip = '';
  String lat = '';
  String localKey = '';
  String lon = '';
  String model = '';
  String name = '';
  bool online = false;
  String ownerId = '';
  String homeId = '';
  String productId = '';
  String productName = '';
  List<Map<String, dynamic>> supportedConditions = [];
  List<Map<String, dynamic>> supportedFunctions = [];
  List<Map<String, dynamic>> functions = [];
  bool sub = false;
  String timeZone = '';
  String uid = '';
  int updateTime = 0;
  String uuid = '';

  DeviceClass(
      {required this.activeTime,
      required this.bizType,
      required this.category,
      required this.createTime,
      required this.imageUrl,
      required this.id,
      required this.ip,
      required this.lat,
      this.localKey = '',
      required this.lon,
      required this.model,
      required this.name,
      required this.online,
      required this.ownerId,
      required this.productId,
      required this.productName,
      required this.sub,
      required this.homeId,
      required this.timeZone,
      required this.uid,
      required this.updateTime,
      required this.uuid,
      required this.functions});

  void addSupportedFunctions(List<Map<String, dynamic>> functions) => supportedFunctions = functions;

  void addSupportedConditions(List<Map<String, dynamic>> conditions) => supportedConditions = conditions;

  void sendTestLEDCommand() async {
    waitingRequestWidget();
    int i = 6;
    bool state = false;
    while (i > 0) {
      final String _queryChangeStateDevice = '/v1.0/devices/${id.toString()}/commands';
      await tokenAPIRequest.sendRequest(Method.post, _queryChangeStateDevice,
          body: "{\n"
              "\"commands\": [\n"
              "{\n"
              "\"code\": \"switch_led\",\n"
              "\"value\": $state"
              "\n}"
              "\n]"
              "\n}");
      if (tokenAPIRequest.getResponse().isNotEmpty) {
        try {
          Map<String, dynamic> message = tokenAPIRequest.getResponse();
          requestResponse = message['success'] as bool;
          if (!requestResponse) {
            apiMessage = message['msg'] as String;
          }
        } catch (e) {
          requestResponse = false;
          debugPrint(e.toString());
        }
      }
      await Future.delayed(const Duration(seconds: 1));
      state = !state;
      i--;
    }
    exitRequestWidget();
  }

  Future searchForRoom() async {
    waitingRequestWidget();
    String _queryGetRoomsList = '/v1.0/homes/$homeId/rooms';
    String roomName = '';
    bool search = false;
    await tokenAPIRequest.sendRequest(Method.get, _queryGetRoomsList);
    if (tokenAPIRequest.getResponse().isNotEmpty) {
      try {
        Map<String, dynamic> message = tokenAPIRequest.getResponse();
        requestResponse = message['success'] as bool;
        if (requestResponse) {
          Map<String, dynamic> result = message['result'] as Map<String, dynamic>;
          List<dynamic> resultRooms = result['rooms'] as List<dynamic>;
          String _queryGetRoomDevicesList;
          for (int i = 0; i < resultRooms.length; i++) {
            _queryGetRoomDevicesList = '/v1.0/homes/$homeId/rooms/${resultRooms[i]['room_id']}/devices';
            await tokenAPIRequest.sendRequest(Method.get, _queryGetRoomDevicesList);
            if (tokenAPIRequest.getResponse().isNotEmpty) {
              message = tokenAPIRequest.getResponse();
              requestResponse = message['success'] as bool;
              if (requestResponse) {
                List<dynamic> resultDevices = message['result'] as List<dynamic>;
                for (int j = 0; j < resultDevices.length; j++) {
                  if (resultDevices[j]['id'] == id) {
                    search = true;
                    roomName = resultRooms[j]['name'];
                    break;
                  }
                }
              }
            } else {
              apiMessage = message['msg'] as String;
            }
          }
        } else {
          apiMessage = message['msg'] as String;
        }
      } catch (e) {
        requestResponse = false;
        debugPrint(e.toString());
      }
    }
    exitRequestWidget();
    search ? messageRequestWidget(thisRoomsButtonTextLanguageArray[languageArrayIdentifier] + roomName) : messageRequestWidget(noRoomsButtonTextLanguageArray[languageArrayIdentifier]);
  }
}
