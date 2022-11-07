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

  bool registerVisibility = false;

  int counterRegisterVisibility = 0;

  @override
  void dispose() {
    // TODO: implement dispose
    myEmail.dispose();
    super.dispose();
  }

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
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    fontSize: (screenWidth * 0.05),
                  ),
                  onSubmitted: (value) async {
                    if (appClass.getUsersEmail().contains(value)) {
                      int pos = appClass.getUsersEmail().indexOf(value);
                      await appClass.users[pos].getUniverses();
                      userIdentifier = appClass.users.indexOf(appClass.users[pos]);
                      if (!requestResponse) {
                        showToastMessage('Error request');
                      } else {
                        Navigator.pushNamed(context, '/universe_list');
                      }
                    } else {
                      showToastMessage('the user: $value is not registered');
                      counterRegisterVisibility++;
                      if (counterRegisterVisibility == 5) {
                        registerVisibility = true;
                        setState(() {});
                      }
                    }
                  },
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
                    await appClass.users[pos].getUniverses();
                    userIdentifier = appClass.users.indexOf(appClass.users[pos]);
                    if (!requestResponse) {
                      showToastMessage('Error request');
                    } else {
                      Navigator.pushNamed(context, '/universe_list');
                    }
                  } else {
                    showToastMessage('the user: ${myEmail.text} is not registered');
                    counterRegisterVisibility++;
                    if (counterRegisterVisibility == 5) {
                      registerVisibility = true;
                      setState(() {});
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    connectUserButtonTextLanguageArray[languageArrayIdentifier],
                    style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.02 + screenHeight * 0.02),
                  ),
                ),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(60.0))),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                ),
              ),
              SizedBox(height: screenHeight * 0.1),
              AnimatedOpacity(
                opacity: registerVisibility ? 1.0 : 0.0,
                duration: const Duration(seconds: 1),
                curve: Curves.ease,
                child: Visibility(
                  visible: registerVisibility,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/user_delete');
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
                      SizedBox(width: screenWidth * 0.05),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/user_create');
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            registerUserButtonTextLanguageArray[languageArrayIdentifier],
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
            ],
          ),
        ),
      ),
    );
  }
}
