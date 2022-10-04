import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';

class UserCreate extends StatefulWidget {
  const UserCreate({Key? key}) : super(key: key);

  @override
  State<UserCreate> createState() => _UserCreateState();
}

class _UserCreateState extends State<UserCreate> {
  final myEmail = TextEditingController();
  final myPassword = TextEditingController();
  final myName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(userRegisterPageTitleTextLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      userEmailTextLanguageArray[languageArrayIdentifier],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: (screenWidth * 0.015 + screenHeight * 0.015), fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: (screenHeight * 0.05)),
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
                              fontSize: (screenWidth * 0.025 + screenHeight * 0.025),
                              color: Colors.grey,
                            )),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      userPasswordTextLanguageArray[languageArrayIdentifier],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: (screenWidth * 0.015 + screenHeight * 0.015), fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: (screenHeight * 0.05)),
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: myPassword,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: (screenWidth * 0.05),
                        ),
                        decoration: InputDecoration(
                            hintText: '****',
                            hintStyle: TextStyle(
                              fontSize: (screenWidth * 0.025 + screenHeight * 0.025),
                              color: Colors.grey,
                            )),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      userNameTextLanguageArray[languageArrayIdentifier],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: (screenWidth * 0.015 + screenHeight * 0.015), fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: (screenHeight * 0.05)),
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: myName,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: (screenWidth * 0.05),
                        ),
                        decoration: InputDecoration(
                            hintText: 'exp: Fabrice',
                            hintStyle: TextStyle(
                              fontSize: (screenWidth * 0.025 + screenHeight * 0.025),
                              color: Colors.grey,
                            )),
                      ),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () async {
                  if (myEmail.text.isNotEmpty && myPassword.text.isNotEmpty && myName.text.isNotEmpty) {
                    await appClass.postCreateUser(
                        "{\"country_code\": \"33\", \"username\": \"${myEmail.text}\", \"password\": \"${myPassword.text}\", \"nick_name\": \"${myName.text}\", \"username_type\": \"2\"}");
                    if (!requestResponse) {
                      showToastMessage('Error request');
                    } else {
                      showToastMessage('create request is valid');
                    }
                  } else {
                    showToastMessage('empty text fields !');
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    createUserButtonTextLanguageArray[languageArrayIdentifier],
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
