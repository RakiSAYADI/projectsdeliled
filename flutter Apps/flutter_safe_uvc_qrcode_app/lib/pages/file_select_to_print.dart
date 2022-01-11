import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Future<void> printSettings(BuildContext context) async {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final printHeightCM = TextEditingController();
    final printWidthCM = TextEditingController();
    final printResolutionDPI = TextEditingController();
    printResolutionDPI.text = zplConverter.printerResolution.toString();
    printHeightCM.text = ((zplConverter.printerHeight * 25.4) / zplConverter.printerResolution).toStringAsFixed(1);
    printWidthCM.text = ((zplConverter.printerWidth * 25.4) / zplConverter.printerResolution).toStringAsFixed(1);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(printSettingsAlertDialogTitleLanguageArray[languageArrayIdentifier]),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                resolutionAlertDialogTitleLanguageArray[languageArrayIdentifier],
                style: TextStyle(fontSize: (screenWidth * 0.05 + screenHeight * 0.002)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.05)),
                child: TextField(
                  style: TextStyle(fontSize: (screenWidth * 0.03 + screenHeight * 0.001)),
                  textAlign: TextAlign.center,
                  controller: printResolutionDPI,
                  maxLines: 1,
                  maxLength: 3,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}'))],
                  decoration: InputDecoration(
                      hintText: '0...999',
                      hintStyle: TextStyle(
                        fontSize: (screenWidth * 0.03 + screenHeight * 0.001),
                        color: Colors.grey,
                      )),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      printWidthAlertDialogTitleLanguageArray[languageArrayIdentifier],
                      style: TextStyle(fontSize: (screenWidth * 0.05)),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.05)),
                      child: TextField(
                        style: TextStyle(fontSize: (screenWidth * 0.03 + screenHeight * 0.001)),
                        textAlign: TextAlign.center,
                        controller: printWidthCM,
                        maxLines: 1,
                        maxLength: 5,
                        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}'))],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: '0...999.9',
                            hintStyle: TextStyle(
                              fontSize: (screenWidth * 0.03 + screenHeight * 0.001),
                              color: Colors.grey,
                            )),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      printHeightAlertDialogTitleLanguageArray[languageArrayIdentifier],
                      style: TextStyle(fontSize: (screenWidth * 0.05)),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.05)),
                      child: TextField(
                        style: TextStyle(fontSize: (screenWidth * 0.03 + screenHeight * 0.001)),
                        textAlign: TextAlign.center,
                        controller: printHeightCM,
                        maxLines: 1,
                        maxLength: 5,
                        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}'))],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: '0...999.9',
                            hintStyle: TextStyle(
                              fontSize: (screenWidth * 0.03 + screenHeight * 0.001),
                              color: Colors.grey,
                            )),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                applyTextLanguageArray[languageArrayIdentifier],
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                zplConverter.printerResolution = int.parse(printResolutionDPI.text);
                zplConverter.printerHeight = (double.parse(printHeightCM.text) * zplConverter.printerResolution) ~/ 25.4;
                zplConverter.printerWidth = (double.parse(printWidthCM.text) * zplConverter.printerResolution) ~/ 25.4;
                print(zplConverter.printerResolution);
                print(zplConverter.printerHeight);
                print(zplConverter.printerWidth);
              },
            ),
            TextButton(
              child: Text(
                cancelTextLanguageArray[languageArrayIdentifier],
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: Text(selectQrCodesTitleLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: () async {
                await printSettings(context);
              },
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  Container(
                    width: screenWidth * 0.13,
                    height: screenHeight * 0.07,
                    decoration: new BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Icon(Icons.settings, color: Colors.blue[400]),
                ],
              ),
            ),
          ),
        ],
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
