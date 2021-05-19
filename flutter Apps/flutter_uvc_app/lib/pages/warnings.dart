import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutteruvcapp/services/bleDeviceClass.dart';
import 'package:flutteruvcapp/services/uvcClass.dart';
import 'package:flutteruvcapp/services/uvcToast.dart';

class Warnings extends StatefulWidget {
  @override
  _WarningsState createState() => _WarningsState();
}

class _WarningsState extends State<Warnings> {
  Map warningsClassData = {};

  Device myDevice;
  UvcLight myUvcLight;

  ToastyMessage myUvcToast;

  bool nextButtonPressedOnce = false;

  @override
  Widget build(BuildContext context) {
    warningsClassData = warningsClassData.isNotEmpty ? warningsClassData : ModalRoute.of(context).settings.arguments;
    myDevice = warningsClassData['myDevice'];
    myUvcLight = warningsClassData['myUvcLight'];

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('À lire attentivement'),
          centerTitle: true,
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
                    Container(
                      color: Colors.orange,
                      width: screenWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning,
                            size: screenWidth * 0.1 * screenHeight * 0.002,
                            color: Colors.white,
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Text(
                            'Attention !',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.1 * screenHeight * 0.001,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(flex: 1, child: SizedBox(width: screenWidth * 0.01)),
                        Container(
                          child: Container(
                            width: 40,
                            height: 40,
                            child: Center(
                                child: Text(
                              '1',
                              style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
                            )),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(200),
                            ),
                            color: Colors.blue[300],
                          ),
                        ),
                        Expanded(flex: 1, child: SizedBox(width: screenWidth * 0.01)),
                        Expanded(
                          flex: 9,
                          child: Text(
                            'Sortez de la pièce.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: screenWidth * 0.04),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.025),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Divider(
                        thickness: 1.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(flex: 1, child: SizedBox(width: screenWidth * 0.01)),
                        Container(
                          child: Container(
                            width: 40,
                            height: 40,
                            child: Center(
                                child: Text(
                              '2',
                              style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
                            )),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(200),
                            ),
                            color: Colors.blue[300],
                          ),
                        ),
                        Expanded(flex: 1, child: SizedBox(width: screenWidth * 0.01)),
                        Expanded(
                          flex: 9,
                          child: Text(
                            'Vérifiez qu\'elle soit innocupée.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: screenWidth * 0.04),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.025),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Divider(
                        thickness: 1.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(flex: 1, child: SizedBox(width: screenWidth * 0.01)),
                        Container(
                          child: Container(
                            width: 40,
                            height: 40,
                            child: Center(
                                child: Text(
                              '3',
                              style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
                            )),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(200),
                            ),
                            color: Colors.blue[300],
                          ),
                        ),
                        Expanded(flex: 1, child: SizedBox(width: screenWidth * 0.01)),
                        Expanded(
                          flex: 9,
                          child: Text(
                            'Signalez la désinfection en cours grâce aux accroche-portes et/ou au chevalet.',
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: screenWidth * 0.04),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    //here is the image or gif
                    SizedBox(height: screenHeight * 0.05),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FlatButton(
                          onPressed: () async {
                            if (!nextButtonPressedOnce) {
                              nextButtonPressedOnce = true;
                              final String dataRead = myDevice.getReadCharMessage();
                              try {
                                Map<String, dynamic> dataMap = json.decode(dataRead);
                                int qrCodeSecurity = int.parse(dataMap['security'].toString());
                                if (qrCodeSecurity == 0) {
                                  startScan(context);
                                } else {
                                  String message = 'UVCTreatement : ON';
                                  if (Platform.isIOS) {
                                    await myDevice.writeCharacteristic(0, 0, message);
                                  } else {
                                    await myDevice.writeCharacteristic(2, 0, message);
                                  }
                                  Navigator.pushNamed(context, '/uvc', arguments: {
                                    'uvclight': myUvcLight,
                                    'myDevice': myDevice,
                                  });
                                }
                              } catch (e) {
                                if (myDevice.getConnectionState()) {
                                  startScan(context);
                                } else {
                                  myUvcToast = ToastyMessage(toastContext: context);
                                  myUvcToast.setToastDuration(5);
                                  myUvcToast.setToastMessage('Le dispositif est trop loin ou éteint, merci de vérifier ce dernier');
                                  myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
                                  myDevice.disconnect();
                                  Navigator.pushNamedAndRemoveUntil(context, "/check_permissions", (r) => false);
                                }
                              }
                            }
                          },
                          child: Text(
                            'SUIVANT',
                            style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          color: Colors.blue[400],
                        ),
                        SizedBox(width: screenWidth * 0.09),
                        FlatButton(
                          onPressed: () {
                            myDevice.disconnect();
                            Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
                          },
                          child: Text(
                            'ANNULER',
                            style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          color: Colors.red[400],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      onWillPop: () => exitApp(context),
    );
  }

  Future<bool> exitApp(BuildContext context) async {
    myDevice.disconnect();
    Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
    return true;
  }

  Future<void> startScan(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Scanner le QR code de sécurité.',
              textAlign: TextAlign.center,
            ),
            Image.asset(
              'assets/accessoires_uvc.gif',
              height: screenHeight * 0.3,
              width: screenWidth * 0.8,
            ),
          ],
        ),
        actions: [
          FlatButton(
            child: Text('OK'),
            onPressed: () async {
              Navigator.pop(c, true);
              Navigator.pushNamed(context, '/qr_code_scan', arguments: {
                'myDevice': myDevice,
                'myUvcLight': myUvcLight,
                'qrCodeConnectionOrSecurity': true,
              });
            },
          ),
          FlatButton(
            child: Text('Annuler'),
            onPressed: () {
              Navigator.pop(c, false);
              nextButtonPressedOnce = true;
            },
          ),
        ],
      ),
    );
  }
}
