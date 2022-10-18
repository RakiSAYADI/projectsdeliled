import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';

class ScanListRoom extends StatefulWidget {
  const ScanListRoom({Key? key}) : super(key: key);

  @override
  State<ScanListRoom> createState() => _ScanListRoomState();
}

class _ScanListRoomState extends State<ScanListRoom> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(scanRoomsPageTitleTextLanguageArray[languageArrayIdentifier] + appClass.users[userIdentifier].universes[universeIdentifier].name),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search),
        backgroundColor: Colors.blue,
        onPressed: () async {
          appClass.users[userIdentifier].universes[universeIdentifier].rooms.clear();
          await appClass.users[userIdentifier].universes[universeIdentifier].getRooms();
          if (!requestResponse) {
            showToastMessage('test toast message');
          }
          setState(() {});
        },
      ),
    );
  }
}
