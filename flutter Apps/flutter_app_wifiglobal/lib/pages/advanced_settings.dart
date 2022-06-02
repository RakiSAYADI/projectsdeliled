import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:wifiglobalapp/services/csv_file_class.dart';
import 'package:wifiglobalapp/services/data_variables.dart';
import 'package:wifiglobalapp/services/language_database.dart';
import 'package:wifiglobalapp/services/uvc_toast.dart';

class AdvancedSettings extends StatefulWidget {
  @override
  _AdvancedSettingsState createState() => _AdvancedSettingsState();
}

class _AdvancedSettingsState extends State<AdvancedSettings> {
  final TextEditingController _pinPutController = TextEditingController();

  String myPinCode = '';
  String pinCode = '';

  ToastyMessage myUvcToast = ToastyMessage();

  UVCDataFile uvcDataFile = UVCDataFile();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myUvcToast.setContext(context);
  }

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;

    return WillPopScope(
      child: Container(
        child: Scaffold(
          appBar: AppBar(
            title: Text(parametersTextLanguageArray[languageArrayIdentifier]),
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
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/pin_settings');
                      },
                      child: Text(
                        changePasswordTextLanguageArray[languageArrayIdentifier],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widthScreen * 0.05,
                        ),
                      ),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                      ),
                    ),
                    /*SizedBox(height: heightScreen * 0.05),
                    TextButton(
                      onPressed: () async {
                        alertSecurity(context, 'autouvc');
                      },
                      child: Text(
                        planningTextLanguageArray[languageArrayIdentifier],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widthScreen * 0.05,
                        ),
                      ),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                      ),
                    ),*/
                    SizedBox(height: heightScreen * 0.05),
                    TextButton(
                      onPressed: () async {
                        uvcData = await uvcDataFile.readUVCDATA();
                        print("the uvc data file : $uvcData");
                        openWithSettings = true;
                        Navigator.pushNamed(context, '/rapport_modification');
                      },
                      child: Text(
                        rapportTextLanguageArray[languageArrayIdentifier],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widthScreen * 0.05,
                        ),
                      ),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                      ),
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
            label: Text(backTextLanguageArray[languageArrayIdentifier]),
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
                                      border: Border.all(color: Colors.grey.withOpacity(.5), width: 3),
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
          backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
        ),
        onPressed: () async {
          myPinCode += number;
          _pinPutController.text += '*';
          if (_pinPutController.text.length == 4) {
            pinCodeAccess = await myPinCodeClass.readPINFile();
            //_showSnackBar(myPinCode, context);
            if (myPinCode == pinCodeAccess) {
              Navigator.pop(context);
              switch (accessPath) {
                case 'autouvc':
                  Navigator.pushNamed(context, '/auto_uvc');
                  break;
              }
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

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: Colors.blue, width: 3),
      borderRadius: BorderRadius.circular(15),
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}