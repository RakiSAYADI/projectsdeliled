import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutteruvcapp/services/DataVariables.dart';
import 'package:flutteruvcapp/services/languageDataBase.dart';
import 'package:flutteruvcapp/services/uvcToast.dart';

class Warnings extends StatefulWidget {
  @override
  _WarningsState createState() => _WarningsState();
}

class _WarningsState extends State<Warnings> {
  ToastyMessage myUvcToast;

  bool nextButtonPressedOnce = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(readBeforeUseTitleTextLanguageArray[languageArrayIdentifier]),
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
                            '${attentionTextLanguageArray[languageArrayIdentifier]} !',
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
                            ruleNumberOneTextLanguageArray[languageArrayIdentifier],
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
                            ruleNumberTwoTextLanguageArray[languageArrayIdentifier],
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
                            ruleNumberThreeTextLanguageArray[languageArrayIdentifier],
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
                        TextButton(
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
                                  Navigator.pushNamed(context, '/uvc');
                                }
                              } catch (e) {
                                if (myDevice.getConnectionState()) {
                                  startScan(context);
                                } else {
                                  myUvcToast = ToastyMessage(toastContext: context);
                                  myUvcToast.setToastDuration(5);
                                  myUvcToast.setToastMessage(deviceOutOfReachTextLanguageArray[languageArrayIdentifier]);
                                  myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
                                  myDevice.disconnect();
                                  Navigator.pushNamedAndRemoveUntil(context, "/check_permissions", (r) => false);
                                }
                              }
                            }
                          },
                          child: Text(
                            nextButtonTextLanguageArray[languageArrayIdentifier],
                            style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
                          ),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[400]),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.09),
                        TextButton(
                          onPressed: () {
                            if (startWithOutSettings) {
                              myDevice.disconnect();
                              Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
                            } else {
                              Navigator.pop(context, false);
                            }
                          },
                          child: Text(
                            cancelTextLanguageArray[languageArrayIdentifier],
                            style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
                          ),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.red[400]),
                          ),
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
    if (startWithOutSettings) {
      myDevice.disconnect();
      Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
    } else {
      Navigator.pop(context, false);
    }
    return true;
  }

  Future<void> startScan(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    nextButtonPressedOnce = false;
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              scanSecurityQrCodeTextLanguageArray[languageArrayIdentifier],
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
          TextButton(
            child: Text(okTextLanguageArray[languageArrayIdentifier]),
            onPressed: () async {
              Navigator.pop(c, true);
              qrCodeConnectionOrSecurity = true;
              Navigator.pushNamed(context, '/qr_code_scan');
            },
          ),
          TextButton(
            child: Text(cancelTextLanguageArray[languageArrayIdentifier]),
            onPressed: () {
              Navigator.pop(c, false);
            },
          ),
        ],
      ),
    );
  }
}
