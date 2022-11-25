import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/cards/room/room_widget.dart';
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
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(scanRoomsPageTitleTextLanguageArray[languageArrayIdentifier] + appClass.users[userIdentifier].universes[universeIdentifier].name),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
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
                onPressed: () => addRoomRequestWidget(),
                icon: Icon(Icons.add, size: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.white),
                label: Text(
                  addRoomButtonTextLanguageArray[languageArrayIdentifier],
                  style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        backgroundColor: Colors.blue,
        onPressed: () async {
          await appClass.users[userIdentifier].universes[universeIdentifier].getRooms();
          if (!requestResponse) {
            showToastMessage(apiMessage);
          }
          setState(() {});
        },
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: appClass.users[userIdentifier].universes[universeIdentifier].rooms
              .map(
                (room) => RoomCard(roomClass: room),
              )
              .toList(),
        ),
      ),
    );
  }
}
