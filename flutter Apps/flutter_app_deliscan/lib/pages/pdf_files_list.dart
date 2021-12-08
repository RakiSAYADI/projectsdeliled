import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_deliscan/pages/pdf_email_send.dart';
import 'package:flutter_app_deliscan/pages/pdf_files_view.dart';
import 'package:flutter_app_deliscan/services/DataVariables.dart';
import 'package:flutter_app_deliscan/services/PDF_File_Class.dart';
import 'package:flutter_app_deliscan/services/PDF_File_widget.dart';
import 'package:flutter_app_deliscan/services/animation_between_pages.dart';
import 'package:flutter_app_deliscan/services/languageDataBase.dart';
import 'package:path_provider/path_provider.dart';

class PDFList extends StatefulWidget {
  @override
  _PDFListState createState() => _PDFListState();
}

class _PDFListState extends State<PDFList> {
  Directory internalDirectory;

  List<PDFFile> pdfFiles = [];
  List<FileSystemEntity> files = [];
  List<String> fileName = [];

  @override
  void initState() {
    // TODO: implement initState
    findAllPDFs();
    super.initState();
  }

  Future<void> findAllPDFs() async {
    internalDirectory = await getApplicationDocumentsDirectory();
    //App Document Directory + folder name
    final Directory _appDocDirFolder = Directory('${internalDirectory.path}/$pdfFilesFolderName/');
    try {
      files = Directory(_appDocDirFolder.path).listSync(followLinks: false);
      if (files.length > 0) {
        for (int i = 0; i < files.length; i++) {
          fileName.add(files[i].toString().substring(internalDirectory.path.length + pdfFilesFolderName.length + 9, files[i].toString().length - 5));
        }
      }
      setState(() {
        for (int i = 0; i < Directory(_appDocDirFolder.path).listSync(followLinks: false).length; i++) {
          pdfFiles.add(PDFFile(file: files[i], fileName: fileName[i]));
        }
      });
    } catch (e) {
      print('error list folder');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: Text(pdfListTitleTextLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
            children: pdfFiles
                .map((file) => FileCard(
                      pdfFile: file,
                      open: () {
                        filePDFPath = file.file.path;
                        filePDFName = file.fileName;
                        createRoute(context, PDFFileView());
                      },
                      send: () {
                        filePDFName = file.fileName;
                        createRoute(context, PDFEmail());
                      },
                      delete: () async {
                        waitingWidget(context, waitingAlertDialogMessageTextLanguageArray[languageArrayIdentifier]);
                        await file.file.delete(recursive: false);
                        pdfFiles.clear();
                        fileName.clear();
                        files.clear();
                        await Future.delayed(Duration(seconds: 1));
                        final Directory _appDocDirFolder = Directory('${internalDirectory.path}/$pdfFilesFolderName/');
                        files = Directory(_appDocDirFolder.path).listSync(followLinks: false);
                        if (files.length > 0) {
                          for (int i = 0; i < files.length; i++) {
                            fileName.add(files[i].toString().substring(internalDirectory.path.length + pdfFilesFolderName.length + 9, files[i].toString().length - 5));
                          }
                        }
                        setState(() {
                          for (int i = 0; i < Directory(_appDocDirFolder.path).listSync(followLinks: false).length; i++) {
                            pdfFiles.add(PDFFile(file: files[i], fileName: fileName[i]));
                          }
                        });
                        print(files);
                        print(fileName);
                        print(pdfFiles);
                        // delete the waiting widget
                        Navigator.of(context).pop();
                      },
                    ))
                .toList()),
      ),
    );
  }
}
