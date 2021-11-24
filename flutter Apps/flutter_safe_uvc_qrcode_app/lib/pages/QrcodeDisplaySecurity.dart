import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/DataVariables.dart';
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
  EmailDataFile emailDataFile = EmailDataFile();
  bool saveQrCodeData = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myUvcToast = ToastyMessage(toastContext: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              Icons.add,
              color: Colors.white,
            ),
            backgroundColor: Colors.green,
            label: 'Ajouter un autre QR code',
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
            label: 'Envoi par email',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () async {
              SystemChannels.textInput.invokeMethod('TextInput.hide');
              if (!saveQrCodeData) {
                await captureQrCodePNG();
                saveQrCodeData = true;
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
      final file = await new File('${tempDir.path}/securityQrCode.png').create();
      await file.writeAsBytes(pngBytes);
      qrCodeList.add(new FileAttachment(file));
      qrCodeImageList.add(file);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> dataEmailSending() async {
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
                    'Entrez votre adresse e-mail :',
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
                  qrCodeList = [new FileAttachment(File('path'))];
                  qrCodeList.length = 0;
                  qrCodeImageList.length = 0;
                  Navigator.pushNamedAndRemoveUntil(context, "/choose_qr_code", (r) => false);
                } else {
                  myUvcToast.clearAllToast();
                  myUvcToast.setToastDuration(3);
                  myUvcToast.setToastMessage('Votre téléphone n\'est connecté sur internet !');
                  myUvcToast.showToast(Colors.red, Icons.thumb_down, Colors.white);
                }
              },
            ),
            TextButton(
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

  Future<void> displayQrCodeDATA(BuildContext context) async {
    myQrCodes.length = 0;
    listQrCodes.length = 0;
    for (int i = 0; i < qrCodeImageList.length; i++) {
      listQrCodes.add(TableRow(children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Image.file(qrCodeImageList[i], width: 100, height: 100), Text(qrCodeList[i].fileName)])
      ]));
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Vos QRcodes'),
          content: SingleChildScrollView(
            child: Table(
                border: TableBorder.all(color: Colors.black), defaultVerticalAlignment: TableCellVerticalAlignment.middle, children: listQrCodes),
          ),
          actions: [
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await dataEmailSending();
              },
            ),
            TextButton(
              child: Text(
                'Annuler',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
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
          'Veuillez trouver ci-joint le QRcode généré grâce à l\'application QRCODE UVC de DEEPLIGHT®.\n'
          'Cet email est envoyé automatiquement, merci de ne pas y répondre.\n\n'
          'Merci de votre confiance,\n'
          'L\'équipe DEEPLIGHT®.';

    try {
      await send(message, serverSMTPDeepLight);
      myUvcToast.clearAllToast();
      myUvcToast.setToastDuration(3);
      myUvcToast.setToastMessage('E-mail envoyé, vérifiez votre boîte de réception');
      myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
    } on MailerException catch (e) {
      print(e.message);
      myUvcToast.clearAllToast();
      myUvcToast.setToastDuration(3);
      myUvcToast.setToastMessage('E-mail non envoyé, vérifiez votre adresse e-mail');
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