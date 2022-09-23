import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_app.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_user.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';
import 'package:flutter_delismart_desktop_app/services/user_widget.dart';

class ScanListUser extends StatefulWidget {
  const ScanListUser({Key? key}) : super(key: key);

  @override
  _ScanListUserState createState() => _ScanListUserState();
}

class _ScanListUserState extends State<ScanListUser> {
  List<UserClass> users = [];

  @override
  void initState() {
    AppClass appClass = AppClass();
    appClass.getInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(scanUserPageTitleTextLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search),
        backgroundColor: Colors.blue,
        onPressed: () {},
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(children: users.map((user) => UserCard(userClass: user, connect: () async {})).toList()),
      ),
    );
  }
}
