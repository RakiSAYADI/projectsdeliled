import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterappdentaluvc/services/CSVfileClass.dart';
import 'package:flutterappdentaluvc/services/DataVariables.dart';
import 'package:flutterappdentaluvc/services/httpRequests.dart';
import 'package:flutterappdentaluvc/services/languageDataBase.dart';
import 'package:flutterappdentaluvc/services/uvcToast.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:path_provider/path_provider.dart';

class DataCSVSettingsView extends StatefulWidget {
  @override
  _DataCSVSettingsViewState createState() => _DataCSVSettingsViewState();
}

class _DataCSVSettingsViewState extends State<DataCSVSettingsView> {
  ToastyMessage myUvcToast;

  //final String _uvcDataFileName = 'RapportUVC.csv';
  final String _uvcDataSelectedFileName = 'RapportDataUVC.csv';

  DataBaseRequests dataBaseRequests = DataBaseRequests();

  UVCDataFile uvcDataFile;
  String userEmail;

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
    double widthScreen = MediaQuery.of(context).size.width;

    readUserEmailFile();

    return Scaffold(
      appBar: AppBar(
        title: Text(uvcReportTitleTextLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
      ),
      body: InteractiveViewer(
        child: Container(
          decoration: BoxDecoration(color: Colors.grey[200]),
          child: SingleChildScrollView(
            child: Table(
              border: TableBorder.all(width: 2.0),
              children: uvcDataSelected.map((item) {
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => dataEmailSending(context),
        label: Text(mailTextLanguageArray[languageArrayIdentifier]),
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
                    enterEmailAddressTextLanguageArray[languageArrayIdentifier],
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
            TextButton(
              child: Text(
                sendTextLanguageArray[languageArrayIdentifier],
                style: TextStyle(fontSize: (widthScreen * 0.02)),
              ),
              onPressed: () async {
                if (myEmail.text.isNotEmpty &&
                    RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$").hasMatch(myEmail.text)) {
                  await uvcDataFile.saveStringUVCEmailDATA(myEmail.text);
                  if (await dataBaseRequests.checkConnection()) {
                    uvcDataFile.saveUVCDATASelected(uvcDataSelected);
                    myUvcToast.setToastDuration(60);
                    myUvcToast.setToastMessage(sendingProgressToastTextLanguageArray[languageArrayIdentifier]);
                    myUvcToast.showToast(Colors.green, Icons.send, Colors.white);
                    await sendEmail(myEmail.text);
                    Navigator.pop(context, false);
                  } else {
                    myUvcToast.setToastDuration(3);
                    myUvcToast.setToastMessage(internetConnectionToastTextLanguageArray[languageArrayIdentifier]);
                    myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
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
      ..from = Address(username, emailUserTextLanguageArray[languageArrayIdentifier])
      ..recipients.add(destination)
      ..subject = emailSubjectTextLanguageArray[languageArrayIdentifier]
      ..attachments.add(new FileAttachment(File('${directory.path}/$_uvcDataSelectedFileName')))
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
}
