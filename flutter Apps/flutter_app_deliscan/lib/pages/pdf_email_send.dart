import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_deliscan/services/DataVariables.dart';
import 'package:flutter_app_deliscan/services/data_storage_phone.dart';
import 'package:flutter_app_deliscan/services/languageDataBase.dart';
import 'package:flutter_app_deliscan/services/uvcToast.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:path_provider/path_provider.dart';

class PDFEmail extends StatefulWidget {
  @override
  _PDFEmailState createState() => _PDFEmailState();
}

class _PDFEmailState extends State<PDFEmail> {
  ToastyMessage _myUvcToast;

  UVCDataFile uvcDataFile;

  final myEmail = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    _myUvcToast = ToastyMessage(toastContext: context);
    readEmailUser();
    super.initState();
  }

  void readEmailUser() async {
    uvcDataFile = UVCDataFile();
    userEmail = await uvcDataFile.readUserEmailDATA();
    myEmail.text = userEmail;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(sendEmailPageTitleTextLanguageArray[languageArrayIdentifier]),
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
                        await uvcDataFile.saveUserEmailDATA(myEmail.text);
                        _myUvcToast.setToastDuration(60);
                        _myUvcToast.setToastMessage(sendingEmailPageToastTextLanguageArray[languageArrayIdentifier]);
                        _myUvcToast.showToast(Colors.green, Icons.send, Colors.white);
                        await sendEmail(myEmail.text);
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
    );
  }

  Future<void> sendEmail(String destination) async {
    final directory = await getApplicationDocumentsDirectory();
    final String host = 'smtp.office365.com';
    final String username = 'rapports-deeplight@delitech.eu';
    final String password = 'Ven34Dar20*';
    // Server SMTP
    final serverSMTPDeepLight = SmtpServer(host, username: username, password: password);
    // Create our message.
    final message = Message()
      ..from = Address(username, 'DeliTech Medical')
      ..recipients.add(destination)
      ..subject = uvcEmailObjectTextLanguageArray[languageArrayIdentifier]
      ..attachments.add(new FileAttachment(File('${directory.path}/$pdfFilesFolderName/$filePDFName.pdf')))
      ..text = uvcEmailMessageTextLanguageArray[languageArrayIdentifier];

    try {
      await send(message, serverSMTPDeepLight);
      _myUvcToast.clearAllToast();
      _myUvcToast.setToastDuration(3);
      _myUvcToast.setToastMessage(sendEmailValidToastTextLanguageArray[languageArrayIdentifier]);
      _myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
    } on MailerException catch (e) {
      print(e.message);
      _myUvcToast.clearAllToast();
      _myUvcToast.setToastDuration(3);
      _myUvcToast.setToastMessage(sendEmailNotValidToastTextLanguageArray[languageArrayIdentifier]);
      _myUvcToast.showToast(Colors.red, Icons.thumb_down, Colors.white);
    }
  }
}
