import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/DataVariables.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:package_info/package_info.dart';
import 'package:super_easy_permissions/super_easy_permissions.dart';
import 'package:wakelock/wakelock.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> with TickerProviderStateMixin {
  AnimationController controller;

  void checkConnection() async {
    await SuperEasyPermissions.askPermission(Permissions.camera).then((value) {
      if (value) {
        print("permission granted");
        SuperEasyPermissions.askPermission(Permissions.bluetooth);
      } else {
        print("permission denied");
      }
    });

    Future.delayed(Duration(seconds: 5), () async {
      Navigator.pushReplacementNamed(context, '/choose_qr_code');
    });/*

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        Future.delayed(Duration(seconds: 5), () async {
          Navigator.pushReplacementNamed(context, '/choose_qr_code');
        });
      } else {
        Future.delayed(Duration(seconds: 5), () async {
          Navigator.pushReplacementNamed(context, '/check_permissions');
        });
      }
    } on SocketException catch (_) {
      print('not connected');
      Future.delayed(Duration(seconds: 5), () async {
        Navigator.pushReplacementNamed(context, '/check_permissions');
      });
    }*/
    // The following line will enable the Android and iOS wakelock.
    Wakelock.enable();
  }

  @override
  void initState() {
    // TODO: implement initState
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    checkConnection();

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

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    print('width : $screenWidth and height : $screenHeight');
    return Scaffold(
      backgroundColor: Colors.indigo[700],
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(color: Colors.grey[200]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: screenHeight * 0.04),
              Image.asset(
                'assets/delitech-medical-logo.png',
                height: screenHeight * 0.15,
                width: screenWidth * 0.7,
              ),
              SizedBox(height: screenHeight * 0.005),
              Image.asset(
                'assets/texte-qrcode.png',
                height: screenHeight * 0.1,
                width: screenWidth * 0.7,
              ),
              SizedBox(height: screenHeight * 0.02),
              SpinKitCircle(
                color: Color(0xFF20b3a3),
                size: screenHeight * 0.09,
              ),
              SizedBox(height: screenHeight * 0.02),
              Image.asset(
                'assets/logo-qrcode.png',
                height: screenHeight * 0.4,
                width: screenWidth * 1.0,
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Powered by DELITECH Group',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
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
                          color: Colors.black,
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
