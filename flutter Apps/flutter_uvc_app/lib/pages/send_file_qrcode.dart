import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutteruvcapp/services/CSVfileClass.dart';
import 'package:flutteruvcapp/services/uvcToast.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:path_provider/path_provider.dart';

class SendEmailQrCode extends StatefulWidget {
  @override
  _SendEmailQrCodeState createState() => _SendEmailQrCodeState();
}

class _SendEmailQrCodeState extends State<SendEmailQrCode> {
  ToastyMessage myUvcToast;

  Map sendEmailQrCodeClassData = {};

  final String _uvcDataFileName = 'RapportUVC.csv';

  final myEmail = TextEditingController();

  List<List<String>> uvcData;

  UVCDataFile uvcDataFile;
  String userEmail;

  bool firstDisplayMainWidget = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myUvcToast = ToastyMessage(toastContext: context);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void readUserEmailFile() async {
    if (firstDisplayMainWidget) {
      firstDisplayMainWidget = false;
      uvcDataFile = UVCDataFile();
      userEmail = await uvcDataFile.readUserEmailDATA();
      myEmail.text = userEmail;
    }
  }

  @override
  Widget build(BuildContext context) {
    sendEmailQrCodeClassData = sendEmailQrCodeClassData.isNotEmpty ? sendEmailQrCodeClassData : ModalRoute.of(context).settings.arguments;
    uvcData = sendEmailQrCodeClassData['uvcData'];

    try {
      userEmail = sendEmailQrCodeClassData['userEmail'];
      if (userEmail.isEmpty) {
        print('no email found in qrcode');
      }
    } catch (e) {
      readUserEmailFile();
    }

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('Envoi Rapport'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Entrer votre adresse email :',
                      style: TextStyle(fontSize: (screenWidth * 0.05)),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: myEmail,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: (screenWidth * 0.05),
                        ),
                        decoration: InputDecoration(
                            hintText: 'user@exemple.fr',
                            hintStyle: TextStyle(
                              fontSize: (screenWidth * 0.05),
                              color: Colors.grey,
                            )),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.1),
                    FlatButton(
                      onPressed: () async {
                        await uvcDataFile.saveStringUVCEmailDATA(myEmail.text);
                        myUvcToast.setToastDuration(60);
                        myUvcToast.setToastMessage('Envoi en cours !');
                        myUvcToast.showToast(Colors.green, Icons.send, Colors.white);
                        await sendEmail(myEmail.text);
                      },
                      child: Text(
                        'Envoyer',
                        style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      color: Colors.blue[400],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> sendEmail(String destination) async {
    final directory = await getApplicationDocumentsDirectory();
    String host = 'smtp.office365.com';
    String username = 'rapports-deeplight@delitech.eu';
    String password = 'Ven34Dar20*';
    // Server SMTP
    final serverSMTPDeepLight = SmtpServer(host, username: username, password: password);
    // Create our message.
    final message = Message()
      ..from = Address(username, 'DeliTech Medical')
      ..recipients.add(destination)
      ..subject = 'Rapport de désinfection UVC'
      ..attachments.add(new FileAttachment(File('${directory.path}/$_uvcDataFileName')))
      ..text = 'Bonjour,\n\n'
          'Vous trouverez ci-joint le rapport concernant la désinfection éffectuée à l’aide de'
          ' votre solution de désinfection DEEPLIGHT® de DeliTech Medical®.\n'
          'Cet email est envoyé automatiquement, merci de ne pas y répondre.\n\n'
          'Merci de votre confiance.';

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
}
