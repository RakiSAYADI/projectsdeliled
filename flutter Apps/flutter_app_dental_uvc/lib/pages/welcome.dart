import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterappdentaluvc/services/LEDControl.dart';
import 'package:package_info/package_info.dart';
import 'package:wakelock/wakelock.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> with TickerProviderStateMixin {
  AnimationController controller;

  LedControl ledControl;

  void ledInit() async {
    ledControl = LedControl();
    await ledControl.setLedColor('ON');
    await ledControl.setLedColor('GREEN');
  }

  void wakeLock() async {
    Wakelock.enable();
    bool wakelockEnabled = await Wakelock.enabled;
    if (wakelockEnabled) {
      // The following statement disables the wakelock.
      Wakelock.toggle(enable: false);
    }
    print('screen lock is disabled');
  }

  @override
  void initState() {
    // TODO: implement initState
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    wakeLock();

    ledInit();

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
      Navigator.pushReplacementNamed(context, '/pin_access');
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    print('width : $widthScreen and height : $heightScreen');
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
                height: heightScreen * 0.15,
                width: widthScreen * 0.7,
              ),
              SizedBox(height: heightScreen * 0.02),
              Image.asset(
                'assets/logo_deeplight.png',
                height: heightScreen * 0.15,
                width: widthScreen * 0.7,
              ),
              SizedBox(height: heightScreen * 0.05),
              SpinKitCircle(
                color: Colors.white,
                size: heightScreen * 0.1,
              ),
              SizedBox(height: heightScreen * 0.05),
              Image.asset(
                'assets/logodelitechblanc.png',
                height: heightScreen * 0.15,
                width: widthScreen * 0.7,
              ),
              SizedBox(height: heightScreen * 0.05),
              Text(
                'Powered by DELITECH Group',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: widthScreen * 0.02,
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
                          fontSize: widthScreen * 0.02,
                        ),
                      ),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
