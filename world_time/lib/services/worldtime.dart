import 'dart:convert';

import 'package:http/http.dart';
import 'package:intl/intl.dart';

class WorldTime {
  String location;
  String time;
  String flag;
  String url;
  bool isDayTime;

  WorldTime({this.location, this.flag, this.url});

  Future<String> getTime() async {
    try {
      Response response =
          await get('http://worldtimeapi.org/api/timezone/$url');
      Map data = jsonDecode(response.body);

      String dateTimeTunis = data['datetime'];
      String utcOffset = data['utc_offset'].substring(1, 3);

      DateTime dateTime = DateTime.parse(dateTimeTunis);
      dateTime = dateTime.add(Duration(hours: int.parse(utcOffset)));

      isDayTime = dateTime.hour > 6 && dateTime.hour < 20 ? true : false;

      time = DateFormat.Hm().format(dateTime);
      return time;
    } catch (e) {
      print('error is catched : $e');
      return time = ' could not get time right';
    }
  }
}
