import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myUvcToast = ToastyMessage(toastContext: context);
  }

  @override
  Widget build(BuildContext context) {
    endUVCClassData = endUVCClassData.isNotEmpty ? endUVCClassData : ModalRoute.of(context).settings.arguments;
    isTreatmentCompleted = endUVCClassData['isTreatmentCompleted'];
    myUvcLight = endUVCClassData['myUvcLight'];
    uvcData = endUVCClassData['uvcData'];

    return Scaffold(
      appBar: AppBar(
        title: Text('rapport CSV'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: SingleChildScrollView(
          child: Table(
/*            columnWidths: {
              0: FixedColumnWidth(100.0),
              1: FixedColumnWidth(200.0),
            },*/
            border: TableBorder.all(width: 2.0),
            children: uvcData.map((item) {
              return TableRow(
                  children: item.map((row) {
                return Container(
                  //color: row.toString().contains("réussi") ? Colors.green : Colors.red,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      row.toString(),
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.015,
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
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final myEmail = TextEditingController();
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
                    style: TextStyle(fontSize: (screenWidth * 0.02)),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.02)),
                    child: TextField(
                      style: TextStyle(fontSize: (screenWidth * 0.017)),
                      textAlign: TextAlign.center,
                      controller: myEmail,
                      maxLines: 1,
                      decoration: InputDecoration(
                          hintText: 'user@exemple.fr',
                          hintStyle: TextStyle(
                            fontSize: (screenWidth * 0.02),
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
                style: TextStyle(fontSize: (screenWidth * 0.02)),
              ),
              onPressed: () async {
                myUvcToast.setToastDuration(60);
                myUvcToast.setToastMessage('Envoi en cours !');
                myUvcToast.showToast(Colors.green, Icons.send, Colors.white);
                await sendemail(myEmail.text);
                Navigator.pop(context, false);
              },
            ),
            FlatButton(
              child: Text(
                'Annuler',
                style: TextStyle(fontSize: (screenWidth * 0.02)),
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

  Future<void> sendemail(String destination) async {
    final directory = await getApplicationDocumentsDirectory();
    String host = 'smtp.office365.com';
    String username = 'raki.sayadi@delitech.eu';
    String password = 'TunRSayadi2019*';
    // Server SMTP
    final serverSMTPDeepLight = SmtpServer(host, username: username, password: password);
    // Create our message.
    final message = Message()
      ..from = Address('raki.sayadi@delitech.eu', 'DEEPLGHIT')
      ..recipients.add(destination)
      ..subject = 'Rapport de désinfection UV-C - DEEPLIGHT'
      ..attachments.add(new FileAttachment(File('${directory.path}/$_uvcDataFileName'), fileName: 'RapportUVC', contentType: 'test/csv'))
      ..text = 'Bonjour,\n\n'
          'Vous trouverez ci-joint le rapport concernant la désinfection éffectuée à l’aide de'
          ' votre solution de désinfection DEEPLIGHT® de DeliTech Medical®.\n\n'
          'Merci de votre confiance.';

    try {
      final sendReport = await send(message, serverSMTPDeepLight);
      print('Message sent: ' + sendReport.toString());
      myUvcToast.clearAllToast();
      myUvcToast.setToastDuration(3);
      myUvcToast.setToastMessage('Email bien envoyé , Verifier votre boite de reception !');
      myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
    } on MailerException catch (e) {
      print('Message not sent' + e.toString());
      myUvcToast.clearAllToast();
      myUvcToast.setToastDuration(3);
      myUvcToast.setToastMessage('Email n\'est pas envoyé , Verifier votre addresse email !');
      myUvcToast.showToast(Colors.red, Icons.thumb_up, Colors.white);
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
}
