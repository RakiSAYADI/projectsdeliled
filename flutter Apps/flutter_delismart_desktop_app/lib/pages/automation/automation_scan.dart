import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/cards/automation/automation_widget.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';

class ScanListAutomation extends StatefulWidget {
  const ScanListAutomation({Key? key}) : super(key: key);

  @override
  State<ScanListAutomation> createState() => _ScanListAutomationState();
}

class _ScanListAutomationState extends State<ScanListAutomation> {
  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(scanAutomationPageTitleTextLanguageArray[languageArrayIdentifier] + appClass.users[userIdentifier].universes[universeIdentifier].name),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        backgroundColor: Colors.blue,
        onPressed: () async {
          await appClass.users[userIdentifier].universes[universeIdentifier].getAutomations();
          if (!requestResponse) {
            showToastMessage('test toast message');
          }
          setState(() {});
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton.icon(
                onPressed: () async {
                  await appClass.users[userIdentifier].universes[universeIdentifier].getDevices();
                  Navigator.pushNamed(context, '/automation_create');
                },
                icon: Icon(Icons.add, size: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.white),
                label: Text(
                  addAutomationButtonTextLanguageArray[languageArrayIdentifier],
                  style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: appClass.users[userIdentifier].universes[universeIdentifier].automations
              .map(
                (automation) => AutomationCard(automationClass: automation),
              )
              .toList(),
        ),
      ),
    );
  }
}
