import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_ambimaestro/pages/scan_ble_list.dart';
import 'package:flutter_app_ambimaestro/services/animation_between_pages.dart';
import 'package:flutter_app_ambimaestro/services/data_variables.dart';
import 'package:flutter_app_ambimaestro/services/language_data_base.dart';
import 'package:flutter_app_ambimaestro/services/uvc_toast.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

class CheckPermissions extends StatefulWidget {
  const CheckPermissions({Key? key}) : super(key: key);

  @override
  _CheckPermissionsState createState() => _CheckPermissionsState();
}

class _CheckPermissionsState extends State<CheckPermissions> {
  ToastyMessage? myUvcToast;

  List<BluetoothDevice> scanDevices = [];

  FlutterBlue flutterBlue = FlutterBlue.instance;

  bool firstDisplayMainWidget = true;
  bool bluetoothState = false;

  void _listenForPermissionStatus() async {
    bool connectionState = await checkConnection();
    if (!connectionState) {
      myUvcToast!.setToastDuration(5);
      myUvcToast!.setToastMessage(internetToastLanguageArray[languageArrayIdentifier]);
      myUvcToast!.showToast(Colors.red, Icons.close, Colors.white);
    }
    await Permission.locationWhenInUse.request();
    await Permission.locationAlways.request();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myUvcToast = ToastyMessage(toastContext: context);
    _listenForPermissionStatus();
    flutterBlue.state.listen((state) {
      if (state == BluetoothState.off) {
        //Alert user to turn on bluetooth.
        debugPrint("Bluetooth is off");
        myUvcToast!.setToastDuration(4);
        myUvcToast!.setToastMessage(bluetoothToastLanguageArray[languageArrayIdentifier]);
        myUvcToast!.showToast(Colors.red, Icons.close, Colors.white);
        bluetoothState = false;
      } else if (state == BluetoothState.on) {
        //if bluetooth is enabled then go ahead.
        //Make sure user's device gps is on.
        flutterBlue = FlutterBlue.instance;
        debugPrint("Bluetooth is on");
        bluetoothState = true;
      }
    });
  }

  Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        debugPrint('connected');
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      debugPrint('not connected');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.blue[400],
        appBar: AppBar(
          title: Text(checkPermissionTitleTextLanguageArray[languageArrayIdentifier], style: const TextStyle(fontSize: 18)),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(color: Colors.grey[200]),
          child: Builder(
            builder: (context) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            checkPermissionMessageTextLanguageArray[languageArrayIdentifier],
                            overflow: TextOverflow.fade,
                            maxLines: 2,
                            softWrap: true,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: screenWidth * 0.02,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Image.asset(
                            'assets/loading_Bluetooth.gif',
                            height: screenHeight * 0.3,
                            width: screenWidth * 0.8,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextButton(
                            child: Text(
                              understoodTextLanguageArray[languageArrayIdentifier],
                              style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.03),
                            ),
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[400]!),
                            ),
                            onPressed: () {
                              debugPrint('understood_key is pressed');
                              if (bluetoothState) {
                                createRoute(context, const ScanListBle());
                              } else {
                                myUvcToast!.setToastDuration(4);
                                myUvcToast!.setToastMessage(bluetoothToastLanguageArray[languageArrayIdentifier]);
                                myUvcToast!.showToast(Colors.red, Icons.close, Colors.white);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      onWillPop: () {
        stopActivity(context);
        return Future.value(true);
      },
    );
  }

  Future<void> stopActivity(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(attentionTextLanguageArray[languageArrayIdentifier]),
        content: Text(stopActivityAlertDialogMessageTextLanguageArray[languageArrayIdentifier]),
        actions: [
          TextButton(
            child: Text(yesTextLanguageArray[languageArrayIdentifier]),
            onPressed: () => Navigator.pop(c, true),
          ),
          TextButton(
            child: Text(noTextLanguageArray[languageArrayIdentifier]),
            onPressed: () => Navigator.pop(c, false),
          ),
        ],
      ),
    );
  }
}
