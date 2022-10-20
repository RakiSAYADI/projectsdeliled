import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_room.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';

class RoomCard extends StatelessWidget {
  final RoomClass roomClass;

  const RoomCard({Key? key, required this.roomClass}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  flex: 9,
                  child: Text(
                    roomClass.name,
                    style: TextStyle(fontSize: heightScreen * 0.013 + widthScreen * 0.013, color: Colors.grey[800]),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: TextButton.icon(
                    onPressed: () {
                      roomIdentifier = appClass.users[userIdentifier].universes[universeIdentifier].rooms.indexOf(roomClass);
                      renameRoomRequestWidget(roomClass.name);
                    },
                    icon: Icon(Icons.edit, size: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.blue),
                    label: Text(
                      modifyUserButtonTextLanguageArray[languageArrayIdentifier],
                      style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.blue),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: TextButton.icon(
                    onPressed: () {
                      roomIdentifier = appClass.users[userIdentifier].universes[universeIdentifier].rooms.indexOf(roomClass);
                      deleteRoomRequestWidget(roomClass.id.toString());
                    },
                    icon: Icon(Icons.delete, size: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.red),
                    label: Text(
                      deleteUserButtonTextLanguageArray[languageArrayIdentifier],
                      style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: heightScreen * 0.001, width: widthScreen * 0.001),
            TextButton.icon(
              onPressed: () async {
                roomClass.devices.clear();
                await roomClass.getDevices();
                roomIdentifier = appClass.users[userIdentifier].universes[universeIdentifier].rooms.indexOf(roomClass);
                if (!requestResponse) {
                  showToastMessage('Error request');
                } else {
                  Navigator.pushNamed(context, '/room_device_list');
                }
              },
              icon: Icon(Icons.devices, size: heightScreen * 0.009 + widthScreen * 0.009),
              label: Text(
                devicesButtonTextLanguageArray[languageArrayIdentifier],
                style: TextStyle(fontSize: heightScreen * 0.009 + widthScreen * 0.009),
              ),
            ),
            SizedBox(height: heightScreen * 0.001, width: widthScreen * 0.001),
          ],
        ),
      ),
    );
  }
}
