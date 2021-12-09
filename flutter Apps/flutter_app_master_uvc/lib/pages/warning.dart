import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_master_uvc/services/DataVariables.dart';
import 'package:flutter_app_master_uvc/services/languageDataBase.dart';
import 'package:url_launcher/url_launcher.dart';

class Warning extends StatefulWidget {
  @override
  _WarningState createState() => _WarningState();
}

class _WarningState extends State<Warning> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(attentionTextLanguageArray[languageArrayIdentifier]),
          centerTitle: true,
          backgroundColor: Color(0xFF554c9a),
        ),
        body: Container(
          decoration: BoxDecoration(color: Colors.grey[200]),
          child: Container(
            width: screenWidth,
            height: screenHeight,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: screenHeight * 0.02),
                    Icon(
                      Icons.warning,
                      size: screenHeight * 0.1,
                      color: Colors.red,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                color: Colors.black,
                              ),
                              text: warningMessageTextLanguageArray[languageArrayIdentifier],
                            ),
                            TextSpan(
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: screenWidth * 0.05,
                              ),
                              text: warningLinkTextLanguageArray[languageArrayIdentifier],
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  final url = 'https://www.deeplight.fr/contact/';
                                  if (await canLaunch(url)) {
                                    await launch(
                                      url,
                                      forceSafariVC: false,
                                    );
                                  }
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 30),
                      child: TextButton(
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'OK',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.06),
                          ),
                        ),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[400]),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      onWillPop: () => restartApp(context),
    );
  }

  Future<bool> restartApp(BuildContext context) async {
    Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
    return true;
  }
}
