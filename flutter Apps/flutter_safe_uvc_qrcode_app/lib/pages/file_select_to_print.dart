import 'package:flutter/material.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/DataVariables.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/languageDataBase.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/uvcToast.dart';

class FileSelector extends StatefulWidget {
  @override
  _FileSelectorState createState() => _FileSelectorState();
}

class _FileSelectorState extends State<FileSelector> {
  List<bool> fileSelector = [];

  List<Color> fileCardSelectorColor = [];
  List<Color> fileCardNameSelectorColor = [];

  ToastyMessage myUvcToast;

  bool printButtonVisibility = false;

  @override
  void initState() {
    // TODO: implement initState
    myUvcToast = ToastyMessage(toastContext: context);
    addFiles();
    super.initState();
  }

  addFiles() async {
    listQrCodes.clear();
    fileCardSelectorColor.clear();
    fileCardNameSelectorColor.clear();
    fileSelector.clear();
    for (int i = 0; i < qrCodeImageList.length; i++) {
      fileSelector.add(false);
      fileCardSelectorColor.add(Colors.grey[200]);
      fileCardNameSelectorColor.add(Colors.black);
      listQrCodes.add(
        TableRow(
          children: [
            GestureDetector(
              onTap: () => selectFile(i),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: fileCardSelectorColor[i],
                  margin: const EdgeInsets.all(16.0),
                  shape: RoundedRectangleBorder(side: new BorderSide(color: Colors.blue[400], width: 2.0), borderRadius: BorderRadius.circular(18.0)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RepaintBoundary(
                        child: Image.file(qrCodeImageList[i], width: screenWidth * 0.3, height: screenHeight * 0.3),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          qrCodeList[i].fileName,
                          style: TextStyle(fontSize: screenWidth * 0.02 + screenHeight * 0.02, color: fileCardNameSelectorColor[i]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  changeFiles() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    for (int i = 0; i < qrCodeImageList.length; i++) {
      listQrCodes[i] = TableRow(
        children: [
          GestureDetector(
            onTap: () => selectFile(i),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: fileCardSelectorColor[i],
                margin: const EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(side: new BorderSide(color: Colors.blue[400], width: 2.0), borderRadius: BorderRadius.circular(18.0)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RepaintBoundary(
                      child: Image.file(qrCodeImageList[i], width: screenWidth * 0.3, height: screenHeight * 0.3),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        qrCodeList[i].fileName,
                        style: TextStyle(fontSize: screenWidth * 0.02 + screenHeight * 0.02, color: fileCardNameSelectorColor[i]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  selectFile(int i) {
    printButtonVisibility = false;
    fileSelector[i] = !fileSelector[i];
    listQrCodes = listQrCodes;
    if (fileSelector[i]) {
      fileCardSelectorColor[i] = Colors.green[700];
      fileCardNameSelectorColor[i] = Colors.white;
    } else {
      fileCardSelectorColor[i] = Colors.grey[200];
      fileCardNameSelectorColor[i] = Colors.black;
    }
    for (bool state in fileSelector) {
      if (state) {
        printButtonVisibility = true;
        break;
      }
    }
    changeFiles();
    setState(() {});
  }

  Future<void> printStateWidget(BuildContext buildContext, int fileNumber) async {
    double screenWidth = MediaQuery.of(buildContext).size.width;
    double screenHeight = MediaQuery.of(buildContext).size.height;
    return showDialog<void>(
        context: buildContext,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
              title: Text(
                impressionWidgetTextLanguageArray[languageArrayIdentifier],
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/printing.gif',
                    width: screenWidth * 0.5,
                    height: screenHeight * 0.3,
                  ),
                ],
              ),
            );
          });
        });
  }

  printDoneToast(BuildContext context) async {
    myUvcToast.setToastDuration(2);
    myUvcToast.setToastMessage(printDoneToastTextLanguageArray[languageArrayIdentifier]);
    myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: Text(selectQrCodesTitleLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Table(border: TableBorder.all(color: Colors.black), defaultVerticalAlignment: TableCellVerticalAlignment.middle, children: listQrCodes),
        ),
      ),
      floatingActionButton: Visibility(
        visible: printButtonVisibility,
        child: FloatingActionButton(
            child: Icon(Icons.print),
            onPressed: () async {
              int numberOfFilesToPrint = 0;
              for (bool file in fileSelector) {
                if (file) {
                  numberOfFilesToPrint++;
                }
              }
              printStateWidget(context, numberOfFilesToPrint);
              for (int i = 0; i < fileSelector.length; i++) {
                if (fileSelector[i]) {
                  if (printerBLEOrWIFI) {
                    await zebraWifiPrinter.printFile(qrCodeImageList[i], true, 50);
                    await Future.delayed(Duration(milliseconds: 500));
                  } else {
                    await zebraBlePrinter.printFile(qrCodeImageList[i], true, 50);
                    await Future.delayed(Duration(milliseconds: 500));
                  }
                }
              }
              Navigator.of(context).pop();
              printDoneToast(context);
            }),
      ),
    );
  }
}
