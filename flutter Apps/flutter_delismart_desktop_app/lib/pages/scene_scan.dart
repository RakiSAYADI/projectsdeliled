import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/cards/scene_widget.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';

class ScanListScene extends StatefulWidget {
  const ScanListScene({Key? key}) : super(key: key);

  @override
  State<ScanListScene> createState() => _ScanListSceneState();
}

class _ScanListSceneState extends State<ScanListScene> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(scanScenesPageTitleTextLanguageArray[languageArrayIdentifier] + appClass.users[userIdentifier].universes[universeIdentifier].name),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search),
        backgroundColor: Colors.blue,
        onPressed: () async {
          appClass.users[userIdentifier].universes[universeIdentifier].scenes.clear();
          await appClass.users[userIdentifier].universes[universeIdentifier].getDevices();
          if (!requestResponse) {
            showToastMessage('test toast message');
          }
          setState(() {});
        },
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: appClass.users[userIdentifier].universes[universeIdentifier].scenes
              .map(
                (scene) => SceneCard(sceneClass: scene),
              )
              .toList(),
        ),
      ),
    );
  }
}
