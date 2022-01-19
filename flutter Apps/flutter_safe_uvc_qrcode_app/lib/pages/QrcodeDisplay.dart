import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/DataVariables.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/EMAILfileClass.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/languageDataBase.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/uvcToast.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:super_easy_permissions/super_easy_permissions.dart';

class QrCodeDisplay extends StatefulWidget {
  @override
  _QrCodeDisplayState createState() => _QrCodeDisplayState();
}

class _QrCodeDisplayState extends State<QrCodeDisplay> {
  final GlobalKey globalKey = new GlobalKey();
  ToastyMessage myUvcToast;
  final EmailDataFile emailDataFile = EmailDataFile();
  String deepLightText = 'assets/texte-deeplight.png';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myUvcToast = ToastyMessage(toastContext: context);
    switch (languageArrayIdentifier) {
      case 0:
        deepLightText = 'assets/texte-deeplight.png';
        break;
      case 1:
        deepLightText = 'assets/texte-en-deeplight.png';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        centerTitle: true,
        title: Text(myQRCodeTitleTextLanguageArray[languageArrayIdentifier]),
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Center(
          child: SingleChildScrollView(
            child: RepaintBoundary(
              key: globalKey,
              child: Container(
                decoration: BoxDecoration(color: Colors.white),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/delitech.png',
                      ),
                      QrImage(
                        data: qrCodeData,
                      ),
                      Container(
                        alignment: Alignment.bottomCenter, // align the row
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          qrCodeDataName,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.035 + screenHeight * 0.0035,
                          ),
                        ),
                      ),
                      Image.asset(
                        deepLightText,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: SpeedDial(
        marginRight: 18,
        marginBottom: 20,
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        tooltip: menuTextLanguageArray[languageArrayIdentifier],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
            backgroundColor: Colors.green,
            label: addQrCodeButtonTextLanguageArray[languageArrayIdentifier],
            labelStyle: TextStyle(fontSize: screenWidth * 0.03 + screenHeight * 0.002),
            onTap: () async {
              SystemChannels.textInput.invokeMethod('TextInput.hide');
              if (saveToPrint) {
                await captureQrCodePNG();
                saveToPrint = false;
              }
              Navigator.pushNamedAndRemoveUntil(context, "/choose_qr_code", (r) => false);
            },
          ),
          SpeedDialChild(
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
            backgroundColor: Colors.red,
            label: sendEmailButtonTextLanguageArray[languageArrayIdentifier],
            labelStyle: TextStyle(fontSize: screenWidth * 0.03 + screenHeight * 0.002),
            onTap: () async {
              SystemChannels.textInput.invokeMethod('TextInput.hide');
              dataEmailSending(context);
            },
          ),
          SpeedDialChild(
            child: Icon(
              Icons.print,
              color: Colors.white,
            ),
            backgroundColor: Colors.blue,
            label: printTextLanguageArray[languageArrayIdentifier],
            labelStyle: TextStyle(fontSize: screenWidth * 0.03 + screenHeight * 0.002),
            onTap: () async {
              if (saveToPrint) {
                await captureQrCodePNG();
                saveToPrint = false;
              }
              await displayQrCodeDATA(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> captureQrCodePNG() async {
    try {
      RenderRepaintBoundary boundary = globalKey.currentContext.findRenderObject();
      var image = await boundary.toImage();
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = await new File('${tempDir.path}/$qrCodeFileName').create();
      await file.writeAsBytes(pngBytes);
      qrCodeList.add(new FileAttachment(file));
      qrCodeImageList.add(file);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> dataEmailSending(BuildContext context) async {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    final myEmail = TextEditingController();
    String userEmail = await emailDataFile.readUserEmailDATA();
    myEmail.text = userEmail;
    return showDialog<void>(
      context: context,
      builder: (BuildContext c) {
        return AlertDialog(
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    enterEmailTextLanguageArray[languageArrayIdentifier],
                    style: TextStyle(fontSize: (widthScreen * 0.05)),
                  ),
                  SizedBox(height: heightScreen * 0.05),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: (widthScreen * 0.05)),
                    child: TextField(
                      style: TextStyle(fontSize: (widthScreen * 0.05)),
                      textAlign: TextAlign.center,
                      controller: myEmail,
                      maxLines: 1,
                      decoration: InputDecoration(
                          hintText: 'user@exemple.fr',
                          hintStyle: TextStyle(
                            fontSize: (widthScreen * 0.05),
                            color: Colors.grey,
                          )),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                sendTextLanguageArray[languageArrayIdentifier],
                style: TextStyle(fontSize: (widthScreen * 0.05)),
              ),
              onPressed: () async {
                if (myEmail.text.isNotEmpty &&
                    RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$").hasMatch(myEmail.text)) {
                  Navigator.pop(context, false);
                  await captureQrCodePNG();
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                  await emailDataFile.saveStringUVCEmailDATA(myEmail.text);
                  myUvcToast.setToastDuration(60);
                  myUvcToast.setToastMessage(sendProgressToastTextLanguageArray[languageArrayIdentifier]);
                  myUvcToast.showToast(Colors.green, Icons.send, Colors.white);
                  if (await checkInternetConnection()) {
                    await sendEmail(myEmail.text);
                    qrCodeList.clear();
                    qrCodeImageList.length = 0;
                    Navigator.pushNamedAndRemoveUntil(context, "/choose_qr_code", (r) => false);
                  } else {
                    myUvcToast.clearAllToast();
                    myUvcToast.setToastDuration(3);
                    myUvcToast.setToastMessage(noConnectionToastTextLanguageArray[languageArrayIdentifier]);
                    myUvcToast.showToast(Colors.red, Icons.thumb_down, Colors.white);
                  }
                } else {
                  myUvcToast.setToastDuration(10);
                  myUvcToast.setToastMessage(emailAddressNonValidToastTextLanguageArray[languageArrayIdentifier]);
                  myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
                }
              },
            ),
            TextButton(
              child: Text(
                cancelTextLanguageArray[languageArrayIdentifier],
                style: TextStyle(fontSize: (widthScreen * 0.05)),
              ),
              onPressed: () {
                myEmail.text = '';
                Navigator.pop(context, false);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> sendEmail(String destination) async {
    String host = 'smtp.office365.com';
    String username = 'rapports-deeplight@delitech.eu';
    String password = 'Ven34Dar20*';
    // Server SMTP
    final serverSMTPDeepLight = SmtpServer(host, username: username, password: password);
    // Create our message.
    final message = Message()
      ..from = Address(username, 'DeliTech Medical')
      ..recipients.add(destination)
      ..subject = myQRCodeTitleTextLanguageArray[languageArrayIdentifier]
      ..attachments = qrCodeList
      ..text = emailMessageTextLanguageArray[languageArrayIdentifier];

    try {
      await send(message, serverSMTPDeepLight);
      myUvcToast.clearAllToast();
      myUvcToast.setToastDuration(3);
      myUvcToast.setToastMessage(emailSentToastTextLanguageArray[languageArrayIdentifier]);
      myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
    } on MailerException catch (e) {
      print(e.message);
      myUvcToast.clearAllToast();
      myUvcToast.setToastDuration(3);
      myUvcToast.setToastMessage(emailNotSentToastTextLanguageArray[languageArrayIdentifier]);
      myUvcToast.showToast(Colors.red, Icons.thumb_down, Colors.white);
    }
  }

  Future<void> displayQrCodeDATA(BuildContext context) async {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    listQrCodes.clear();
    if (qrCodeImageList.length == 0) {
      myUvcToast.setToastDuration(2);
      myUvcToast.setToastMessage(noFilesToastTextLanguageArray[languageArrayIdentifier]);
      myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
    } else {
      for (int i = 0; i < qrCodeImageList.length; i++) {
        listQrCodes.add(TableRow(children: [
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            RepaintBoundary(child: Image.file(qrCodeImageList[i], width: screenWidth * 0.27, height: screenHeight * 0.14)),
            Text(qrCodeList[i].fileName, textAlign: TextAlign.center),
          ])
        ]));
      }
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(qrCodesAlertDialogTitleLanguageArray[languageArrayIdentifier]),
            content: SingleChildScrollView(
              child: Table(border: TableBorder.all(color: Colors.black), defaultVerticalAlignment: TableCellVerticalAlignment.middle, children: listQrCodes),
            ),
            actions: [
              TextButton(
                child: Text(
                  printBLETextLanguageArray[languageArrayIdentifier],
                  style: TextStyle(color: Colors.green),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await SuperEasyPermissions.askPermission(Permissions.bluetooth);
                  printerBLEOrWIFI = false;
                  Navigator.pushNamed(context, '/scan_list_printers');
                },
              ),
              TextButton(
                child: Text(
                  printWifiTextLanguageArray[languageArrayIdentifier],
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  var connectivityResult = await (Connectivity().checkConnectivity());
                  if (connectivityResult == ConnectivityResult.wifi) {
                    printerBLEOrWIFI = true;
                    Navigator.pushNamed(context, '/scan_list_printers');
                  } else {
                    myUvcToast.setToastDuration(2);
                    myUvcToast.setToastMessage(noWIFIConnectionToastTextLanguageArray[languageArrayIdentifier]);
                    myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
                  }
                },
              ),
              TextButton(
                child: Text(
                  cancelTextLanguageArray[languageArrayIdentifier],
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      print(result);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      print('not connected');
      return false;
    }
  }
}
