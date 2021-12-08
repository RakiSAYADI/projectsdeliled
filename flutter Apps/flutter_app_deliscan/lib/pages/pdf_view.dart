import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_deliscan/pages/pdf_file_downloader.dart';
import 'package:flutter_app_deliscan/services/DataVariables.dart';
import 'package:flutter_app_deliscan/services/animation_between_pages.dart';
import 'package:flutter_app_deliscan/services/languageDataBase.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class PDFViewer extends StatefulWidget {
  @override
  _PDFViewerState createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  bool downloadVisibility = true;

  Future<void> refreshWidget() async {
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () async {
            await returnButton(context);
          }),
          backgroundColor: Colors.blue[400],
          title: Text(pdfViewerTitleTextLanguageArray[languageArrayIdentifier]),
          centerTitle: true,
        ),
        body: Center(
          child: PDF(
            enableSwipe: true,
          ).cachedFromUrl(
            pdfFileURL,
            placeholder: (progress) => Center(child: Text('$progress %')),
            errorWidget: (error) {
              downloadVisibility = false;
              refreshWidget();
              return Center(child: Text(error.toString(), textAlign: TextAlign.center));
            },
          ),
        ),
        floatingActionButton: Visibility(
          visible: downloadVisibility,
          child: FloatingActionButton(
            onPressed: () {
              SystemChannels.textInput.invokeMethod('TextInput.hide');
              filePDFIsSaved = false;
              createRoute(context, PDFDownloader());
            },
            child: Icon(
              Icons.file_download,
              color: Colors.white,
            ),
            backgroundColor: Colors.blue[400],
          ),
        ),
      ),
      onWillPop: () => returnButton(context),
    );
  }

  Future<bool> returnButton(BuildContext context) async {
    qrViewController.resumeCamera();
    qrCodeVerified = false;
    Navigator.pop(context, true);
    return true;
  }
}
