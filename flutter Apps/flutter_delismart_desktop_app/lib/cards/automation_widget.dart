import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_automation.dart';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              automationClass.name,
              style: TextStyle(fontSize: heightScreen * 0.013 + widthScreen * 0.013),
            ),
            SizedBox(height: heightScreen * 0.001, width: widthScreen * 0.001),
            Text(
              automationClass.automationId,
              style: TextStyle(fontSize: heightScreen * 0.007 + widthScreen * 0.007),
            ),
            SizedBox(height: heightScreen * 0.001, width: widthScreen * 0.001),
          ],
        ),
      ),
    );
  }
}
