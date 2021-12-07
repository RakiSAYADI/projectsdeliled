import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_deliscan/services/DataVariables.dart';
import 'package:flutter_app_deliscan/services/languageDataBase.dart';
import 'package:path_provider/path_provider.dart';

class PDFList extends StatefulWidget {
  @override
  _PDFListState createState() => _PDFListState();
}

class _PDFListState extends State<PDFList> {
  Directory internalDirectory;

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
      List file = Directory(_appDocDirFolder.path).listSync(followLinks: false);
      List<String> fileName = [];
      if (file.length > 0) {
        for (int i = 0; i < file.length; i++) {
          fileName.add(file[i].toString().substring(internalDirectory.path.length + pdfFilesFolderName.length + 9, file[i].toString().length - 5));
        }
      }
    } catch (e) {
      print('erreur list folder');
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [],
        ),
      ),
    );
  }
}
