import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_deliscan/pages/pdf_files_list.dart';
import 'package:flutter_app_deliscan/services/DataVariables.dart';
import 'package:flutter_app_deliscan/services/animation_between_pages.dart';
import 'package:flutter_app_deliscan/services/languageDataBase.dart';
import 'package:flutter_app_deliscan/services/uvcToast.dart';
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
                'Choissir le nom du fichier PDF :',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: screenHeight * 0.02 + screenWidth * 0.02, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                textAlign: TextAlign.center,
                controller: myPDFFileName,
                style: TextStyle(
                  fontSize: screenHeight * 0.017 + screenWidth * 0.017,
                ),
                maxLines: 1,
                maxLength: 64,
                decoration: InputDecoration(
                  hintText: 'exp:my_PDF_File',
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
                    bool downloading = false;
                    double download = 0.0;
                    File myPDFFile;
                    Dio dio = Dio();
                    myPDFFile = File('${internalDirectory.path}/$pdfFilesFolderName/${myPDFFileName.text}.pdf');
                    dio.download(pdfFileURL, myPDFFile.path, deleteOnError: true, onReceiveProgress: (rec, total) {
                      download = (rec / total) * 100;
                      if (download == 100.0) {
                        downloading = false;
                      } else {
                        downloading = true;
                      }
                      print("Downloading PDF : " + (download).toStringAsFixed(0));
                    });
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => createRoute(context, PDFList()),
        label: Text('List PDF'),
        icon: Icon(
          Icons.assignment,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue[400],
      ),
    );
  }

  Future<void> downloadWidget(BuildContext buildContext) async {
    double screenHeight = MediaQuery.of(buildContext).size.height;
    double screenWidth = MediaQuery.of(buildContext).size.width;
    return showDialog<void>(
        context: buildContext,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(downloadWidgetTextLanguageArray[languageArrayIdentifier]),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '$downloadProgress %',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: screenHeight * 0.02),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LinearProgressIndicator(
                    value: downloadProgress.toDouble(),
                    semanticsLabel: 'Download indicator',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text(
                  pauseTextLanguageArray[languageArrayIdentifier],
                  style: TextStyle(fontSize: (screenWidth * 0.02)),
                ),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              TextButton(
                child: Text(
                  stopTextLanguageArray[languageArrayIdentifier],
                  style: TextStyle(fontSize: (screenWidth * 0.02)),
                ),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
            ],
          );
        });
  }
}
