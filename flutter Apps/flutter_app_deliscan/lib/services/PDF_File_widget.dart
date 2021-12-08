import 'package:flutter/material.dart';
import 'package:flutter_app_deliscan/services/DataVariables.dart';
import 'package:flutter_app_deliscan/services/PDF_File_Class.dart';
import 'package:flutter_app_deliscan/services/languageDataBase.dart';

class FileCard extends StatelessWidget {
  final PDFFile pdfFile;
  final Function open;
  final Function send;
  final Function delete;

  FileCard({@required this.pdfFile, @required this.open, @required this.send, @required this.delete});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Card(
      margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(3.0, 8.0, 3.0, 8.0),
              child: Text(
                pdfFile.fileName,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: screenWidth * 0.03 + screenHeight * 0.03, color: Colors.grey[800]),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(3.0, 8.0, 3.0, 8.0),
                    child: TextButton.icon(
                      onPressed: open,
                      icon: Icon(
                        Icons.article,
                        color: Colors.blue,
                        size: screenWidth * 0.015 + screenHeight * 0.015,
                      ),
                      label: Text(
                        pdfFileCardOpenTextLanguageArray[languageArrayIdentifier],
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: screenWidth * 0.011 + screenHeight * 0.011, color: Colors.blue),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(3.0, 8.0, 3.0, 8.0),
                    child: TextButton.icon(
                      onPressed: send,
                      icon: Icon(
                        Icons.send,
                        color: Colors.green,
                        size: screenWidth * 0.015 + screenHeight * 0.015,
                      ),
                      label: Text(
                        sendEmailPageButtonTextLanguageArray[languageArrayIdentifier],
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: screenWidth * 0.011 + screenHeight * 0.011, color: Colors.green),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(3.0, 8.0, 3.0, 8.0),
                    child: TextButton.icon(
                      onPressed: delete,
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: screenWidth * 0.015 + screenHeight * 0.015,
                      ),
                      label: Text(
                        pdfFileCardDeleteTextLanguageArray[languageArrayIdentifier],
                        style: TextStyle(fontSize: screenWidth * 0.011 + screenHeight * 0.011, color: Colors.red),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
