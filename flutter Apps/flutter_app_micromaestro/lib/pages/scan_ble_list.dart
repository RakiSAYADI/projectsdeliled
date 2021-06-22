import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterappmicromaestro/services/bleDeviceClass.dart';
import 'package:flutterappmicromaestro/services/deviceBleWidget.dart';
import 'package:flutterappmicromaestro/services/uvcToast.dart';

class ScanListBle extends StatefulWidget {
  @override
  _ScanListBleState createState() => _ScanListBleState();
}

class _ScanListBleState extends State<ScanListBle> {
  List<Device> devices = [];

  ToastyMessage myUvcToast;

  ///Initialisation and listening to device state

  BluetoothDeviceState deviceState;
  FlutterBlue flutterBlue = FlutterBlue.instance;
  Device myDevice;

  BluetoothDevice device;
  BluetoothDevice myDeviceBluetooth;
  BluetoothCharacteristic characteristicMaestro;

  @override
  void initState() {
    super.initState();
    myUvcToast = ToastyMessage(toastContext: context);

    //checks bluetooth current state
    flutterBlue.state.listen((state) {
      if (state == BluetoothState.off) {
        //Alert user to turn on bluetooth.
        print("Bluetooth is off");
        myUvcToast.setToastDuration(5);
        myUvcToast.setToastMessage('Le Bluetooth (BLE) sur votre téléphone n\'est pas activé !');
        myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
      } else if (state == BluetoothState.on) {
        //if bluetooth is enabled then go ahead.
        //Make sure user's device gps is on.
        flutterBlue = FlutterBlue.instance;
        print("Bluetooth is on");
        scanForDevices();
      }
    });
  }

  List<String> scanIdentifiers = [];

  void scanForDevices() {
    // Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 5));
    // Listen to scan results
    flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results) {
        print('${r.device.name} found! mac: ${r.device.id.toString()}');
        if (scanIdentifiers.isEmpty) {
          scanIdentifiers.add(r.device.id.toString());
          setState(() {
            devices.add(Device(device: r.device));
          });
        } else {
          if (!scanIdentifiers.contains(r.device.id.toString())) {
            scanIdentifiers.add(r.device.id.toString());
            setState(() {
              devices.add(Device(device: r.device));
            });
          }
        }
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Liste des UVC-LIGHT :'),
        centerTitle: true,
        backgroundColor: Colors.indigo[700],
      ),
      floatingActionButton: StreamBuilder<bool>(
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
                    devices.clear();
                  });
                  scanIdentifiers.clear();
                  flutterBlue.startScan(timeout: Duration(seconds: 4));
                });
          }
        },
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
            children: devices
                .map((device) => DeviceCard(
                    device: device,
                    connect: () async {
                      setState(() {
                        myDeviceBluetooth = device.device;
                      });
                      // display Toast message
                      myDevice = Device(device: myDeviceBluetooth);
                      try {
                        myUvcToast.clearAllToast();
                      } catch (e) {
                        print(e);
                      }
                      waitingWidget();
                      String deviceName = myDeviceBluetooth.name;
                      // stop scanning and start connecting
                      await flutterBlue.stopScan();
                      bool resultConnection = false;
                      while (true) {
                        myDevice.connect(autoConnect: true);
                        await Future.delayed(Duration(seconds: 2));
                        resultConnection = myDevice.getConnectionState();
                        if (resultConnection) {
                          break;
                        }
                        print('result of trying connection is $resultConnection');
                        myDevice.disconnect();
                        await Future.delayed(Duration(seconds: 2));
                      }
                      myUvcToast.setToastDuration(60);
                      myUvcToast.setToastMessage('Connexion à $deviceName !');
                      myUvcToast.showToast(Colors.green, Icons.autorenew, Colors.white);
                      if (resultConnection) {
                        //Discover services
                        List<BluetoothService> services = await myDeviceBluetooth.discoverServices();
                        BluetoothService service;
                        service = services.elementAt(2);
                        // Read the first characteristic
                        characteristicMaestro = service.characteristics[0];
                        // reading the characteristic after 1 second
                        Future.delayed(const Duration(seconds: 1), () async {
                          String dataMaestro = String.fromCharCodes(await characteristicMaestro.read());
                          print(dataMaestro);
                          // clear the remaining toast message
                          myUvcToast.clearCurrentToast();
                          Navigator.pushNamed(context, '/home', arguments: {
                            'bleDevice': myDevice,
                            'characteristicMaestro': characteristicMaestro,
                          });
                        });
                      }
                    }))
                .toList()),
      ),
    );
  }

  Future<void> waitingWidget() async {
    //double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Connexion en cours'),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SpinKitCircle(
                  color: Colors.blue[600],
                  size: screenHeight * 0.1,
                ),
              ],
            ),
          );
        });
  }
}
