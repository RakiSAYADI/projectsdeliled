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

  bool printButtonVisibility = false;

  ToastyMessage myUvcToast;

  @override
  void initState() {
    // TODO: implement initState
    myUvcToast = ToastyMessage(toastContext: context);
    addFiles();
    super.initState();
  }

  addFiles() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    listQrCodes.clear();
    fileCardSelectorColor.clear();
    fileSelector.clear();
    for (int i = 0; i < qrCodeImageList.length; i++) {
      fileSelector.add(false);
      fileCardSelectorColor.add(Colors.grey[200]);
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
                          style: TextStyle(fontSize: screenWidth * 0.02 + screenHeight * 0.02),
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
                        style: TextStyle(fontSize: screenWidth * 0.02 + screenHeight * 0.02),
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
    } else {
      fileCardSelectorColor[i] = Colors.grey[200];
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

  Future<bool> checkingStatePrinter(BuildContext context) async {
    waitingConnectionWidget(context, connectionWidgetTextLanguageArray[languageArrayIdentifier]);
    bool state = false;
    state = await zebraWifiPrinter.printerPing();
    state = await zebraWifiPrinter.checkPrinterState();
    Navigator.of(context).pop();
    if (state) {
      myUvcToast.setToastDuration(2);
      myUvcToast.setToastMessage(printerConnexionToastTextLanguageArray[languageArrayIdentifier]);
      myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
    } else {
      myUvcToast.setToastDuration(2);
      myUvcToast.setToastMessage(printerNoConnexionToastTextLanguageArray[languageArrayIdentifier]);
      myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
    }
    return state;
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
              if (printerBLEOrWIFI) {
                if (await checkingStatePrinter(context)) {
                  bool state = false;
                  int numberOfFilesToPrint = 0;
                  for (bool file in fileSelector) {
                    if (file) {
                      numberOfFilesToPrint++;
                    }
                  }
                  await zebraWifiPrinter.getPrinterSettings();
                  for (int i = 0; i < fileSelector.length; i++) {
                    if (fileSelector[i]) {
                      state = await zebraWifiPrinter.printFile(qrCodeImageList[i], true, 50);
                    }
                  }
                }
              } else {
                if (zebraBlePrinter.getConnectionState()) {
                  await zebraBlePrinter.printTest();
                } else {
                  zebraBlePrinter.disconnect();
                }
              }
            }),
      ),
    );
  }
}
