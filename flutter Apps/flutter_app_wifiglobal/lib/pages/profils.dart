import 'package:flutter/material.dart';
import 'package:wifiglobalapp/services/data_variables.dart';
import 'package:wifiglobalapp/services/language_database.dart';

class Profiles extends StatefulWidget {
  @override
  _ProfilesState createState() => _ProfilesState();
}

class _ProfilesState extends State<Profiles> {
  final myCompany = TextEditingController();
  final myName = TextEditingController();
  final myRoomName = TextEditingController();

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
    myCompany.dispose();
    myName.dispose();
    myRoomName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      myName.text = myDevice.deviceOperatorName;
      myRoomName.text = myDevice.deviceRoomName;
      myCompany.text = myDevice.deviceCompanyName;
    } catch (e) {
      debugPrint(e.toString());
    }

    debugPrint('company : ${myDevice.deviceCompanyName}');
    debugPrint('username : ${myDevice.deviceOperatorName}');
    debugPrint('roomname : ${myDevice.deviceRoomName}');

    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(profileTitleTextLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: heightScreen * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/etablissement_logo.png',
                            height: heightScreen * 0.09,
                            width: widthScreen * 0.5,
                          ),
                          SizedBox(height: heightScreen * 0.03),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: (widthScreen * 0.02)),
                            child: TextField(
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              maxLength: 15,
                              controller: myCompany,
                              style: TextStyle(
                                fontSize: widthScreen * 0.03,
                                color: Colors.grey[800],
                              ),
                              decoration: InputDecoration(
                                  hintText: establishmentTextLanguageArray[languageArrayIdentifier],
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/operateur_logo.png',
                            height: heightScreen * 0.09,
                            width: widthScreen * 0.5,
                          ),
                          SizedBox(height: heightScreen * 0.03),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: (widthScreen * 0.02)),
                            child: TextField(
                              textAlign: TextAlign.center,
                              maxLength: 15,
                              maxLines: 1,
                              controller: myName,
                              style: TextStyle(
                                fontSize: widthScreen * 0.03,
                                color: Colors.grey[800],
                              ),
                              decoration: InputDecoration(
                                  hintText: operatorTextLanguageArray[languageArrayIdentifier],
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/piece_logo.png',
                            height: heightScreen * 0.09,
                            width: widthScreen * 0.5,
                          ),
                          SizedBox(height: heightScreen * 0.03),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: (widthScreen * 0.02)),
                            child: TextField(
                              textAlign: TextAlign.center,
                              maxLength: 15,
                              maxLines: 1,
                              controller: myRoomName,
                              style: TextStyle(
                                fontSize: widthScreen * 0.03,
                              ),
                              decoration: InputDecoration(
                                  hintText: roomTextLanguageArray[languageArrayIdentifier],
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: heightScreen * 0.15),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: (widthScreen * 0.1)),
                  child: Text(
                    profileMessageTextLanguageArray[languageArrayIdentifier],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: widthScreen * 0.03,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: heightScreen * 0.04),
                TextButton(
                  onPressed: () {
                    myDevice.deviceOperatorName = myName.text;
                    myDevice.deviceRoomName = myRoomName.text;
                    myDevice.deviceCompanyName = myCompany.text;
                    Navigator.pushNamed(context, '/settings');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      nextTextLanguageArray[languageArrayIdentifier],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: widthScreen * 0.02,
                      ),
                    ),
                  ),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                ),
                SizedBox(height: heightScreen * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
