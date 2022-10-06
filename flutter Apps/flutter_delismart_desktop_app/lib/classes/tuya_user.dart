import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_universe.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';

class UserClass {
  String userName = '';
  String email = '';
  String uid = '';
  int updateTime = 0;
  int createTime = 0;
  List<UniverseClass> universes = [];

  String _queryGetUniversesList = '';

  UserClass({required this.userName, this.email = '', required this.createTime, required this.uid, required this.updateTime});

  Future getUniverses() async {
    waitingRequestWidget();
    _queryGetUniversesList = '/v1.0/users/$uid/homes';
    await tokenAPIRequest.sendRequest(Method.get, _queryGetUniversesList);
    if (tokenAPIRequest.getResponse().isNotEmpty) {
      try {
        Map<String, dynamic> message = tokenAPIRequest.getResponse();
        requestResponse = message['success'] as bool;
        if (requestResponse) {
          List<dynamic> result = message['result'] as List<dynamic>;
          for (int i = 0; i < result.length; i++) {
            universes.add(UniverseClass(
              geoName: result[i]['geo_name'],
              homeId: result[i]['home_id'],
              lat: (result[i] as Map<String, dynamic>).containsKey('lat') ? double.parse(result[i]['lat'].toString()) : 0.0,
              lon: (result[i] as Map<String, dynamic>).containsKey('lon') ? double.parse(result[i]['lon'].toString()) : 0.0,
              name: result[i]['name'],
              role: result[i]['role'],
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
