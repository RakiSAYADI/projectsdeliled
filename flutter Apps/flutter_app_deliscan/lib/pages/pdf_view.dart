import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_deliscan/pages/pdf_file_downloader.dart';
import 'package:flutter_app_deliscan/services/DataVariables.dart';
import 'package:flutter_app_deliscan/services/animation_between_pages.dart';
import 'package:flutter_app_deliscan/services/languageDataBase.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class PDFViewer extends StatefulWidget {
  @override
  _PDFViewerState createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
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
            errorWidget: (error) => Center(child: Text(error.toString())),
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
                Icons.file_download,
                color: Colors.white,
              ),
              backgroundColor: Colors.green,
              label: downloadTextLanguageArray[languageArrayIdentifier],
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () async {
                SystemChannels.textInput.invokeMethod('TextInput.hide');
                createRoute(context, PDFDownloader());
              },
            ),
            SpeedDialChild(
              child: Icon(
                Icons.send,
                color: Colors.white,
              ),
              backgroundColor: Colors.blue,
              label: sendTextLanguageArray[languageArrayIdentifier],
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () async {
                SystemChannels.textInput.invokeMethod('TextInput.hide');
              },
            ),
          ],
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
