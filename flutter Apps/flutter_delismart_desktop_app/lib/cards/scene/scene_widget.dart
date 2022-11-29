import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_scene.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';
import 'package:get/get.dart';

class SceneCard extends StatelessWidget {
  final SceneClass sceneClass;

  const SceneCard({Key? key, required this.sceneClass}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
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
                    sceneClass.name,
                    style: TextStyle(fontSize: heightScreen * 0.013 + widthScreen * 0.013),
                  ),
                  SizedBox(height: heightScreen * 0.001, width: widthScreen * 0.001),
                  sceneClass.enabled
                      ? Text(
                          'Enabled',
                          style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.green),
                        )
                      : Text(
                          'Disabled',
                          style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.red),
                        ),
                  SizedBox(height: heightScreen * 0.001, width: widthScreen * 0.001),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: TextButton.icon(
                onPressed: () async => await sceneClass.triggerScene(),
                icon: Icon(Icons.check, size: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.green),
                label: Text(
                  deviceExecuteButtonTextLanguageArray[languageArrayIdentifier],
                  style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.green),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: TextButton.icon(
                onPressed: () async {
                  await appClass.users[userIdentifier].universes[universeIdentifier].getDevices();
                  await appClass.users[userIdentifier].universes[universeIdentifier].getAutomations();
                  sceneIdentifier = appClass.users[userIdentifier].universes[universeIdentifier].scenes.indexOf(sceneClass);
                  Get.toNamed('/scene_modify');
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
              flex: 1,
              child: TextButton.icon(
                onPressed: () {
                  sceneIdentifier = appClass.users[userIdentifier].universes[universeIdentifier].scenes.indexOf(sceneClass);
                  deleteSceneRequestWidget();
                },
                icon: Icon(Icons.delete, size: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.red),
                label: Text(
                  deleteButtonTextLanguageArray[languageArrayIdentifier],
                  style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
