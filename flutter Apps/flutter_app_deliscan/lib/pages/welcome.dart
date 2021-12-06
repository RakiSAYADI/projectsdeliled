import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_deliscan/pages/check_permissions.dart';
import 'package:flutter_app_deliscan/pages/qr_code_scan.dart';
import 'package:flutter_app_deliscan/services/animation_between_pages.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {

  void checkPermissions() async {
    await Permission.camera.request();
    await Permission.manageExternalStorage.request();
    await Permission.storage.request();
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        Future.delayed(Duration(seconds: 5), () async {
          createReplacementRoute(context, QrCodeScan());
        });
      } else {
        Future.delayed(Duration(seconds: 5), () async {
          createReplacementRoute(context, CheckPermissions());
        });
      }
    } on SocketException catch (_) {
      print('not connected');
      Future.delayed(Duration(seconds: 5), () async {
        createReplacementRoute(context, CheckPermissions());
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    checkPermissions();

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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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
