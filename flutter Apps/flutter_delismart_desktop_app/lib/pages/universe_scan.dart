import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/cards/universe_widget.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';

class ScanListUniverse extends StatefulWidget {
  const ScanListUniverse({Key? key}) : super(key: key);

  @override
  _ScanListUniverseState createState() => _ScanListUniverseState();
}

class _ScanListUniverseState extends State<ScanListUniverse> {
  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/universe_create'),
                icon: Icon(Icons.add, size: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.white),
                label: Text(
                  addUniverseButtonTextLanguageArray[languageArrayIdentifier],
                  style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(scanUniversePageTitleTextLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        backgroundColor: Colors.blue,
        onPressed: () async {
          appClass.users[userIdentifier].universes.clear();
          await appClass.users[userIdentifier].getUniverses();
          if (!requestResponse) {
            showToastMessage('Error request');
          }
          setState(() {});
        },
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(children: appClass.users[userIdentifier].universes.map((universe) => UniverseCard(universeClass: universe)).toList()),
      ),
    );
  }
}
