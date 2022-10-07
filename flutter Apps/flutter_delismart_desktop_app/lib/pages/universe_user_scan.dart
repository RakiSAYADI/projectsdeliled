import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/cards/universe_user_widget.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';

class ScanListUniverseUser extends StatefulWidget {
  const ScanListUniverseUser({Key? key}) : super(key: key);

  @override
  State<ScanListUniverseUser> createState() => _ScanListUniverseUserState();
}

class _ScanListUniverseUserState extends State<ScanListUniverseUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(scanUniverseUsersPageTitleTextLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        backgroundColor: Colors.blue,
        onPressed: () async {
          appClass.users[userIdentifier].universes[universeIdentifier].users.clear();
          await appClass.users[userIdentifier].universes[universeIdentifier].getUsers();
          if (!requestResponse) {
            showToastMessage('Error request');
          }
          setState(() {});
        },
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(children: appClass.users[userIdentifier].universes[universeIdentifier].users.map((user) => UniverseUserCard(universeUserClass: user)).toList()),
      ),
    );
  }
}
