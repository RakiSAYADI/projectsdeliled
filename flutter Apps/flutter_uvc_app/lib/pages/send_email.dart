import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutteruvcapp/services/CSVfileClass.dart';
import 'package:flutteruvcapp/services/uvcClass.dart';
import 'package:flutteruvcapp/services/uvcToast.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:path_provider/path_provider.dart';

class SendEmail extends StatefulWidget {
  @override
  _SendEmailState createState() => _SendEmailState();
}

class _SendEmailState extends State<SendEmail> {
  ToastyMessage myUvcToast;

  Map sendEmailClassData = {};

  final String _uvcDataFileName = 'RapportUVC.csv';

  final myEmail = TextEditingController();

  List<List<String>> uvcData;

  bool isTreatmentCompleted;
  UvcLight myUvcLight;

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
    sendEmailClassData = sendEmailClassData.isNotEmpty ? sendEmailClassData : ModalRoute.of(context).settings.arguments;
    isTreatmentCompleted = sendEmailClassData['isTreatmentCompleted'];
    myUvcLight = sendEmailClassData['myUvcLight'];
    uvcData = sendEmailClassData['uvcData'];

    readUserEmailFile();

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      child: Scaffold(
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
                        'Entrer votre Adresse Email :',
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
      ),
      onWillPop: () => exitApp(context),
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
      ..from = Address(username, 'DEEPLIGHT')
      ..recipients.add(destination)
      ..subject = 'Rapport de désinfection UV-C - DEEPLIGHT'
      ..attachments.add(new FileAttachment(File('${directory.path}/$_uvcDataFileName')))
      ..text = 'Bonjour,\n\n'
          'Vous trouverez ci-joint le rapport concernant la désinfection éffectuée à l’aide de'
          ' votre solution de désinfection DEEPLIGHT® de DeliTech Medical®.\n\n'
          'Merci de votre confiance.';

    try {
      await send(message, serverSMTPDeepLight);
      myUvcToast.clearAllToast();
      myUvcToast.setToastDuration(3);
      myUvcToast.setToastMessage('Email bien envoyé , Verifier votre boite de reception !');
      myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
    } on MailerException catch (e) {
      myUvcToast.clearAllToast();
      myUvcToast.setToastDuration(3);
      myUvcToast.setToastMessage('Email n\'est pas envoyé , Verifier votre addresse email !');
      myUvcToast.showToast(Colors.red, Icons.thumb_down, Colors.white);
    }
  }

  Future<bool> exitApp(BuildContext context) async {
    Navigator.pushNamedAndRemoveUntil(context, "/DataCSVView", (r) => false, arguments: {
      'isTreatmentCompleted': isTreatmentCompleted,
      'myUvcLight': myUvcLight,
      'uvcData': uvcData,
    });
    return true;
  }
}
