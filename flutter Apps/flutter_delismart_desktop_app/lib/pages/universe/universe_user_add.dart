import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';

class UniverseUserAdd extends StatefulWidget {
  const UniverseUserAdd({Key? key}) : super(key: key);

  @override
  State<UniverseUserAdd> createState() => _UniverseUserAddState();
}

class _UniverseUserAddState extends State<UniverseUserAdd> {
  final myUniverseUserName = TextEditingController();
  final myUniverseUserAddress = TextEditingController();
  String accessTypeUserData = administratorUserChoiceMessageTextLanguageArray[languageArrayIdentifier];

  @override
  void dispose() {
    // TODO: implement dispose
    myUniverseUserName.dispose();
    myUniverseUserAddress.dispose();
    super.dispose();
  }

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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                nameTextLanguageArray[languageArrayIdentifier],
                style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
                child: TextField(
                  textAlign: TextAlign.center,
                  controller: myUniverseUserName,
                  maxLines: 1,
                  maxLength: 20,
                  style: TextStyle(
                    fontSize: screenHeight * 0.01 + screenWidth * 0.01,
                  ),
                  decoration: InputDecoration(
                      hintText: 'Exp: My Name',
                      hintStyle: TextStyle(
                        fontSize: screenHeight * 0.01 + screenWidth * 0.01,
                        color: Colors.grey,
                      )),
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              Text(
                universeAddressTextLanguageArray[languageArrayIdentifier],
                style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
                child: TextField(
                  textAlign: TextAlign.center,
                  controller: myUniverseUserAddress,
                  maxLines: 1,
                  maxLength: 100,
                  style: TextStyle(
                    fontSize: screenHeight * 0.01 + screenWidth * 0.01,
                  ),
                  decoration: InputDecoration(
                      hintText: 'user@exemple.fr',
                      hintStyle: TextStyle(
                        fontSize: screenHeight * 0.01 + screenWidth * 0.01,
                        color: Colors.grey,
                      )),
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              Text(
                stateUserChoiceMessageTextLanguageArray[languageArrayIdentifier],
                style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
                child: DropdownButton<String>(
                  value: accessTypeUserData,
                  icon: const Icon(Icons.arrow_drop_down),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(color: Colors.grey[800], fontSize: screenHeight * 0.01 + screenWidth * 0.01),
                  underline: Container(
                    height: 2,
                    color: Colors.blue[300],
                  ),
                  onChanged: (String? data) {
                    setState(() {
                      accessTypeUserData = data!;
                    });
                  },
                  items: accessTypeUserList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              TextButton(
                onPressed: () async {
                  if (myUniverseUserName.text.isNotEmpty && myUniverseUserAddress.text.isNotEmpty && appClass.getUsersEmail().contains(myUniverseUserAddress.text)) {
                    await appClass.users[userIdentifier].universes[universeIdentifier]
                        .addUserUniverse(accessTypeUserList.indexOf(accessTypeUserData) == 0 ? false : true, myUniverseUserName.text, myUniverseUserAddress.text);
                    if (!requestResponse) {
                      showToastMessage('Error request');
                    } else {
                      showToastMessage('request is valid');
                    }
                  } else {
                    showToastMessage('empty or wrong text fields !');
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    addButtonTextLanguageArray[languageArrayIdentifier],
                    style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.02 + screenHeight * 0.02),
                  ),
                ),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(60.0))),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
