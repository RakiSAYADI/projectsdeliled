import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_bispectrum/services/uvcToast.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:location_permissions/location_permissions.dart';

class CheckPermissions extends StatefulWidget {
  @override
  _CheckPermissionsState createState() => _CheckPermissionsState();
}

class _CheckPermissionsState extends State<CheckPermissions> with TickerProviderStateMixin {
  ToastyMessage myUvcToast;

  List<BluetoothDevice> scanDevices = [];

  FlutterBlue flutterBlue = FlutterBlue.instance;

  bool firstDisplayMainWidget = true;

  PermissionStatus _permissionStatus = PermissionStatus.unknown;

  @override
  void dispose() {
    super.dispose();
  }

  void _listenForPermissionStatus() async {
    bool connectionState = await checkConnection();
    if (!connectionState){
      myUvcToast.setToastDuration(5);
      myUvcToast.setToastMessage('Votre téléphone n\'est pas connecté sur internet !');
      myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
    }

    final Future<PermissionStatus> statusFuture = LocationPermissions().checkPermissionStatus();

    await statusFuture.then((PermissionStatus status) {
      setState(() {
        _permissionStatus = status;
        if (_permissionStatus.index != 2) {
          myUvcToast.setToastDuration(6);
          myUvcToast.setToastMessage('La localisation n\'est pas activée sur votre téléphone !');
          myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
        } else {
          checkServiceStatus(context);
        }
      });
    });
  }

  void checkServiceStatus(BuildContext context) {
    LocationPermissions().checkServiceStatus().then((ServiceStatus serviceStatus) {
      if (serviceStatus.index != 2) {
        myUvcToast.setToastDuration(6);
        myUvcToast.setToastMessage('La localisation n\'est pas activée sur votre téléphone !');
        myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
      }
    });
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
        print("Bluetooth is off");
        myUvcToast.setToastDuration(4);
        myUvcToast.setToastMessage('Le Bluetooth (BLE) n\'est pas activé sur votre téléphone !');
        myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
      } else if (state == BluetoothState.on) {
        //if bluetooth is enabled then go ahead.
        //Make sure user's device gps is on.
        flutterBlue = FlutterBlue.instance;
        print("Bluetooth is on");
      }
    });
  }

  Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      print('not connected');
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
          title: const Text('Permissions', style: TextStyle(fontSize: 18)),
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
                            'Afin de garantir le bon fonctionnement de l\'application merci d\'activer votre Bluetooth ainsi que votre localisation.',
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
                          child: FlatButton(
                            color: Colors.blue[400],
                            child: Text(
                              'COMPRIS',
                              style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.03),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            onPressed: () {
                              print('understood_key is pressed');
                              Navigator.pushNamed(context, '/home'); // scan_ble_list
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
      onWillPop: () => stopActivity(context),
    );
  }

  Future<void> stopActivity(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Attention'),
        content: Text('Voulez-vous vraiment quitter l\'application ?'),
        actions: [
          FlatButton(
            child: Text('Oui'),
            onPressed: () => Navigator.pop(c, true),
          ),
          FlatButton(
            child: Text('Non'),
            onPressed: () => Navigator.pop(c, false),
          ),
        ],
      ),
    );
  }
}
