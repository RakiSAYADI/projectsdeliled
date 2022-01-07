import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

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
                        child: Text(myRoomNameText),
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
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () async {
              SystemChannels.textInput.invokeMethod('TextInput.hide');
              await captureQrCodePNG();
              Navigator.pushNamedAndRemoveUntil(context, "/choose_qr_code", (r) => false);
            },
          ),
          SpeedDialChild(
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
            backgroundColor: Colors.blue,
            label: sendEmailButtonTextLanguageArray[languageArrayIdentifier],
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () async {
              SystemChannels.textInput.invokeMethod('TextInput.hide');
              dataEmailSending(context);
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
