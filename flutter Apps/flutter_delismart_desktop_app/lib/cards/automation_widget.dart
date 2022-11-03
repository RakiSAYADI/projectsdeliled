import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_automation.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';
import 'package:get/get.dart';

class AutomationCard extends StatelessWidget {
  final AutomationClass automationClass;

  const AutomationCard({Key? key, required this.automationClass}) : super(key: key);

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
                    automationClass.name,
                    style: TextStyle(fontSize: heightScreen * 0.013 + widthScreen * 0.013),
                  ),
                  SizedBox(height: heightScreen * 0.001, width: widthScreen * 0.001),
                  automationClass.enabled
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
                onPressed: () async {
                  await appClass.users[userIdentifier].universes[universeIdentifier].getDevices();
                  automationIdentifier = appClass.users[userIdentifier].universes[universeIdentifier].automations.indexOf(automationClass);
                  Get.toNamed('/automation_modify');
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
                  automationIdentifier = appClass.users[userIdentifier].universes[universeIdentifier].automations.indexOf(automationClass);
                  deleteAutomationRequestWidget();
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
