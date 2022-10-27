import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';

class TimerSceneAdd extends StatefulWidget {
  const TimerSceneAdd({Key? key}) : super(key: key);

  @override
  State<TimerSceneAdd> createState() => _TimerSceneAddState();
}

class _TimerSceneAddState extends State<TimerSceneAdd> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(addTimePageTitleTextLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
      ),
    );
  }
}
