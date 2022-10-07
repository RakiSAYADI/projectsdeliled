import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';
import 'package:flutter_delismart_desktop_app/cards/user_widget.dart';

class ScanListUser extends StatefulWidget {
  const ScanListUser({Key? key}) : super(key: key);

  @override
  _ScanListUserState createState() => _ScanListUserState();
}

class _ScanListUserState extends State<ScanListUser> {
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
        onPressed: () async {
          appClass.users.clear();
          waitingRequestWidget();
          await appClass.getUserList();
          if (!requestResponse) {
            showToastMessage('Error request');
          }
          exitRequestWidget();
          setState(() {});
        },
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
            children: appClass.users
                .map((user) => UserCard(
                    userClass: user,
                    connect: () async {
                      user.universes.clear();
                      await user.getUniverses();
                      userIdentifier = appClass.users.indexOf(user);
                      if (!requestResponse) {
                        showToastMessage('Error request');
                      } else {
                        Navigator.pushNamed(context, '/universe_list');
                      }
                    }))
                .toList()),
      ),
    );
  }
}
