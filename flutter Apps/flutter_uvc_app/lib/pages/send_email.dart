import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutteruvcapp/services/CSVfileClass.dart';
import 'package:flutteruvcapp/services/DataVariables.dart';
import 'package:flutteruvcapp/services/languageDataBase.dart';
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

  //final String _uvcDataFileName = 'RapportUVC.csv';
  final String _uvcDataSelectedFileName = 'RapportDataUVC.csv';

  final myEmail = TextEditingController();

  UVCDataFile uvcDataFile;

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
      if (userEmail.isEmpty) {
        userEmail = await uvcDataFile.readUserEmailDATA();
      }
      myEmail.text = userEmail;
    }
  }

  @override
  Widget build(BuildContext context) {
    readUserEmailFile();

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(sendEmailPageTitleTextLanguageArray[languageArrayIdentifier]),
          leading: BackButton(onPressed: () async {
            await exitApp(context);
          }),
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
                        sendEmailPageMessageTextLanguageArray[languageArrayIdentifier],
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
                      TextButton(
                        onPressed: () async {
                          if (myEmail.text.isNotEmpty &&
                              RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                                  .hasMatch(myEmail.text)) {
                            await uvcDataFile.saveStringUVCEmailDATA(myEmail.text);
                            uvcDataFile.saveUVCDATASelected(uvcDataSelected);
                            myUvcToast.setToastDuration(60);
                            myUvcToast.setToastMessage(sendingEmailPageToastTextLanguageArray[languageArrayIdentifier]);
                            myUvcToast.showToast(Colors.green, Icons.send, Colors.white);
                            await sendEmail(myEmail.text);
                          } else {
                            myUvcToast.setToastDuration(10);
                            myUvcToast.setToastMessage(emailAddressNonValidToastTextLanguageArray[languageArrayIdentifier]);
                            myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
                          }
                        },
                        child: Text(
                          sendEmailPageButtonTextLanguageArray[languageArrayIdentifier],
                          style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
                        ),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[400]),
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
      onWillPop: () => exitApp(context),
    );
  }

  Future<bool> exitApp(BuildContext context) async {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    Navigator.of(context).pop();
    return true;
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
      ..from = Address(username, 'Deeplight')
      ..recipients.add(destination)
      ..subject = uvcEmailObjectTextLanguageArray[languageArrayIdentifier]
      ..attachments.add(new FileAttachment(File('${directory.path}/$_uvcDataSelectedFileName')))
      ..text = uvcEmailMessageTextLanguageArray[languageArrayIdentifier];

    try {
      await send(message, serverSMTPDeepLight);
      myUvcToast.clearAllToast();
      myUvcToast.setToastDuration(3);
      myUvcToast.setToastMessage(sendEmailValidToastTextLanguageArray[languageArrayIdentifier]);
      myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
    } on MailerException catch (e) {
      print(e.message);
      myUvcToast.clearAllToast();
      myUvcToast.setToastDuration(3);
      myUvcToast.setToastMessage(sendEmailNotValidToastTextLanguageArray[languageArrayIdentifier]);
      myUvcToast.showToast(Colors.red, Icons.thumb_down, Colors.white);
    }
  }
}
