import 'dart:io';

import 'package:flutter/material.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  AnimationController controller;

  @override
  void initState() {
    // TODO: implement initState
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );

    if (Platform.isAndroid) {
      print('android');
    }
    if (Platform.isIOS) {
      print('ios');
    }
    if (Platform.isWindows) {
      print('windows');
    }
    if (Platform.isLinux) {
      print('linux');
    }
    if (Platform.isMacOS) {
      print('macos');
    }

    Future.delayed(Duration(seconds: 5), () async {
      Navigator.pushReplacementNamed(context, '/bluetooth_activation');
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    print('width : $screenWidth and height : $screenHeight');
    return Scaffold(
      backgroundColor: Colors.indigo[700],
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/fondapplication.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/logo_uv_c.png',
                height: screenHeight * 0.15,
                width: screenWidth * 0.7,
              ),
              SizedBox(height: screenHeight * 0.02),
              Image.asset(
                'assets/logo_deeplight.png',
                height: screenHeight * 0.15,
                width: screenWidth * 0.7,
              ),
              SizedBox(height: screenHeight * 0.1),
              SpinKitCircle(
                color: Colors.white,
                size: screenHeight * 0.1,
              ),
              SizedBox(height: screenHeight * 0.1),
              Image.asset(
                'assets/logodelitechblanc.png',
                height: screenHeight * 0.15,
                width: screenWidth * 0.7,
              ),
              SizedBox(height: screenHeight * 0.05),
              Text(
                'Powered by DELITECH Group',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: screenWidth * 0.04,
                ),
              ),
              FutureBuilder(
                  future: PackageInfo.fromPlatform(),
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.hasData) {
                      String version = snapshot.data.version;
                      return Center(
                          child: Text(
                            '$version',
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: screenWidth * 0.04,
                            ),
                          ));
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
