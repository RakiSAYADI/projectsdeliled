import 'dart:convert';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/DataVariables.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/ZebraPrinterBLEWidget.dart';
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
  List<ZebraWifiPrinter> wifiPrinters = [];
  List<ZebraBLEPrinter> blePrinters = [];
  ToastyMessage myUvcToast;

  List<String> devicesMacAddress = [];

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
    bluetoothPrint = BluetoothPrint.instance;

    bluetoothPrint.scanResults.listen((results) {
      for (BluetoothDevice zebraPrinter in results) {
        print('${zebraPrinter.name} found! mac: ${zebraPrinter.address}');
        if (zebraPrinter.name.contains('Zebra') && (!devicesMacAddress.contains(zebraPrinter.address))) {
          setState(() {
            blePrinters.add(new ZebraBLEPrinter(zebraPrinter: zebraPrinter));
          });
        }
        devicesMacAddress.add(zebraPrinter.address);
      }
    });
    // Start scanning`
    bluetoothPrint.startScan(timeout: Duration(seconds: 4));
  }

  scanWIFIForZebraPrinters(BuildContext context) async {
    waitingConnectionWidget(context, scanWidgetTextLanguageArray[languageArrayIdentifier]);
    // Start scanning`
    Map<String, dynamic> messageJSON;
    try {
      await ZebraSdk.onDiscovery().then((printersString) {
        messageJSON = json.decode(printersString);
        if (messageJSON['success'] == true) {
          List<dynamic> listPrinters = jsonDecode(messageJSON['content']);
          for (int i = 0; i < listPrinters.length; i++) {
            print('list of zebra printers on Local : ${listPrinters[i]}');
            setState(() {
              wifiPrinters.add(new ZebraWifiPrinter(name: listPrinters[i]['productName'], address: listPrinters[i]['address'], port: listPrinters[i]['jsonPortNumber']));
            });
          }
          scanDoneToast(context);
        } else {
          scanErrorToast(context);
          print('error access local network !');
        }
      });
    } catch (e) {
      scanErrorToast(context);
      print(e);
    }
    Navigator.of(context).pop();
  }

  Widget floatingActionButtonScan() {
    if (printerBLEOrWIFI) {
      return FloatingActionButton(
          child: Icon(Icons.search),
          onPressed: () {
            setState(() {
              wifiPrinters.clear();
            });
            scanWIFIForZebraPrinters(context);
          });
    } else {
      return StreamBuilder<bool>(
        stream: bluetoothPrint.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => bluetoothPrint.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    blePrinters.clear();
                  });
                  devicesMacAddress.clear();
                  bluetoothPrint.startScan(timeout: Duration(seconds: 4));
                });
          }
        },
      );
    }
  }

  Future<bool> checkingStatePrinter(BuildContext context, ZebraBLEPrinter zebraBLEPrinter) async {
    waitingConnectionWidget(context, connectionWidgetTextLanguageArray[languageArrayIdentifier]);
    bool state = false;
    await zebraBLEPrinter.connect();
    state = zebraBLEPrinter.getConnectionState();
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

  Widget columnDevicesScanned(BuildContext context) {
    if (printerBLEOrWIFI) {
      return Column(
          children: wifiPrinters
              .map((wifiPrinter) => PrinterWifiCard(
                    printer: wifiPrinter,
                    send: () {
                      zebraWifiPrinter = wifiPrinter;
                      Navigator.pushNamed(context, '/file_selector');
                    },
                  ))
              .toList());
    } else {
      return Column(
          children: blePrinters
              .map((blePrinter) => PrinterBleCard(
                    printer: blePrinter,
                    send: () async {
                      zebraBlePrinter = blePrinter;
                      await bluetoothPrint.stopScan();
                      if (await checkingStatePrinter(context, zebraBlePrinter)) {
                        Navigator.pushNamed(context, '/file_selector');
                      }
                    },
                  ))
              .toList());
    }
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
      floatingActionButton: floatingActionButtonScan(),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: columnDevicesScanned(context),
      ),
    );
  }
}
