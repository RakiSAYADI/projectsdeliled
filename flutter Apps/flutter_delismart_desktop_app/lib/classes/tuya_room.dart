import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_device.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';

class RoomClass {
  int homeId = 0;
  String name = '';
  int id = 0;
  List<DeviceClass> devices = [];

  String _queryGetRoomDevicesList = '';

  RoomClass({required this.homeId, required this.name, required this.id});

  Future getDevices() async {
    waitingRequestWidget();
    _queryGetRoomDevicesList = '/v1.0/homes/${homeId.toString()}/rooms/devices';
    await tokenAPIRequest.sendRequest(Method.get, _queryGetRoomDevicesList);
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
