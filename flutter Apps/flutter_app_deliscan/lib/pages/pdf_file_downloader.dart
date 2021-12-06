import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_deliscan/services/DataVariables.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _myUvcToast = ToastyMessage(toastContext: context);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
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
                style: TextStyle(fontSize: screenHeight * 0.02 + screenWidth * 0.02),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                textAlign: TextAlign.center,
                controller: myPDFFileName,
                style: TextStyle(
                  fontSize: screenWidth * 0.02,
                ),
                maxLines: 1,
                maxLength: 64,
                decoration: InputDecoration(
                  hintText: 'exp:my_PDF_File',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Choissir l\'emplacement du fichier PDF :',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: screenHeight * 0.02 + screenWidth * 0.02),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [],
            ),
            TextButton(
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
                  var imageUrl = "https://www.itl.cat/pngfile/big/10-100326_desktop-wallpaper-hd-full-screen-free-download-full.jpg";
                  bool downloading = true;
                  String downloadingStr = "No data";
                  double download = 0.0;
                  File f;
                  Dio dio = Dio();
                  var dir = await getApplicationDocumentsDirectory();
                  f = File("${dir.path}/myimagepath.jpg");
                  String fileName = imageUrl.substring(imageUrl.lastIndexOf("/") + 1);
                  dio.download(imageUrl, "${dir.path}/$fileName", onReceiveProgress: (rec, total) {
                    setState(() {
                      downloading = true;
                      download = (rec / total) * 100;
                      print(fileName);
                      downloadingStr = "Downloading Image : " + (download).toStringAsFixed(0);
                    });
                  });
                  /*final downloaderUtils = DownloaderUtils(
                    progressCallback: (current, total) {
                      final progress = (current / total) * 100;
                      downloadProgress = progress.round();
                      print('Downloading: $progress');
                    },
                    file: File('$pathFile/${myPDFFileName.text}.pdf'),
                    progress: ProgressImplementation(),
                    onDone: () {
                      print('Download done');
                      Navigator.pop(context, false);
                    },
                    deleteOnCancel: true,
                  );
                  Flowder.download(pdfFileURL, downloaderUtils);
                  downloadWidget(context);*/
                } else {
                  _myUvcToast.setToastDuration(3);
                  _myUvcToast.setToastMessage(noNameToastTextLanguageArray[languageArrayIdentifier]);
                  _myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
                }
              },
            ),
          ],
        ),
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
