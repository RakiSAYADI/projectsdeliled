import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gifimage/flutter_gifimage.dart';
import 'package:flutterappdentaluvc/services/CSVfileClass.dart';
import 'package:flutterappdentaluvc/services/DataVariables.dart';
import 'package:flutterappdentaluvc/services/LEDControl.dart';
import 'package:flutterappdentaluvc/services/languageDataBase.dart';
import 'package:flutterappdentaluvc/services/uvcToast.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pinput/pin_put/pin_put.dart';

class EndUVC extends StatefulWidget {
  @override
  _EndUVCState createState() => _EndUVCState();
}

class _EndUVCState extends State<EndUVC> with TickerProviderStateMixin {
  final TextEditingController _pinPutController = TextEditingController();

  String pinCodeAccess = '';
  String pinCode;
  String myPinCode = '';

  UVCDataFile uvcDataFile;

  LedControl ledControl;

  Widget mainWidgetScreen;

  bool firstDisplayMainWidget = true;

  int timeToSleep;

  ToastyMessage myUvcToast;

  @override
  void initState() {
    // TODO: implement initState
    gifController = GifController(vsync: this);
    myUvcToast = ToastyMessage(toastContext: context);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    gifController.dispose();
    super.dispose();
  }

  void csvDataFile() async {
    uvcDataFile = UVCDataFile();
    if (Platform.isAndroid) {
      ledControl = LedControl();
    }
    uvcData = await uvcDataFile.readUVCDATA();
    List<String> uvcOperationData = ['default'];
    uvcOperationData.length = 0;

    uvcOperationData.add(myUvcLight.getMachineName());
    uvcOperationData.add(myUvcLight.getOperatorName());
    uvcOperationData.add(myUvcLight.getCompanyName());
    uvcOperationData.add(myUvcLight.getRoomName());

    var dateTime = new DateTime.now();
    DateFormat dateFormat;
    DateFormat timeFormat;
    initializeDateFormatting();
    dateFormat = new DateFormat.yMd('fr');
    timeFormat = new DateFormat.Hm('fr');
    uvcOperationData.add(timeFormat.format(dateTime));
    uvcOperationData.add(dateFormat.format(dateTime));

    uvcOperationData.add(activationTime.toString());

    if (Platform.isAndroid) {
      await ledControl.setLedColor('ON');
    }
    await Future.delayed(const Duration(milliseconds: 50));

    if (isTreatmentCompleted) {
      uvcOperationData.add(validTextLanguageArray[languageArrayIdentifier]);
      if (Platform.isAndroid) {
        await ledControl.setLedColor('GREEN');
      }
    } else {
      uvcOperationData.add(incidentTextLanguageArray[languageArrayIdentifier]);
      if (Platform.isAndroid) {
        await ledControl.setLedColor('RED');
      }
    }

    uvcData.add(uvcOperationData);

    await uvcDataFile.saveUVCDATA(uvcData);
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
      if (sleepIsInactiveEndUVC) {
        timeToSleep = timeSleep;
      } else {
        timeToSleep -= 1000;
        if (timeToSleep == 0) {
          try {
            setState(() {
              mainWidgetScreen = sleepWidget(context);
            });
          } catch (e) {
            print(e.message);
            break;
          }
        }
        if (timeToSleep < 0) {
          timeToSleep = (-1000);
        }
      }
      await Future.delayed(Duration(seconds: 1));
    } while (true);
  }

  Widget appWidget(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;

    String title;
    String message;
    String imageGif;

    if (isTreatmentCompleted) {
      title = disinfectionGoodStateTextLanguageArray[languageArrayIdentifier];
      message = disinfectionGoodStateMessageTextLanguageArray[languageArrayIdentifier];
      imageGif = 'assets/felicitation_animation.gif';
    } else {
      title = disinfectionBadStateTextLanguageArray[languageArrayIdentifier];
      message = disinfectionBadStateMessageTextLanguageArray[languageArrayIdentifier];
      imageGif = 'assets/echec_logo.gif';
    }

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(color: Colors.grey[200]),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: widthScreen * 0.06,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: heightScreen * 0.05),
                  Image.asset(
                    imageGif,
                    height: heightScreen * 0.2,
                    width: widthScreen * 0.8,
                  ),
                  SizedBox(height: heightScreen * 0.05),
                  TextButton(
                    onPressed: () {
                      //myDevice.disconnect();
                      Navigator.pushNamedAndRemoveUntil(context, "/pin_access", (r) => false);
                    },
                    child: Text(
                      newDisinfectionTextLanguageArray[languageArrayIdentifier],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: widthScreen * 0.05,
                      ),
                    ),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[400]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            sleepIsInactiveEndUVC = true;
            openWithSettings = false;
            Navigator.pushNamed(context, '/rapport_modification');
          },
          label: Text(reportTextLanguageArray[languageArrayIdentifier]),
          icon: Icon(
            Icons.assignment,
            color: Colors.white,
          ),
          backgroundColor: Colors.blue[400],
        ),
      ),
      onWillPop: () => exitApp(context),
    );
  }

  BuildContext myContext;

  @override
  Widget build(BuildContext context) {
    if (firstDisplayMainWidget) {
      firstDisplayMainWidget = false;
      csvDataFile();
      mainWidgetScreen = appWidget(context);
      screenSleep(context);
      myContext = context;
    }

    return GestureDetector(
      child: mainWidgetScreen,
      onTap: () {
        setState(() {
          if (timeToSleep <= 0) {
            alertSecurity(context);
          }
        });
      },
    );
  }

  Future<void> alertSecurity(BuildContext context) async {
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
                            enterSecurityCodeTextLanguageArray[languageArrayIdentifier],
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
          );
        });
  }

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: Colors.blue, width: 3),
      borderRadius: BorderRadius.circular(15),
    );
  }

  ButtonTheme buttonNumbers(String number, BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return ButtonTheme(
      minWidth: widthScreen * 0.07,
      height: heightScreen * 0.05,
      child: TextButton(
        child: Text(
          number,
          style: TextStyle(
            color: Colors.white,
            fontSize: widthScreen * 0.02,
          ),
        ),
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[400]),
        ),
        onPressed: () async {
          myPinCode += number;
          _pinPutController.text += '*';
          if (_pinPutController.text.length == 4) {
            pinCodeAccess = await _readPINFile();
            //_showSnackBar(myPinCode, context);
            if (myPinCode == pinCodeAccess) {
              Navigator.pop(context);
              setState(() {
                timeToSleep = timeSleep;
                mainWidgetScreen = appWidget(myContext);
              });
            } else {
              myUvcToast.setToastDuration(3);
              myUvcToast.setToastMessage(invalidPinCodeTextLanguageArray[languageArrayIdentifier]);
              myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
            }
            _pinPutController.text = '';
            myPinCode = '';
          }
        },
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
      return '1234';
    }
  }

  Future<bool> exitApp(BuildContext context) async {
    sleepIsInactiveEndUVC = true;
    Navigator.pushNamedAndRemoveUntil(context, "/pin_access", (r) => false);
    return true;
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
