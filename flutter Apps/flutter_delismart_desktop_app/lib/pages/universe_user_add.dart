import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';

class UniverseUserAdd extends StatefulWidget {
  const UniverseUserAdd({Key? key}) : super(key: key);

  @override
  State<UniverseUserAdd> createState() => _UniverseUserAddState();
}

class _UniverseUserAddState extends State<UniverseUserAdd> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(universeUserAddMessageTextLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
      ),
      body: const Center(
        child: SingleChildScrollView(),
      ),
    );
  }
}
