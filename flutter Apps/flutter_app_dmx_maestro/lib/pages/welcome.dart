import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:package_info/package_info.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  String appName;
  String appPackageName;
  String appVersion;
  String appBuildNumber;

  FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  void initState() {
    // TODO: implement initState
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.initState();
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

    gettingAppInfo();

    flutterBlue.state.listen((state) {
      if (state == BluetoothState.off) {
        //Alert user to turn on bluetooth.
        print("Bluetooth is off");
        Future.delayed(Duration(seconds: 5), () {
          Navigator.pushReplacementNamed(context, '/check_permissions');
        });
      } else if (state == BluetoothState.on) {
        //if bluetooth is enabled then go ahead.
        //Make sure user's device gps is on.
        flutterBlue = FlutterBlue.instance;
        print("Bluetooth is on");
        Future.delayed(Duration(seconds: 5), () {
          Navigator.pushReplacementNamed(context, '/scan_ble_list');
        });
      }
    });
  }

  void gettingAppInfo() async {
    await PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      appName = packageInfo.appName;
      appPackageName = packageInfo.packageName;
      appVersion = packageInfo.version;
      appBuildNumber = packageInfo.buildNumber;
    });
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
              Expanded(
                flex: 9,
                child: Image.asset(
                  'assets/ic_launcher_App.png',
                  key: Key('app_logo'),
                  height: screenHeight * 0.15,
                  width: screenWidth * 0.3,
                ),
              ),
              Expanded(
                flex: 3,
                child: SpinKitCircle(
                  key: Key('loader'),
                  color: Colors.white,
                  size: 100.0,
                ),
              ),
              Expanded(
                flex: 3,
                child: Image.asset(
                  'assets/logodelitechblanc.png',
                  key: Key('delitech_logo'),
                  height: screenHeight * 0.15,
                  width: screenWidth * 0.7,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Powered by DELITECH Group',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: screenWidth * 0.04,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: FutureBuilder(
                    key: Key('app_version'),
                    future: PackageInfo.fromPlatform(),
                    builder: (BuildContext context, snapshot) {
                      if (snapshot.hasData) {
                        String version = snapshot.data.version;
                        return Center(
                            child: Text(
                          'V$version',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
