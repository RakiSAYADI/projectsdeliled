import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:wifiglobalapp/services/data_variables.dart';
import 'package:wifiglobalapp/services/language_database.dart';
import 'package:wifiglobalapp/services/uvc_toast.dart';

class AccessPin extends StatefulWidget {
  const AccessPin({Key? key}) : super(key: key);

  @override
  _AccessPinState createState() => _AccessPinState();
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

class _AccessPinState extends State<AccessPin> {
  final TextEditingController _pinPutController = TextEditingController();

  Widget? mainWidgetScreen;

  int timeToSleep = 0;

  bool firstDisplayMainWidget = true;

  String pinCode = '';
  String myPinCode = '';

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: Colors.blue, width: 3),
      borderRadius: BorderRadius.circular(15),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (firstDisplayMainWidget) {
      debugPrint('build sleep page');
      mainWidgetScreen = appWidget(context);
      screenSleep(context);
      firstDisplayMainWidget = false;
    }
    return GestureDetector(
      child: mainWidgetScreen,
      onTap: () {
        setState(() {
          timeToSleep = timeSleep;
          mainWidgetScreen = appWidget(context);
        });
      },
    );
  }

  Widget appWidget(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.blue[400],
        appBar: AppBar(
          title: Text(pinCodeTitleTextLanguageArray[languageArrayIdentifier]),
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
                                  border: Border.all(color: Colors.grey[600]!.withOpacity(.5), width: 3),
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
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          buttonNumbers('0', context),
                          buttonNumbers('1', context),
                          buttonNumbers('2', context),
                          buttonNumbers('3', context),
                          buttonNumbers('4', context),
                          buttonNumbers('5', context),
                          buttonNumbers('6', context),
                          buttonNumbers('7', context),
                          buttonNumbers('8', context),
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
            sleepIsInactivePinAccess = true;
            Navigator.pushNamed(context, '/advanced_settings');
          },
          label: Text(settingsTextLanguageArray[languageArrayIdentifier], style: TextStyle(fontSize: heightScreen * 0.001 + widthScreen * 0.03)),
          icon: Icon(
            Icons.settings,
            color: Colors.white,
            size: heightScreen * 0.001 + widthScreen * 0.03,
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
    return WillPopScope(
      onWillPop: () => exitMessage(context),
      child: Scaffold(
        backgroundColor: Colors.blue[400],
        body: Center(
          child: Image.asset(
            'assets/logo-delitech-animation.gif',
            fit: BoxFit.cover,
            height: heightScreen,
            width: widthScreen,
          ),
        ),
      ),
    );
  }

  void screenSleep(BuildContext context) async {
    timeToSleep = timeSleep;
    do {
      if (sleepIsInactivePinAccess) {
        timeToSleep = timeSleep;
      } else {
        timeToSleep -= 1000;
        if (timeToSleep == 0) {
          try {
            setState(() {
              mainWidgetScreen = sleepWidget(context);
            });
          } catch (e) {
            debugPrint(e.toString());
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

  Expanded buttonNumbers(String number, BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ButtonTheme(
          minWidth: widthScreen * 0.09,
          height: heightScreen * 0.07,
          child: TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
              ),
              backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
            ),
            child: Text(
              number,
              style: TextStyle(
                color: Colors.white,
                fontSize: widthScreen * 0.02,
              ),
            ),
            onPressed: () async {
              timeToSleep = timeSleep;
              myPinCode += number;
              _pinPutController.text += '*';
              if (_pinPutController.text.length == 4) {
                _showSnackBar(myPinCode, context);
                myPinCode = '';
              }
            },
          ),
        ),
      ),
    );
  }

  exitMessage(BuildContext context) async {
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
              quitAppMessageTextLanguageArray[languageArrayIdentifier],
              style: TextStyle(fontSize: (widthScreen * 0.02)),
            ),
            SizedBox(height: heightScreen * 0.005),
          ],
        ),
        actions: [
          TextButton(
            child: Text(
              yesTextLanguageArray[languageArrayIdentifier],
              style: TextStyle(fontSize: (widthScreen * 0.02)),
            ),
            onPressed: () {
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            },
          ),
          TextButton(
            child: Text(
              noTextLanguageArray[languageArrayIdentifier],
              style: TextStyle(fontSize: (widthScreen * 0.02)),
            ),
            onPressed: () => Navigator.pop(c, false),
          ),
        ],
      ),
    );
  }

  _showSnackBar(String pin, BuildContext context) async {
    double widthScreen = MediaQuery.of(context).size.width;
    pinCodeAccess = await myPinCodeClass.readPINFile();
    String messagePin;
    Color messageColor;
    if (pin == pinCodeAccess && pin.isNotEmpty) {
      messagePin = validCodeTextLanguageArray[languageArrayIdentifier];
      messageColor = Colors.green;
    } else {
      messagePin = noValidCodeTextLanguageArray[languageArrayIdentifier];
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
          final bool result = await myDevice.getDeviceData();
          if (result) {
            sleepIsInactivePinAccess = true;
            ScaffoldMessenger.of(context).hideCurrentSnackBar(reason: SnackBarClosedReason.hide);
            if (myDevice.deviceCompanyName.isEmpty && myDevice.deviceRoomName.isEmpty && myDevice.deviceOperatorName.isEmpty) {
              await myDevice.getDeviceData();
            }
            Navigator.pushNamed(context, '/profiles');
          } else {
            ToastyMessage toastyMessage = ToastyMessage();
            toastyMessage.setContext(context);
            toastyMessage.setToastDuration(5);
            toastyMessage.setToastMessage('Connexion perdue avec dispositif !');
            toastyMessage.showToast(Colors.yellow, Icons.warning, Colors.white);
          }
        }
      },
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
