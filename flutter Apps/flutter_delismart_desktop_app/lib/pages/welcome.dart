import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {


  @override
  void initState() {
    // TODO: implement initState
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    if (Platform.isAndroid) {
      debugPrint('android');
    }
    if (Platform.isIOS) {
      debugPrint('ios');
    }
    if (Platform.isWindows) {
      debugPrint('windows');
    }
    if (Platform.isLinux) {
      debugPrint('linux');
    }
    if (Platform.isMacOS) {
      debugPrint('macos');
    }

    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/user_list');
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    debugPrint('width : $widthScreen and height : $heightScreen');
    return Scaffold(
      backgroundColor: Colors.indigo[700],
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fond-lumiair-lite.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/ic_launcher.png',
                  height: heightScreen * 0.2,
                  width: widthScreen * 0.7,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  appName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[300],
                    fontSize: widthScreen * 0.03,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: SpinKitCircle(
                color: Colors.white,
                size: heightScreen * 0.1,
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Image.asset(
                      'assets/logo_deeplight.png',
                      height: heightScreen * 0.1,
                      width: widthScreen * 0.7,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        welcomePageMessageLanguageArray[languageArrayIdentifier],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[300],
                          fontSize: widthScreen * 0.03,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  'Powered by DELITECH Group',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: widthScreen * 0.02,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
