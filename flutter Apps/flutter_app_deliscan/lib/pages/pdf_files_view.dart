import 'package:flutter/material.dart';
import 'package:deliscan/services/DataVariables.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class PDFFileView extends StatefulWidget {
  @override
  _PDFFileViewState createState() => _PDFFileViewState();
}

class _PDFFileViewState extends State<PDFFileView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: Text(filePDFName),
        centerTitle: true,
      ),
      body: Center(
        child: PDF(
          enableSwipe: true,
        ).fromPath(filePDFPath),
      ),
    );
  }
}
