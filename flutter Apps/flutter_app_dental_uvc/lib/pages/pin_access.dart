import 'dart:io';
import 'dart:io' as io;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gifimage/flutter_gifimage.dart';
import 'package:flutterappdentaluvc/services/AutoUVCService.dart';
import 'package:flutterappdentaluvc/services/NFCManagerClass.dart';
import 'package:flutterappdentaluvc/services/bleDeviceClass.dart';
import 'package:flutterappdentaluvc/services/lifeCycleWidget.dart';
import 'package:flutterappdentaluvc/services/uvcToast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pinput/pin_put/pin_put.dart';

class AccessPin extends StatefulWidget {
  @override
  _AccessPinState createState() => _AccessPinState();
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

AutoUVCService autoUVCService = AutoUVCService();

class _AccessPinState extends State<AccessPin> with TickerProviderStateMixin {
  final TextEditingController _pinPutController = TextEditingController();

  String pinCode;
  String pinCodeAccess = '';
  String myPinCode = '';

  ToastyMessage myUvcToast;

  Animation colorInfoQrCode;

  GifController gifController;

  Device myDevice;

  Widget mainWidgetScreen;

  final int timeSleep = 120000;

  bool widgetIsInactive = false;

  int timeToSleep;

  bool firstDisplayMainWidget = true;

  Map pinAccessClassData = {};

  String dataRobotUVC = '';

