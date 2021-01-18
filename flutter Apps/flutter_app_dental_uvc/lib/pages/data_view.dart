import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterappdentaluvc/services/CSVfileClass.dart';
import 'package:flutterappdentaluvc/services/httpRequests.dart';
import 'package:flutterappdentaluvc/services/uvcClass.dart';
import 'package:flutterappdentaluvc/services/uvcToast.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:path_provider/path_provider.dart';

class DataCSVView extends StatefulWidget {
  @override
  _DataCSVViewState createState() => _DataCSVViewState();
}

class _DataCSVViewState extends State<DataCSVView> {
  Map endUVCClassData = {};
  List<List<String>> uvcData;

  bool isTreatmentCompleted;
  UvcLight myUvcLight;

  ToastyMessage myUvcToast;

  final String _uvcDataFileName = 'RapportUVC.csv';

  UVCDataFile uvcDataFile;
  String userEmail;

  DataBaseRequests dataBaseRequests = DataBaseRequests();

  bool firstDisplayMainWidget = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myUvcToast = ToastyMessage(toastContext: context);
  }

  void readUserEmailFile() async {
    if (firstDisplayMainWidget) {
      firstDisplayMainWidget = false;
      uvcDataFile = UVCDataFile();
      userEmail = await uvcDataFile.readUserEmailDATA();
    }
  }

  @override
  Widget build(BuildContext context) {
    endUVCClassData = endUVCClassData.isNotEmpty ? endUVCClassData : ModalRoute.of(context).settings.arguments;
    isTreatmentCompleted = endUVCClassData['isTreatmentCompleted'];
    myUvcLight = endUVCClassData['myUvcLight'];
    uvcData = endUVCClassData['uvcData'];

    readUserEmailFile();

    double widthScreen = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('rapport CSV'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: SingleChildScrollView(
          child: Table(
            border: TableBorder.all(width: 2.0),
            children: uvcData.map((item) {
              return TableRow(
                  children: item.map((row) {
                return Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      row.toString(),
                      style: TextStyle(
                        fontSize: widthScreen * 0.015,
                      ),
                    ),
                  ),
                );
              }).toList());
            }).toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => dataEmailSending(context),
        label: Text('Envoi'),
        icon: Icon(
          Icons.send,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue[400],
      ),
    );
  }

  Future<void> dataEmailSending(BuildContext context) async {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    final myEmail = TextEditingController();
    userEmail = await uvcDataFile.readUserEmailDATA();
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
                    style: TextStyle(fontSize: (widthScreen * 0.02)),
                  ),
                  SizedBox(height: heightScreen * 0.005),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: (widthScreen * 0.02)),
                    child: TextField(
                      style: TextStyle(fontSize: (widthScreen * 0.017)),
                      textAlign: TextAlign.center,
                      controller: myEmail,
                      maxLines: 1,
                      decoration: InputDecoration(
                          hintText: 'user@exemple.fr',
                          hintStyle: TextStyle(
                            fontSize: (widthScreen * 0.02),
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
                style: TextStyle(fontSize: (widthScreen * 0.02)),
              ),
              onPressed: () async {
                Navigator.pop(context, false);
                await uvcDataFile.saveStringUVCEmailDATA(myEmail.text);
                if (await dataBaseRequests.checkConnection()) {
                  myUvcToast.setToastDuration(60);
                  myUvcToast.setToastMessage('Envoi en cours !');
                  myUvcToast.showToast(Colors.green, Icons.send, Colors.white);
                  await sendEmail(myEmail.text);
                } else {
                  myUvcToast.setToastDuration(3);
                  myUvcToast.setToastMessage('Veuillez connecter votre tablette sur internet !');
                  myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
                }
              },
            ),
            FlatButton(
              child: Text(
                'Annuler',
                style: TextStyle(fontSize: (widthScreen * 0.02)),
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
