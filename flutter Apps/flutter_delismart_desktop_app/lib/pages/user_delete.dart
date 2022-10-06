import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_user.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';

class UserDelete extends StatefulWidget {
  const UserDelete({Key? key}) : super(key: key);

  @override
  State<UserDelete> createState() => _UserDeleteState();
}

class _UserDeleteState extends State<UserDelete> {
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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                enterUserEmailTextLanguageArray[languageArrayIdentifier],
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: (screenWidth * 0.03 + screenHeight * 0.03), fontWeight: FontWeight.bold),
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
                        fontSize: (screenWidth * 0.025 + screenHeight * 0.025),
                        color: Colors.grey,
                      )),
                ),
              ),
              SizedBox(height: screenHeight * 0.1),
              TextButton(
                onPressed: () async {
                  if (appClass.getUsersEmail().contains(myEmail.text)) {
                    int pos = appClass.getUsersEmail().indexOf(myEmail.text);
                    UserClass userToDelete = appClass.users[pos];
                    await appClass.postDeleteUser(userToDelete.uid);
                    if (!requestResponse) {
                      showToastMessage('Error request');
                    } else {
                      showToastMessage('the user: ${myEmail.text} is deleted');
                    }
                  } else {
                    showToastMessage('the user: ${myEmail.text} is not on the database');
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    deleteUserButtonTextLanguageArray[languageArrayIdentifier],
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
