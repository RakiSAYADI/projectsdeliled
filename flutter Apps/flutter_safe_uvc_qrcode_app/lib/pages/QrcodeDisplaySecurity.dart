import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/EMAILfileClass.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/uvcToast.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeDisplaySecurity extends StatefulWidget {
  @override
  _QrCodeDisplaySecurityState createState() => _QrCodeDisplaySecurityState();
}

class _QrCodeDisplaySecurityState extends State<QrCodeDisplaySecurity> {
  ToastyMessage myUvcToast;
  GlobalKey globalKey = new GlobalKey();
  List<Attachment> qrCodeList = [new FileAttachment(File('path'))];
  EmailDataFile emailDataFile = EmailDataFile();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myUvcToast = ToastyMessage(toastContext: context);
    qrCodeList.length = 0;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => stopActivity(context),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[400],
          centerTitle: true,
          title: Text('Votre QR code'),
        ),
        body: Container(
          decoration: BoxDecoration(color: Colors.grey[200]),
          child: Center(
            child: SingleChildScrollView(
              child: RepaintBoundary(
                key: globalKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/delitech.png',
                    ),
                    QrImage(
                      data: 'https://qrgo.page.link/hYgXu',
                    ),
                    Container(
                      alignment: Alignment.bottomCenter, // align the row
                      padding: EdgeInsets.all(16.0),
                      child: Text('QrCode de Sécurité'),
                    ),
                    Image.asset(
                      'assets/texte-deeplight.png',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: SpeedDial(
          // both default to 16
          marginRight: 18,
          marginBottom: 20,
          animatedIcon: AnimatedIcons.menu_close,
          animatedIconTheme: IconThemeData(size: 22.0),
          // this is ignored if animatedIcon is non null
          // child: Icon(Icons.add),

          // If true user is forced to close dial manually
          // by tapping main button and overlay is not rendered.
          closeManually: false,
          curve: Curves.bounceIn,
          overlayColor: Colors.black,
          overlayOpacity: 0.5,
/*          onOpen: () => print('OPENING DIAL'),
          onClose: () => print('DIAL CLOSED'),*/
          tooltip: 'Menu',
/*          heroTag: 'speed-dial-hero-tag',*/
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 8.0,
          shape: CircleBorder(),
          children: [
            SpeedDialChild(
              child: Icon(
                Icons.send,
                color: Colors.white,
              ),
              backgroundColor: Colors.blue,
              label: 'Envoi par email',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () async {
                SystemChannels.textInput.invokeMethod('TextInput.hide');
                await captureQrCodePNG();
                await dataEmailSending(context);
              },
            ),
          ],
        ),
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
      final file = await new File('${tempDir.path}/securityQrCode').create();
      await file.writeAsBytes(pngBytes);
      qrCodeList.add(new FileAttachment(file));
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
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Entrer votre Adresse Email :',
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
            FlatButton(
              child: Text(
                'Envoyer',
                style: TextStyle(fontSize: (widthScreen * 0.05)),
              ),
              onPressed: () async {
                Navigator.pop(context, false);
                SystemChannels.textInput.invokeMethod('TextInput.hide');
                await emailDataFile.saveStringUVCEmailDATA(myEmail.text);
                myUvcToast.setToastDuration(60);
                myUvcToast.setToastMessage('Envoi en cours !');
                myUvcToast.showToast(Colors.green, Icons.send, Colors.white);
                if (await checkInternetConnection()) {
                  await sendEmail(myEmail.text);
                  Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
                } else {
                  myUvcToast.clearAllToast();
                  myUvcToast.setToastDuration(3);
                  myUvcToast.setToastMessage('Votre téléphone n\'est connecté sur internet !');
                  myUvcToast.showToast(Colors.red, Icons.thumb_down, Colors.white);
                }
              },
            ),
            FlatButton(
              child: Text(
                'Annuler',
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
      ..subject = 'Votre QR code'
      ..attachments = qrCodeList
      ..text = 'Bonjour,\n\n'
          'Veuillez trouver ci-joint le QRcode généré grâce à l\'application QRCODE UVC de DeliTech Medical®.\n'
          'Cet email est envoyé automatiquement, merci de ne pas y répondre.\n\n'
          'Merci de votre confiance,\n'
          'L\'équipe DeliTech Medical.';

    try {
      await send(message, serverSMTPDeepLight);
      myUvcToast.clearAllToast();
      myUvcToast.setToastDuration(3);
      myUvcToast.setToastMessage('Email bien envoyé , Verifier votre boite de reception !');
      myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
    } on MailerException catch (e) {
      print(e.message);
      myUvcToast.clearAllToast();
      myUvcToast.setToastDuration(3);
      myUvcToast.setToastMessage('Email n\'est pas envoyé , Verifier votre addresse email !');
      myUvcToast.showToast(Colors.red, Icons.thumb_down, Colors.white);
    }
  }

  Future<void> stopActivity(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Attention'),
        content: Text('Voulez-vous vraiment quitter l\'application ?'),
        actions: [
          FlatButton(
            child: Text('Oui'),
            onPressed: () {
              Navigator.pop(c, true);
            },
          ),
          FlatButton(
            child: Text('Non'),
            onPressed: () => Navigator.pop(c, false),
          ),
        ],
      ),
    );
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
