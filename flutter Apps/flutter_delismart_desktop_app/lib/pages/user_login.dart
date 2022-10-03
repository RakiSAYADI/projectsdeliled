import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({Key? key}) : super(key: key);

  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  final myEmail = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(userLoginPageTitleTextLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      enterUserEmailTextLanguageArray[languageArrayIdentifier],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: (screenWidth * 0.05), fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: myEmail,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: (screenWidth * 0.05),
                        ),
                        decoration: InputDecoration(
                            hintText: 'user@exemple.fr',
                            hintStyle: TextStyle(
                              fontSize: (screenWidth * 0.05),
                              color: Colors.grey,
                            )),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.1),
                    TextButton(
                      onPressed: () async {
                        if (appClass.getUsersEmail().contains(myEmail.text)) {
                          int pos = appClass.getUsersEmail().indexOf(myEmail.text);
                          appClass.users[pos].universes.clear();
                          await appClass.users[pos].getUniverses();
                          userIdentifier = appClass.users.indexOf(appClass.users[pos]);
                          if (!requestResponse) {
                            showToastMessage('Error request');
                          } else {
                            Navigator.pushNamed(context, '/universe_list');
                          }
                        } else {
                          showToastMessage('the user: ${myEmail.text} is not registered');
                        }
                      },
                      child: Text(
                        connectUserButtonTextLanguageArray[languageArrayIdentifier],
                        style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
                      ),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
