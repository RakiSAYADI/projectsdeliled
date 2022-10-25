import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/cards/automation_widget.dart';
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
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(scanAutomationPageTitleTextLanguageArray[languageArrayIdentifier] + appClass.users[userIdentifier].universes[universeIdentifier].name),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search),
        backgroundColor: Colors.blue,
        onPressed: () async {
          await appClass.users[userIdentifier].universes[universeIdentifier].getAutomations();
          if (!requestResponse) {
            showToastMessage('test toast message');
          }
          setState(() {});
        },
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
