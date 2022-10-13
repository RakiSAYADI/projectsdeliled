import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_home_user.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';

class UniverseUserCard extends StatelessWidget {
  final UniverseUserClass universeUserClass;

  const UniverseUserCard({Key? key, required this.universeUserClass}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    Color accessTypeIconColor = Colors.white;
    IconData accessTypeIcon = Icons.accessibility;
    String accessTypeText = 'default';
    if (universeUserClass.owner) {
      accessTypeIconColor = Colors.amber;
      accessTypeText = universeOwnerTextLanguageArray[languageArrayIdentifier];
    } else {
      if (universeUserClass.admin) {
        accessTypeIconColor = Colors.blue;
        accessTypeText = universeAdminDeviceTextLanguageArray[languageArrayIdentifier];
      } else {
        accessTypeIconColor = Colors.black;
        accessTypeText = universeMemberDeviceTextLanguageArray[languageArrayIdentifier];
      }
    }

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    universeUserClass.name,
                    style: TextStyle(fontSize: heightScreen * 0.013 + widthScreen * 0.013),
                  ),
                  SizedBox(height: heightScreen * 0.001, width: widthScreen * 0.001),
                  Text(
                    universeUserClass.memberAccount,
                    style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007),
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
              flex: 1,
              child: universeUserClass.avatarImage.isEmpty
                  ? Image.asset(
                      'assets/avatar.png',
                      height: heightScreen * 0.1,
                      width: widthScreen * 0.1,
                    )
                  : Image.network(
                      universeUserClass.avatarImage,
                      height: heightScreen * 0.1,
                      width: widthScreen * 0.1,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
