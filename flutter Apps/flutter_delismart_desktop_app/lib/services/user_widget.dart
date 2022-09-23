import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_user.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';

import 'language_data_base.dart';

class UserCard extends StatelessWidget {
  final UserClass userClass;
  final Function() connect;

  const UserCard({required this.userClass, required this.connect});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              userClass.userName,
              style: TextStyle(fontSize: 10.0, color: Colors.grey[600]),
            ),
            const SizedBox(height: 2.0),
            Text(
              userClass.email,
              style: TextStyle(fontSize: 20.0, color: Colors.grey[800]),
            ),
            const SizedBox(height: 8.0),
            TextButton.icon(
              onPressed: connect,
              icon: const Icon(Icons.connect_without_contact),
              label: Text(deviceConnectButtonTextLanguageArray[languageArrayIdentifier]),
            )
          ],
        ),
      ),
    );
  }
}
