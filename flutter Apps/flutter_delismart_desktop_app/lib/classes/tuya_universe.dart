import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_device.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_home_user.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_room.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';

class UniverseClass {
  String geoName = '';
  int homeId = 0;
  double lat = 0;
  double lon = 0;
  String name = '';
  String role = '';
  List<RoomClass> rooms = [];
  List<DeviceClass> devices = [];
  List<UniverseUserClass> users = [];

  String _queryGetDevicesList = '';
  String _queryGetMembersList = '';

  UniverseClass({required this.geoName, required this.homeId, this.lat = 0.0, this.lon = 0.0, required this.name, required this.role});

  Future getUsers() async {
    waitingRequestWidget();
    _queryGetMembersList = '/v1.0/homes/$homeId/members';
    await tokenAPIRequest.sendRequest(Method.get, _queryGetMembersList);
    if (tokenAPIRequest.getResponse().isNotEmpty) {
      try {
        Map<String, dynamic> message = tokenAPIRequest.getResponse();
        requestResponse = message['success'] as bool;
        if (requestResponse) {
          List<dynamic> result = message['result'] as List<dynamic>;
          for (int i = 0; i < result.length; i++) {
            users.add(UniverseUserClass(
              admin: result[i]['admin'] as bool,
              avatarImage: result[i]['avatar'],
              countryCode: result[i]['country_code'],
              memberAccount: result[i]['member_account'],
              name: result[i]['name'],
              owner: result[i]['owner'] as bool,
              uid: result[i]['uid'],
            ));
          }
        }
      } catch (e) {
        requestResponse = false;
        debugPrint(e.toString());
      }
    }
    exitRequestWidget();
  }

  Future getDevices() async {
    waitingRequestWidget();
    _queryGetDevicesList = '/v1.0/homes/$homeId/devices';
    await tokenAPIRequest.sendRequest(Method.get, _queryGetDevicesList);
    if (tokenAPIRequest.getResponse().isNotEmpty) {
      try {
        Map<String, dynamic> message = tokenAPIRequest.getResponse();
        requestResponse = message['success'] as bool;
        if (requestResponse) {
          List<dynamic> result = message['result'] as List<dynamic>;
          for (int i = 0; i < result.length; i++) {
            devices.add(DeviceClass(
              activeTime: int.parse(result[i]['active_time'].toString()),
              bizType: int.parse(result[i]['biz_type'].toString()),
              category: result[i]['category'],
              createTime: int.parse(result[i]['create_time'].toString()),
              imageUrl: result[i]['icon'],
              id: result[i]['id'],
              ip: result[i]['ip'],
              lat: result[i]['lat'],
              lon: result[i]['lon'],
              model: result[i]['model'],
              name: result[i]['name'],
              online: result[i]['online'] as bool,
              ownerId: result[i]['owner_id'],
              productId: result[i]['product_id'],
              productName: result[i]['product_name'],
              sub: result[i]['sub'] as bool,
              timeZone: result[i]['time_zone'],
              uid: result[i]['uid'],
              updateTime: int.parse(result[i]['update_time'].toString()),
              uuid: result[i]['uuid'],
            ));
          }
        }
      } catch (e) {
        requestResponse = false;
        debugPrint(e.toString());
      }
    }
    exitRequestWidget();
  }
}
