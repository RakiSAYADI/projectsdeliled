import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/DataVariables.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/ZebraPrinterWIFIWidget.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/languageDataBase.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/uvcToast.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/zebraPrinterDeviceClass.dart';
import 'package:flutter_zebra_sdk/flutter_zebra_sdk.dart';

class ScanListPrinters extends StatefulWidget {
  @override
  _ScanListPrintersState createState() => _ScanListPrintersState();
}

class _ScanListPrintersState extends State<ScanListPrinters> {
  List<ZebraWifiPrinter> printers = [];
  ToastyMessage myUvcToast;

  @override
  void initState() {
    super.initState();
    myUvcToast = ToastyMessage(toastContext: context);
    if (printerBLEOrWIFI) {
      scanWIFIForZebraPrinters(context);
    } else {
      scanBLEForZebraPrinters(context);
    }
  }

  scanErrorToast(BuildContext context) async {
    myUvcToast.setToastDuration(2);
    myUvcToast.setToastMessage(noScanToastTextLanguageArray[languageArrayIdentifier]);
    myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
  }

  scanDoneToast(BuildContext context) async {
    myUvcToast.setToastDuration(2);
    myUvcToast.setToastMessage(scanToastTextLanguageArray[languageArrayIdentifier]);
    myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
  }

  scanBLEForZebraPrinters(BuildContext context) async {
    waitingConnectionWidget(context, scanWidgetTextLanguageArray[languageArrayIdentifier]);
    // Start scanning`
    Map<String, dynamic> messageJSON;
    Navigator.of(context).pop();
  }

  scanWIFIForZebraPrinters(BuildContext context) async {
    waitingConnectionWidget(context, scanWidgetTextLanguageArray[languageArrayIdentifier]);
    // Start scanning`
    Map<String, dynamic> messageJSON;
    await ZebraSdk.onDiscovery().then((printersString) {
      try {
        messageJSON = json.decode(printersString);
        if (messageJSON['success'] == true) {
          List<dynamic> listPrinters = jsonDecode(messageJSON['content']);
          for (int i = 0; i < listPrinters.length; i++) {
            print('list of zebra printers on Local : ${listPrinters[i]}');
            setState(() {
              printers.add(new ZebraWifiPrinter(name: listPrinters[i]['productName'], address: listPrinters[i]['address'], port: listPrinters[i]['jsonPortNumber']));
            });
          }
          scanDoneToast(context);
        } else {
          scanErrorToast(context);
          print('error access local network !');
        }
      } catch (e) {
        scanErrorToast(context);
        print(e);
      }
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(scanPrinterDevicesPageTitleTextLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.search),
          onPressed: () {
            setState(() {
              printers.clear();
            });
            if (printerBLEOrWIFI) {
              scanWIFIForZebraPrinters(context);
            } else {
              scanBLEForZebraPrinters(context);
            }
          }),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
            children: printers
                .map((printer) => PrinterWifiCard(
                      printer: printer,
                      send: () {
                        zebraPrinter = printer;
                        Navigator.pushNamed(context, '/file_selector');
                      },
                    ))
                .toList()),
      ),
    );
  }
}