  final String _uvcAutoDataFileName = 'UVC_Auto_Data.txt';

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: Colors.blue, width: 3),
      borderRadius: BorderRadius.circular(15),
    );
  }

  void readingNFCTags() async {
    NFCTagsManager nfcManager = NFCTagsManager();
    print(await nfcManager.checkNFCAvailibility());
    nfcManager.setContext(context);
    nfcManager.startNFCTask();
    print(nfcManager.nfcGetMessage());
  }

  void checkAutoFileExists() async {
    bool isExisted = false;
    final directory = await getApplicationDocumentsDirectory();
    isExisted = await io.File('${directory.path}/$_uvcAutoDataFileName').exists();
    if (isExisted) {
      autoUVCService.setContext(context);
      autoUVCService.startUVCService();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    gifController = GifController(vsync: this);

    readingNFCTags();

    checkAutoFileExists();

/*    WidgetsBinding.instance.addObserver(LifecycleEventHandler(
        resumeCallBack: () async => setState(() {
              Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
            })));*/

    myUvcToast = ToastyMessage(toastContext: context);
    //checks bluetooth current state
    Future.delayed(const Duration(seconds: 1), () async {
      pinCodeAccess = await _readPINFile();
    });
  }

  Widget appWidget(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    try {
      pinAccessClassData = pinAccessClassData.isNotEmpty ? pinAccessClassData : ModalRoute.of(context).settings.arguments;
      myDevice = pinAccessClassData['myDevice'];
      dataRobotUVC = pinAccessClassData['dataRead'];
      autoUVCService.setUVCDevice(myDevice);
    } catch (e) {
      print('its empty');
    }

    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.blue[400],
        appBar: AppBar(
          title: const Text('Code PIN'),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(color: Colors.grey[200]),
          child: Builder(
            builder: (context) {
              return Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Entrer le code de sécurité :',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: widthScreen * 0.04,
                        ),
                      ),
                      SizedBox(height: heightScreen * 0.05),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: SizedBox(height: heightScreen * 0.01)),
                          Expanded(
                            flex: 3,
                            child: Container(
                              margin: EdgeInsets.all(20),
                              padding: EdgeInsets.all(10),
                              child: PinPut(
                                fieldsCount: 4,
                                onSubmit: (String pin) => pinCode = pin,
                                focusNode: AlwaysDisabledFocusNode(),
                                controller: _pinPutController,
                                textStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: widthScreen * 0.04,
                                ),
                                submittedFieldDecoration: _pinPutDecoration.copyWith(borderRadius: BorderRadius.circular(20)),
                                selectedFieldDecoration: _pinPutDecoration,
                                followingFieldDecoration: _pinPutDecoration.copyWith(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: Colors.grey[600].withOpacity(.5), width: 3),
                                ),
                              ),
                            ),
                          ),
                          Expanded(flex: 1, child: SizedBox(height: heightScreen * 0.01)),
                        ],
                      ),
                      SizedBox(height: heightScreen * 0.05),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buttonNumbers('0', context),
                          SizedBox(width: widthScreen * 0.003),
                          buttonNumbers('1', context),
                          SizedBox(width: widthScreen * 0.003),
                          buttonNumbers('2', context),
                          SizedBox(width: widthScreen * 0.003),
                          buttonNumbers('3', context),
                          SizedBox(width: widthScreen * 0.003),
                          buttonNumbers('4', context),
                          SizedBox(width: widthScreen * 0.003),
                          buttonNumbers('5', context),
                          SizedBox(width: widthScreen * 0.003),
                          buttonNumbers('6', context),
                          SizedBox(width: widthScreen * 0.003),
                          buttonNumbers('7', context),
                          SizedBox(width: widthScreen * 0.003),
                          buttonNumbers('8', context),
                          SizedBox(width: widthScreen * 0.003),
                          buttonNumbers('9', context),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            widgetIsInactive = true;
            Navigator.pushNamed(context, '/advanced_settings', arguments: {
              'pinCodeAccess': pinCodeAccess,
              'myDevice': myDevice,
            });
          },
          label: Text('Réglages'),
          icon: Icon(
            Icons.settings,
            color: Colors.white,
          ),
          backgroundColor: Colors.blue[400],
        ),
      ),
      onWillPop: () => exitMessage(context),
    );
  }

  Widget sleepWidget(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    // loop from 0 frame to 29 frame
    gifController.repeat(min: 0, max: 11, period: Duration(milliseconds: 1000));
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.blue[400],
        body: Center(
          child: GifImage(
            controller: gifController,
            fit: BoxFit.cover,
            height: heightScreen,
            width: widthScreen,
            image: AssetImage('assets/logo-delitech-animation.gif'),
          ),
        ),
      ),
    );
  }

  void screenSleep(BuildContext context) async {
    timeToSleep = timeSleep;
    do {
      timeToSleep -= 1000;
      if (timeToSleep == 0) {
        setState(() {
          mainWidgetScreen = sleepWidget(context);
        });
      }

      if (timeToSleep < 0) {
        timeToSleep = (-1000);
      }

      if (widgetIsInactive) {
        break;
      }
      await Future.delayed(Duration(seconds: 1));
    } while (true);
  }

  @override
  Widget build(BuildContext context) {
    if (firstDisplayMainWidget) {
      mainWidgetScreen = appWidget(context);
      screenSleep(context);
      firstDisplayMainWidget = false;
    }
    return  GestureDetector(
        child: mainWidgetScreen,
        onTap: () {
          setState(() {
            timeToSleep = timeSleep;
            mainWidgetScreen = appWidget(context);
          });
        },
      );
  }

  ButtonTheme buttonNumbers(String number, BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return ButtonTheme(
      minWidth: widthScreen * 0.09,
      height: heightScreen * 0.07,
      child: FlatButton(
        color: Colors.grey[400],
        child: Text(
          number,
          style: TextStyle(
            color: Colors.white,
            fontSize: widthScreen * 0.02,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        onPressed: () async {
          myPinCode += number;
          _pinPutController.text += '*';
          if (_pinPutController.text.length == 4) {
            _showSnackBar(myPinCode, context);
            myPinCode = '';
          }
        },
      ),
    );
  }

  Future<void> exitMessage(BuildContext context) async {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: heightScreen * 0.005),
            Text(
              'Voulez-vous quittez l\'application ? Les désinfections programmées ne seront pas effectuées.',
              style: TextStyle(fontSize: (widthScreen * 0.02)),
            ),
            SizedBox(height: heightScreen * 0.005),
          ],
        ),
        actions: [
          FlatButton(
            child: Text(
              'Oui',
              style: TextStyle(fontSize: (widthScreen * 0.02)),
            ),
            onPressed: () {
              if (myDevice != null) {
                myDevice.disconnect();
              }
              Navigator.pop(c, true);
            },
          ),
          FlatButton(
            child: Text(
              'Non',
              style: TextStyle(fontSize: (widthScreen * 0.02)),
            ),
            onPressed: () => Navigator.pop(c, false),
          ),
        ],
      ),
    );
  }

  Future<String> _readPINFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/my_pin_code.txt');
      String pinCode = await file.readAsString();
      return pinCode;
    } catch (e) {
      print("Couldn't read file");
      _savePINFile('1234');
      return '1234';
    }
  }

  _savePINFile(String pinCode) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/my_pin_code.txt');
    await file.writeAsString(pinCode);
    print('saved');
  }

  @override
  void dispose() {
    gifController.dispose();
    super.dispose();
  }

  void _showSnackBar(String pin, BuildContext context) async {
    double widthScreen = MediaQuery.of(context).size.width;
    pinCodeAccess = await _readPINFile();
    String messagePin;
    Color messageColor;
    if (pin == pinCodeAccess && pin.isNotEmpty) {
      messagePin = 'Code valide';
      messageColor = Colors.green;
    } else {
      messagePin = 'Code non valide';
      messageColor = Colors.red;
    }
    _pinPutController.clear();
    final snackBar = SnackBar(
      duration: Duration(seconds: 2),
      content: Container(
          height: widthScreen * 0.1,
          child: Center(
            child: Text(
              messagePin,
              style: TextStyle(fontSize: 25.0),
            ),
          )),
      backgroundColor: messageColor,
      onVisible: () async {
        if (pin == pinCodeAccess && pin.isNotEmpty) {
          widgetIsInactive = true;
          if (dataRobotUVC.isEmpty) {
            myUvcToast.setToastDuration(3);
            myUvcToast.setToastMessage('Veuillez selectionner un dispositif UV-C dans la page \'Réglages\' !');
            myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
          } else {
            if (myDevice != null) {
              Navigator.pushNamed(context, '/profiles', arguments: {
                'myDevice': myDevice,
                'dataRead': myDevice.getReadCharMessage(),
              });
            }
          }
        }
      },
    );
    Scaffold.of(context).hideCurrentSnackBar();
    Scaffold.of(context).showSnackBar(snackBar);
  }
}
