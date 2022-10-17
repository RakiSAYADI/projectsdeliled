import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_universe.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';

class UniverseCard extends StatelessWidget {
  final UniverseClass universeClass;

  const UniverseCard({Key? key, required this.universeClass}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    Color accessTypeIconColor = Colors.white;
    IconData accessTypeIcon = Icons.accessibility;
    String accessTypeText = 'default';
    switch (universeClass.role) {
      case 'OWNER':
        accessTypeIconColor = Colors.amber;
        accessTypeText = universeOwnerTextLanguageArray[languageArrayIdentifier];
        break;
      case 'ADMIN':
        accessTypeIconColor = Colors.blue;
        accessTypeText = universeAdminDeviceTextLanguageArray[languageArrayIdentifier];
        break;
      case 'MEMBER':
        accessTypeIconColor = Colors.black;
        accessTypeText = universeMemberDeviceTextLanguageArray[languageArrayIdentifier];
        break;
    }
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 9,
                  child: Column(
                    //crossAxisAlignment: CrossAxisAlignment.stretch,
                    //mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SelectableText(
                        universeClass.name,
                        style: TextStyle(fontSize: heightScreen * 0.013 + widthScreen * 0.013, color: Colors.grey[800]),
                      ),
                      SelectableText(
                        universeClass.geoName,
                        style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.grey[600]),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SelectableText(
                            'lon : ${universeClass.lon}',
                            style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.grey[800]),
                          ),
                          SelectableText(
                            ' lat : ${universeClass.lat}',
                            style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.grey[800]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(accessTypeIcon, size: heightScreen * 0.01 + widthScreen * 0.01, color: accessTypeIconColor),
                      Text(
                        accessTypeText,
                        style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: accessTypeIconColor),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: TextButton.icon(
                    onPressed: () => deleteUniverseRequestWidget(universeClass.homeId.toString()),
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
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: TextButton.icon(
                    onPressed: () async {
                      universeClass.users.clear();
                      await universeClass.getUsers();
                      universeIdentifier = appClass.users[userIdentifier].universes.indexOf(universeClass);
                      if (!requestResponse) {
                        showToastMessage('Error request');
                      } else {
                        Navigator.pushNamed(context, '/universe_user_list');
                      }
                    },
                    icon: Icon(Icons.supervised_user_circle, size: heightScreen * 0.009 + widthScreen * 0.009),
                    label: Text(
                      usersButtonTextLanguageArray[languageArrayIdentifier],
                      style: TextStyle(fontSize: heightScreen * 0.009 + widthScreen * 0.009),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: TextButton.icon(
                    onPressed: () async {
                      universeClass.devices.clear();
                      await universeClass.getDevices();
                      universeIdentifier = appClass.users[userIdentifier].universes.indexOf(universeClass);
                      if (!requestResponse) {
                        showToastMessage('Error request');
                      } else {
                        Navigator.pushNamed(context, '/device_list');
                      }
                    },
                    icon: Icon(Icons.devices, size: heightScreen * 0.009 + widthScreen * 0.009),
                    label: Text(
                      devicesButtonTextLanguageArray[languageArrayIdentifier],
                      style: TextStyle(fontSize: heightScreen * 0.009 + widthScreen * 0.009),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: TextButton.icon(
                    onPressed: () async {
                      universeClass.scenes.clear();
                      await universeClass.getScenes();
                      universeIdentifier = appClass.users[userIdentifier].universes.indexOf(universeClass);
                      if (!requestResponse) {
                        showToastMessage('Error request');
                      } else {
                        Navigator.pushNamed(context, '/scene_list');
                      }
                    },
                    icon: Icon(Icons.check_box_outlined, size: heightScreen * 0.009 + widthScreen * 0.009),
                    label: Text(
                      scenesButtonTextLanguageArray[languageArrayIdentifier],
                      style: TextStyle(fontSize: heightScreen * 0.009 + widthScreen * 0.009),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: TextButton.icon(
                    onPressed: () async {
                      universeClass.automations.clear();
                      await universeClass.getAutomations();
                      universeIdentifier = appClass.users[userIdentifier].universes.indexOf(universeClass);
                      if (!requestResponse) {
                        showToastMessage('Error request');
                      } else {
                        Navigator.pushNamed(context, '/automation_list');
                      }
                    },
                    icon: Icon(Icons.alarm, size: heightScreen * 0.009 + widthScreen * 0.009),
                    label: Text(
                      automationButtonTextLanguageArray[languageArrayIdentifier],
                      style: TextStyle(fontSize: heightScreen * 0.009 + widthScreen * 0.009),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
