import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:wifiglobalapp/services/aes_cbc_crypt.dart';
import 'package:wifiglobalapp/services/data_variables.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  void scanDevices(BuildContext context) async {
    try {
      //ping to check the network
      /*for (int i = 1; i < 256; i++) {
        try {
          Socket socket = await Socket.connect('192.168.2.$i', port, timeout: const Duration(milliseconds: 100));
          debugPrint('we have good connection => 192.168.2.$i');
          // wait 5 milliseconds
          await Future.delayed(const Duration(milliseconds: 300));
          // .. and close the socket
          socket.close();
          debugPrint('disconnected');
        } catch (e) {
          debugPrint(e.toString());
        }
      }*/

      Socket socket = await Socket.connect('192.168.2.1', port);
      debugPrint('connected');

      final plainText = 'Hello_Testing';

      final key = '12345678901234567890123456789012';
      final iv = '1234567890123456';

      AESCbcCrypt aesCbcCrypt = AESCbcCrypt(key, iv, textString: plainText);

      // listen to the received data event stream
      socket.listen((List<int> message) {
        debugPrint('message received : ${utf8.decode(message)}');
        aesCbcCrypt.setText(utf8.decode(message).toLowerCase());
        aesCbcCrypt.decrypt();
        debugPrint(aesCbcCrypt.getDecryptedText());
      });

      aesCbcCrypt.setText(plainText);

      aesCbcCrypt.encrypt();

      String cryptMessage = aesCbcCrypt.getCrypted16Text();

      debugPrint(cryptMessage);

      aesCbcCrypt.setText(cryptMessage);

      // send crypt message
      socket.add(utf8.encode(cryptMessage));

      // wait 5 seconds
      await Future.delayed(const Duration(seconds: 2));

      // .. and close the socket
      socket.close();
      debugPrint('disconnected');
    } catch (e) {
      debugPrint(e.toString());
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
