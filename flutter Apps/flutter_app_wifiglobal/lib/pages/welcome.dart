import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:wifiglobalapp/services/data_variables.dart';
import 'package:wifiglobalapp/services/uvc_toast.dart';
import 'package:wifiglobalapp/services/wifi_tcp.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  ToastyMessage toastyMessage = ToastyMessage();

  void scanDevices(BuildContext context) async {
    toastyMessage.setContext(context);
    toastyMessage.setToastDuration(5);
    TCPScan _tcpScan = TCPScan();
    if (await _tcpScan.checkWifiConnection()) {
      await _tcpScan.scanTCP(noAllScan: true);
      if (_tcpScan.getScanList().isNotEmpty) {
        toastyMessage.setToastMessage('des appareils DELILED trouvées dans le réseau');
        toastyMessage.showToast(Colors.green, Icons.thumb_up, Colors.white);
        myDevice = _tcpScan.selectDevice(0);
        await myDevice.getDeviceData();
        await myDevice.setDeviceTime();
      } else {
        toastyMessage.setToastMessage('aucune appareils trouvées dans le réseau');
        toastyMessage.showToast(Colors.red, Icons.thumb_down, Colors.white);
      }
    } else {
      toastyMessage.setToastMessage('Application n\'est pas connectée avec une modem WIFI');
      toastyMessage.showToast(Colors.red, Icons.thumb_down, Colors.white);
    }

    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/pin_access');
    });
  }

  @override
  void initState() {
    // TODO: implement initState

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

    scanDevices(context);

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
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/fondapplication.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Image.asset(
                  'assets/ic_launcher_App.png',
                  height: heightScreen * 0.2,
                  width: widthScreen * 0.7,
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
                          '',
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
      ),
    );
  }
}
