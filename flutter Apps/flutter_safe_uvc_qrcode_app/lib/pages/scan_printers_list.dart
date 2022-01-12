import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/DataVariables.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/ZebraPrinterBLEWidget.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/ZebraPrinterWIFIWidget.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/languageDataBase.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/uvcToast.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/zebraPrinterDeviceClass.dart';
import 'package:flutter_zebra_sdk/flutter_zebra_sdk.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:network_info_plus/network_info_plus.dart';

class ScanListPrinters extends StatefulWidget {
  @override
  _ScanListPrintersState createState() => _ScanListPrintersState();
}

class _ScanListPrintersState extends State<ScanListPrinters> {
  List<ZebraWifiPrinter> wifiPrinters = [];
  List<ZebraBLEPrinter> blePrinters = [];
  ToastyMessage myUvcToast;

  List<String> devicesMacAddress = [];

  String customIpAddress = '';

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
    flutterBlue = FlutterBlue.instance;

    flutterBlue.scanResults.listen((results) {
      for (ScanResult zebraPrinter in results) {
        print('${zebraPrinter.device.name} found! mac: ${zebraPrinter.device.id.id}');
        if ((zebraPrinter.device.name.contains('Zebra')) || (zebraPrinter.device.name.contains('ZEBRA')) && (!devicesMacAddress.contains(zebraPrinter.device.id.id))) {
          setState(() {
            blePrinters.add(new ZebraBLEPrinter(zebraPrinter: zebraPrinter.device));
          });
        }
        devicesMacAddress.add(zebraPrinter.device.id.id);
      }
    });
    // Start scanning`
    flutterBlue.startScan(timeout: Duration(seconds: 4));
  }

  List<String> printerAddressList = [];

  scanWIFIForZebraPrinters(BuildContext context) async {
    await Future.delayed(Duration(milliseconds: 200));
    waitingConnectionWidget(context, scanWidgetTextLanguageArray[languageArrayIdentifier]);
    var wifiIP = await (NetworkInfo().getWifiIP());
    customIpAddress = ipToSubnet(wifiIP);
    //ping to check the network
    for (int i = 1; i < 256; i++) {
      try {
        await Socket.connect('$customIpAddress.$i', 9100, timeout: Duration(milliseconds: 200));
        print('we have good connection => $customIpAddress.$i');
      } catch (e) {
        print(e);
      }
    }

    // Start scanning
    try {
      Map<String, dynamic> messageJSON;
      await ZebraSdk.onDiscovery().then((printersString) {
        print(printersString);
        messageJSON = json.decode(printersString);
        if (messageJSON['success'] == true) {
          List<dynamic> listPrinters = jsonDecode(messageJSON['content']);
          for (int i = 0; i < listPrinters.length; i++) {
            print('list of zebra printers on Local : ${listPrinters[i]}');
            setState(() {
              if (Platform.isIOS) {
                wifiPrinters.add(new ZebraWifiPrinter(name: listPrinters[i]['productName'], address: listPrinters[i]['address'], port: listPrinters[i]['jsonPortNumber']));
              }
              if (Platform.isAndroid) {
                wifiPrinters.add(new ZebraWifiPrinter(name: listPrinters[i]['productName'], address: listPrinters[i]['address'], port: 9100));
              }
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

  Widget floatingActionButtonScan(BuildContext context) {
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
        stream: flutterBlue.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => flutterBlue.stopScan(),
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
                  flutterBlue.startScan(timeout: Duration(seconds: 4));
                });
          }
        },
      );
    }
  }

  Future<void> editIPAddress(BuildContext context) async {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    final myPrinterIP = TextEditingController();
    myPrinterIP.text = customIpAddress;
    return showDialog<void>(
      context: context,
      builder: (BuildContext c) {
        return AlertDialog(
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    enterIpAddressPrinterTextLanguageArray[languageArrayIdentifier],
                    style: TextStyle(fontSize: (widthScreen * 0.05)),
                  ),
                  SizedBox(height: heightScreen * 0.05),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: (widthScreen * 0.05)),
                    child: TextField(
                      style: TextStyle(fontSize: (widthScreen * 0.05)),
                      textAlign: TextAlign.center,
                      controller: myPrinterIP,
                      maxLines: 1,
                      decoration: InputDecoration(
                          hintText: '$customIpAddress.XXX',
                          hintStyle: TextStyle(
                            fontSize: (widthScreen * 0.05),
                            color: Colors.grey,
                          )),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                validateTextLanguageArray[languageArrayIdentifier],
                style: TextStyle(fontSize: (widthScreen * 0.05)),
              ),
              onPressed: () async {
                Navigator.pop(context, false);
                if (myPrinterIP.text.isNotEmpty && myPrinterIP.text.contains(customIpAddress)) {
                  try {
                    await Socket.connect(myPrinterIP.text, 9100, timeout: Duration(seconds: 1));
                    zebraWifiPrinter = ZebraWifiPrinter(name: 'Custom Zebra Printer', address: myPrinterIP.text, port: 9100);
                    Navigator.pushNamed(context, '/file_selector');
                  } catch (e) {
                    print(e);
                    myUvcToast.setToastDuration(3);
                    myUvcToast.setToastMessage(nonValidIPAddressToastTextLanguageArray[languageArrayIdentifier]);
                    myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
                  }
                } else {
                  myUvcToast.setToastDuration(3);
                  myUvcToast.setToastMessage(nonValidIPAddressToastTextLanguageArray[languageArrayIdentifier]);
                  myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
                }
                myPrinterIP.text = '';
              },
            ),
            TextButton(
              child: Text(
                cancelTextLanguageArray[languageArrayIdentifier],
                style: TextStyle(fontSize: (widthScreen * 0.05)),
              ),
              onPressed: () {
                myPrinterIP.text = '';
                Navigator.pop(context, false);
              },
            ),
          ],
        );
      },
    );
  }

  Widget enterIPAddress(BuildContext context) {
    if (printerBLEOrWIFI) {
      return Padding(
        padding: EdgeInsets.all(10.0),
        child: GestureDetector(
          onTap: () async {
            await editIPAddress(context);
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
              Icon(Icons.edit, color: Colors.blue[400]),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
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
                      await flutterBlue.stopScan();
                      Navigator.pushNamed(context, '/file_selector');
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
        actions: <Widget>[
          enterIPAddress(context),
        ],
        centerTitle: true,
        backgroundColor: Colors.blue[400],
      ),
      floatingActionButton: floatingActionButtonScan(context),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: columnDevicesScanned(context),
      ),
    );
  }
}
