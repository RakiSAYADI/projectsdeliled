import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';

class SceneCreate extends StatefulWidget {
  const SceneCreate({Key? key}) : super(key: key);

  @override
  State<SceneCreate> createState() => _SceneCreateState();
}

class _SceneCreateState extends State<SceneCreate> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(newSceneMessageTextLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(),
      ),
    );
  }
}
