import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_deliscan/pages/pdf_email_send.dart';
import 'package:flutter_app_deliscan/pages/pdf_files_list.dart';
import 'package:flutter_app_deliscan/services/DataVariables.dart';
import 'package:flutter_app_deliscan/services/animation_between_pages.dart';
import 'package:flutter_app_deliscan/services/languageDataBase.dart';
import 'package:flutter_app_deliscan/services/uvcToast.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:path_provider/path_provider.dart';

class PDFDownloader extends StatefulWidget {
  @override
  _PDFDownloaderState createState() => _PDFDownloaderState();
}

class _PDFDownloaderState extends State<PDFDownloader> {
  int downloadProgress = 0;
  final myPDFFileName = TextEditingController();
  ToastyMessage _myUvcToast;
  Directory internalDirectory;
  List<String> fileName = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _myUvcToast = ToastyMessage(toastContext: context);
    init();
  }

  Future<void> init() async => await createFolderInAppDocDir(pdfFilesFolderName);

  Future<bool> createFolderInAppDocDir(String folderName) async {
    //Get this App Document Directory
    internalDirectory = await getApplicationDocumentsDirectory();
    //App Document Directory + folder name
    final Directory _appDocDirFolder = Directory('${internalDirectory.path}/$folderName/');

    if (await _appDocDirFolder.exists()) {
      //if folder already exists return path
      return true;
    } else {
      //if folder not exists create folder and then return its path
      await _appDocDirFolder.create(recursive: true);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: Text(pdfDownloaderTitleTextLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                inputTextMessageLanguageArray[languageArrayIdentifier],
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: screenHeight * 0.02 + screenWidth * 0.02, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                textAlign: TextAlign.center,
                controller: myPDFFileName,
                onChanged: (text) => filePDFIsSaved = false,
                style: TextStyle(
                  fontSize: screenHeight * 0.017 + screenWidth * 0.017,
                ),
                maxLines: 1,
                maxLength: 64,
                decoration: InputDecoration(
                  hintText: inputTextExampleMessageLanguageArray[languageArrayIdentifier],
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: screenHeight * 0.017 + screenWidth * 0.017,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                child: Text(
                  downloadTextLanguageArray[languageArrayIdentifier],
                  style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
                ),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[400]),
                ),
                onPressed: () async {
                  if (myPDFFileName.text.isNotEmpty) {
                    //App Document Directory + folder name
                    final Directory _appDocDirFolder = Directory('${internalDirectory.path}/$pdfFilesFolderName/');
                    List<FileSystemEntity> files = [];
                    files = Directory(_appDocDirFolder.path).listSync(followLinks: false);
                    if (files.length > 0) {
                      for (int i = 0; i < files.length; i++) {
                        fileName.add(files[i].toString().substring(internalDirectory.path.length + pdfFilesFolderName.length + 9, files[i].toString().length - 5));
                      }
                    }
                    if (!fileName.contains(myPDFFileName.text)) {
                      waitingWidget(context, waitingDownloadingAlertDialogMessageTextLanguageArray[languageArrayIdentifier]);
                      double download = 0.0;
                      File myPDFFile;
                      Dio dio = Dio();
                      myPDFFile = File('${internalDirectory.path}/$pdfFilesFolderName/${myPDFFileName.text}.pdf');
                      dio.download(pdfFileURL, myPDFFile.path, deleteOnError: true, onReceiveProgress: (rec, total) {
                        download = (rec / total) * 100;
                        if (download == 100.0) {
                          // delete the waiting widget
                          Navigator.of(context).pop();
                          _myUvcToast.setToastDuration(3);
                          _myUvcToast.setToastMessage(downloadCompleteToastTextLanguageArray[languageArrayIdentifier]);
                          _myUvcToast.showToast(Colors.green, Icons.done, Colors.white);
                          filePDFIsSaved = true;
                        }
                        print("Downloading PDF : " + (download).toStringAsFixed(0));
                      });
                    } else {
                      _myUvcToast.setToastDuration(3);
                      _myUvcToast.setToastMessage(sameNameToastTextLanguageArray[languageArrayIdentifier]);
                      _myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
                    }
                  } else {
                    _myUvcToast.setToastDuration(3);
                    _myUvcToast.setToastMessage(noNameToastTextLanguageArray[languageArrayIdentifier]);
                    _myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
                  }
                },
              ),
            ),
          ],
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
              Icons.assignment,
              color: Colors.white,
            ),
            backgroundColor: Colors.blue[400],
            label: listPDFTextLanguageArray[languageArrayIdentifier],
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => createRoute(context, PDFList()),
          ),
          SpeedDialChild(
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
            backgroundColor: Colors.green,
            label: sendTextLanguageArray[languageArrayIdentifier],
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () async {
              SystemChannels.textInput.invokeMethod('TextInput.hide');
              if (myPDFFileName.text.isNotEmpty) {
                if (filePDFIsSaved) {
                  filePDFName = myPDFFileName.text;
                  createRoute(context, PDFEmail());
                } else {
                  _myUvcToast.setToastDuration(3);
                  _myUvcToast.setToastMessage(noEmailToastTextLanguageArray[languageArrayIdentifier]);
                  _myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
                }
              } else {
                _myUvcToast.setToastDuration(3);
                _myUvcToast.setToastMessage(noNameToastTextLanguageArray[languageArrayIdentifier]);
                _myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
              }
            },
          ),
        ],
      ),
    );
  }
}
