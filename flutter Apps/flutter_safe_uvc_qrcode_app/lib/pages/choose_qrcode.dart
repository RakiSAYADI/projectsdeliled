import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/DataVariables.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/languageDataBase.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/uvcToast.dart';
import 'package:flutter_usb_write/flutter_usb_write.dart';
import 'package:flutter_zebra_sdk/flutter_zebra_sdk.dart';
import 'package:super_easy_permissions/super_easy_permissions.dart';

class ChooseQrCode extends StatefulWidget {
  @override
  _ChooseQrCodeState createState() => _ChooseQrCodeState();
}

class _ChooseQrCodeState extends State<ChooseQrCode> {
  ToastyMessage myUvcToast;

  @override
  void initState() {
    // TODO: implement initState
    myUvcToast = ToastyMessage(toastContext: context);
    SuperEasyPermissions.askPermission(Permissions.location).then((value) {
      if (value) {
        SuperEasyPermissions.askPermission(Permissions.locationAlways).then((value) {
          if (value) {
            SuperEasyPermissions.askPermission(Permissions.locationWhenInUse);
          }
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.blue[400],
      appBar: AppBar(
        title: Text(qrCodeChoiceTitleLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: () async {
                await displayQrCodeDATA(context);
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
                  Icon(Icons.print, color: Colors.blue[400]),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Builder(
          builder: (context) {
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    qrCodeGenerator(
                        context: context,
                        destination: "/Qr_code_Generate",
                        buttonTitle: qrCodeDataTitleLanguageArray[languageArrayIdentifier],
                        buttonText: qrCodeDataTextLanguageArray[languageArrayIdentifier],
                        buttonDescription1: qrCodeDataDescription1LanguageArray[languageArrayIdentifier],
                        buttonDescription2: qrCodeDataDescription2LanguageArray[languageArrayIdentifier]),
                    qrCodeGenerator(
                        context: context,
                        destination: "/qr_code_scan",
                        buttonTitle: qrCodeOneClickTitleLanguageArray[languageArrayIdentifier],
                        buttonText: qrCodeOneClickTextLanguageArray[languageArrayIdentifier],
                        buttonDescription1: qrCodeOneClickDescription1LanguageArray[languageArrayIdentifier],
                        buttonDescription2: qrCodeOneClickDescription2LanguageArray[languageArrayIdentifier]),
                    qrCodeGeneratorSecond(
                        context: context,
                        destination: "/Qr_code_Generate_Data",
                        buttonTitle: qrCodeRapportTitleLanguageArray[languageArrayIdentifier],
                        buttonText: qrCodeRapportTextLanguageArray[languageArrayIdentifier]),
                    qrCodeGeneratorSecond(
                        context: context,
                        destination: "/Qr_code_Display",
                        buttonTitle: qrCodeSecurityTitleLanguageArray[languageArrayIdentifier],
                        buttonText: qrCodeSecurityTextLanguageArray[languageArrayIdentifier]),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> displayQrCodeDATA(BuildContext context) async {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    listQrCodes.clear();
    if (qrCodeImageList.length == 0) {
      myUvcToast.setToastDuration(2);
      myUvcToast.setToastMessage(noFilesToastTextLanguageArray[languageArrayIdentifier]);
      myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
    } else {
      for (int i = 0; i < qrCodeImageList.length; i++) {
        listQrCodes.add(TableRow(children: [
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            RepaintBoundary(child: Image.file(qrCodeImageList[i], width: screenWidth * 0.27, height: screenHeight * 0.14)),
            Text(qrCodeList[i].fileName),
          ])
        ]));
      }
      try {
        FlutterUsbWrite _flutterUsbWrite = FlutterUsbWrite();
        List<UsbDevice> devices = await _flutterUsbWrite.listDevices();
        print(" length: ${devices.length}");
        myUvcToast.setToastDuration(5);
        myUvcToast.setToastMessage(devices.toString());
        myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
        await Future.delayed(Duration(seconds: 1));
        await ZebraSdk.onDiscoveryUSB().then((value) {
          myUvcToast.setToastDuration(5);
          myUvcToast.setToastMessage(value.toString());
          myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
        });
      } on PlatformException catch (e) {
        print(e.message);
      }
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(qrCodesAlertDialogTitleLanguageArray[languageArrayIdentifier]),
            content: SingleChildScrollView(
              child: Table(border: TableBorder.all(color: Colors.black), defaultVerticalAlignment: TableCellVerticalAlignment.middle, children: listQrCodes),
            ),
            actions: [
              TextButton(
                child: Text(
                  printBLETextLanguageArray[languageArrayIdentifier],
                  style: TextStyle(color: Colors.green),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await SuperEasyPermissions.askPermission(Permissions.bluetooth);
                  printerBLEOrWIFI = false;
                  Navigator.pushNamed(context, '/scan_list_printers');
                },
              ),
              TextButton(
                child: Text(
                  printWifiTextLanguageArray[languageArrayIdentifier],
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  var connectivityResult = await (Connectivity().checkConnectivity());
                  if (connectivityResult == ConnectivityResult.wifi) {
                    printerBLEOrWIFI = true;
                    Navigator.pushNamed(context, '/scan_list_printers');
                  } else {
                    myUvcToast.setToastDuration(2);
                    myUvcToast.setToastMessage(noWIFIConnectionToastTextLanguageArray[languageArrayIdentifier]);
                    myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
                  }
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
  }

  GestureDetector qrCodeGenerator({BuildContext context, String destination, String buttonTitle, String buttonText, String buttonDescription1, String buttonDescription2}) {
    double screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () async {
        if (destination == "/qr_code_scan") {
          await SuperEasyPermissions.askPermission(Permissions.camera);
        }
        Navigator.pushNamed(context, destination);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
          shape: RoundedRectangleBorder(side: new BorderSide(color: Colors.blue[400], width: 2.0), borderRadius: BorderRadius.circular(18.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                child: TextButton(
                  onPressed: () async {
                    if (destination == "/qr_code_scan") {
                      await SuperEasyPermissions.askPermission(Permissions.camera);
                    }
                    Navigator.pushNamed(context, destination);
                  },
                  child: Text(
                    buttonTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.05,
                    ),
                  ),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[400]),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  buttonText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.05,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Divider(
                  thickness: 2.0,
                  color: Colors.grey,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  buttonDescription1,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.black,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.05,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  buttonDescription2,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.05,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector qrCodeGeneratorSecond({BuildContext context, String destination, String buttonTitle, String buttonText}) {
    double screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        if (destination == "/Qr_code_Display") {
          qrCodeData = 'https://qrgo.page.link/hYgXu';
          qrCodeDataName = qrcodeSecurityTextLanguageArray[languageArrayIdentifier];
          qrCodeFileName = 'securityQrCode.png';
        }
        Navigator.pushNamed(context, destination);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
          shape: RoundedRectangleBorder(side: new BorderSide(color: Colors.blue[400], width: 2.0), borderRadius: BorderRadius.circular(18.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                child: TextButton(
                  onPressed: () {
                    if (destination == "/Qr_code_Display_Security") {
                      qrCodeData = 'https://qrgo.page.link/hYgXu';
                      qrCodeDataName = qrcodeSecurityTextLanguageArray[languageArrayIdentifier];
                      qrCodeFileName = 'securityQrCode.png';
                    }
                    Navigator.pushNamed(context, destination);
                  },
                  child: Text(
                    buttonTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.05,
                    ),
                  ),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[400]),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  buttonText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.05,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
