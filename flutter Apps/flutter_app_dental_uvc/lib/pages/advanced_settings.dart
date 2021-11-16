import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterappdentaluvc/services/AutoUVCService.dart';
import 'package:flutterappdentaluvc/services/CSVfileClass.dart';
import 'package:flutterappdentaluvc/services/DataVariables.dart';
import 'package:flutterappdentaluvc/services/uvcToast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pinput/pin_put/pin_put.dart';

class AdvancedSettings extends StatefulWidget {
  @override
  _AdvancedSettingsState createState() => _AdvancedSettingsState();
}

class _AdvancedSettingsState extends State<AdvancedSettings> {
  final TextEditingController _pinPutController = TextEditingController();

  String pinCode;
  String myPinCode = '';

  ToastyMessage myUvcToast;

  UVCDataFile uvcDataFile = UVCDataFile();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myUvcToast = ToastyMessage(toastContext: context);
    autoUVCService.setContext(context);
  }

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;

    return WillPopScope(
      child: Container(
        child: Scaffold(
          appBar: AppBar(
            title: Text('Paramètres'),
            centerTitle: true,
          ),
          body: Container(
            decoration: BoxDecoration(color: Colors.grey[200]),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: heightScreen * 0.05),
                    FlatButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/pin_settings');
                      },
                      child: Text(
                        'Changer le mot de passe',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widthScreen * 0.05,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      color: Colors.blue[400],
                    ),
                    SizedBox(height: heightScreen * 0.05),
                    FlatButton(
                      onPressed: () {
                        alertSecurity(context, 'scanlist');
                      },
                      child: Text(
                        'Changer de dispositif UV-C',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widthScreen * 0.05,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      color: Colors.blue[400],
                    ),
                    SizedBox(height: heightScreen * 0.05),
                    FlatButton(
                      onPressed: () async {
                        String macRobotUVC = '';
                        macRobotUVC = await uvcDataFile.readUVCDevice();
                        if (macRobotUVC.isEmpty) {
                          myUvcToast.setToastDuration(3);
                          myUvcToast.setToastMessage('Veuillez associer un dispositif UV-C !');
                          myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
                        } else {
                          alertSecurity(context, 'autouvc');
                        }
                      },
                      child: Text(
                        'Planning de désinfection',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widthScreen * 0.05,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      color: Colors.blue[400],
                    ),
                    SizedBox(height: heightScreen * 0.05),
                    FlatButton(
                      onPressed: () async {
                        uvcData = await uvcDataFile.readUVCDATA();
                        print("the uvc data file : $uvcData");
                        Navigator.pushNamed(context, '/DataCSVSettingsView');
                      },
                      child: Text(
                        'Rapport Désinfection',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widthScreen * 0.05,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      color: Colors.blue[400],
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).pop();
              sleepIsInactivePinAccess = false;
            },
            label: Text('Retour'),
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
            ),
            backgroundColor: Colors.blue[400],
          ),
        ),
      ),
      onWillPop: () => activatingSleep(context),
    );
  }

  Future<bool> activatingSleep(BuildContext context) async {
    sleepIsInactivePinAccess = false;
    Navigator.pop(context, true);
    return true;
  }

  Future<void> alertSecurity(BuildContext context, String accessPath) async {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;

    return showDialog<void>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
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
                              buttonNumbers('0', context, accessPath),
                              SizedBox(width: widthScreen * 0.003),
                              buttonNumbers('1', context, accessPath),
                              SizedBox(width: widthScreen * 0.003),
                              buttonNumbers('2', context, accessPath),
                              SizedBox(width: widthScreen * 0.003),
                              buttonNumbers('3', context, accessPath),
                              SizedBox(width: widthScreen * 0.003),
                              buttonNumbers('4', context, accessPath),
                              SizedBox(width: widthScreen * 0.003),
                              buttonNumbers('5', context, accessPath),
                              SizedBox(width: widthScreen * 0.003),
                              buttonNumbers('6', context, accessPath),
                              SizedBox(width: widthScreen * 0.003),
                              buttonNumbers('7', context, accessPath),
                              SizedBox(width: widthScreen * 0.003),
                              buttonNumbers('8', context, accessPath),
                              SizedBox(width: widthScreen * 0.003),
                              buttonNumbers('9', context, accessPath),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        });
  }

  ButtonTheme buttonNumbers(String number, BuildContext context, String accessPath) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return ButtonTheme(
      minWidth: widthScreen * 0.07,
      height: heightScreen * 0.05,
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
            pinCodeAccess = await _readPINFile();
            //_showSnackBar(myPinCode, context);
            if (myPinCode == pinCodeAccess) {
              Navigator.pop(context);
              switch (accessPath) {
                case 'scanlist':
                  Navigator.pushNamed(context, '/scan_ble_list');
                  break;
                case 'autouvc':
                  if (myDevice != null) {
                    Navigator.pushNamed(context, '/auto_uvc');
                  } else {
                    myUvcToast.setToastDuration(3);
                    myUvcToast.setToastMessage('Veuillez associer un dispositif UV-C !');
                    myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
                  }

                  break;
              }
            } else {
              myUvcToast.setToastDuration(3);
              myUvcToast.setToastMessage('Code Invalide !');
              myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
            }
            _pinPutController.text = '';
            myPinCode = '';
          }
        },
      ),
    );
  }

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: Colors.blue, width: 3),
      borderRadius: BorderRadius.circular(15),
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
      return '1234';
    }
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
