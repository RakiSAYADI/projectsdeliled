import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_ambimaestro/pages/check_permissions.dart';
import 'package:flutter_app_ambimaestro/pages/scan_ble_list.dart';
import 'package:flutter_app_ambimaestro/services/animation_between_pages.dart';
import 'package:flutter_app_ambimaestro/services/data_variables.dart';
import 'package:flutter_app_ambimaestro/services/language_data_base.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:package_info/package_info.dart';
import 'package:super_easy_permissions/super_easy_permissions.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  String version = '';

  @override
  void initState() {
    // TODO: implement initState
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
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

    checkPermissions();

    flutterBlue.state.listen((state) {
      if (state == BluetoothState.off) {
        //Alert user to turn on bluetooth.
        debugPrint("Bluetooth is off");
        Future.delayed(const Duration(seconds: 5), () {
          createReplacementRoute(context, const CheckPermissions());
        });
      } else if (state == BluetoothState.on) {
        //if bluetooth is enabled then go ahead.
        //Make sure user's device gps is on.
        flutterBlue = FlutterBlue.instance;
        debugPrint("Bluetooth is on");
        Future.delayed(const Duration(seconds: 5), () {
          createReplacementRoute(context, const ScanListBle());
        });
      }
    });
    super.initState();
  }

  void checkPermissions() async {
    await SuperEasyPermissions.askPermission(Permissions.locationWhenInUse).then((value) {
      if (value) {
        debugPrint("permission granted");
        SuperEasyPermissions.askPermission(Permissions.locationAlways).then((value) {
          SuperEasyPermissions.askPermission(Permissions.bluetooth);
        });
      } else {
        debugPrint("permission denied");
      }
    });
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    try {
      setState(() {
        version = packageInfo.version;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
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
              flex: 9,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/ic_launcher.png',
                  height: heightScreen * 0.15,
                  width: widthScreen * 0.3,
                ),
              ),
            ),
            Expanded(
              flex: 3,
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
                      height: heightScreen * 0.15,
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
                          fontSize: widthScreen * 0.05,
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
                    fontSize: widthScreen * 0.04,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Center(
                  child: Text(
                    'V$version',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: widthScreen * 0.04,
                    ),
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
