import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterappdentaluvc/services/uvcToast.dart';
import 'package:flutterappdentaluvc/services/DataVariables.dart';
import 'package:path_provider/path_provider.dart';

class PinSettings extends StatefulWidget {
  @override
  _PinSettingsState createState() => _PinSettingsState();
}

class _PinSettingsState extends State<PinSettings> {

  final myOldPinCode = TextEditingController();
  final myNewPinCode = TextEditingController();
  final myRenewPinCode = TextEditingController();

  ToastyMessage myUvcToast;

  @override
  void initState() {
    // TODO: implement initState
    myUvcToast = ToastyMessage(toastContext: context);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    myOldPinCode.dispose();
    myNewPinCode.dispose();
    myRenewPinCode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.blue[400],
      appBar: AppBar(
        title: const Text('Paramètres'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Builder(builder: (context) {
          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Entrer l\'ancien code de sécurité: ',
                    style: TextStyle(fontSize: (widthScreen * 0.02)),
                  ),
                  SizedBox(height: heightScreen * 0.05),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: (widthScreen * 0.2)),
                    child: TextField(
                      textAlign: TextAlign.center,
                      controller: myOldPinCode,
                      style: TextStyle(
                        fontSize: widthScreen * 0.02,
                      ),
                      maxLines: 1,
                      maxLength: 4,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          hintText: '',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          )),
                    ),
                  ),
                  SizedBox(height: heightScreen * 0.1),
                  Text(
                    'Entrer le nouveau code de sécurité : ',
                    style: TextStyle(fontSize: (widthScreen * 0.02)),
                  ),
                  SizedBox(height: heightScreen * 0.05),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: (widthScreen * 0.2)),
                    child: TextField(
                      textAlign: TextAlign.center,
                      controller: myNewPinCode,
                      style: TextStyle(
                        fontSize: widthScreen * 0.02,
                      ),
                      maxLines: 1,
                      maxLength: 4,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          hintText: '',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          )),
                    ),
                  ),
                  SizedBox(height: heightScreen * 0.1),
                  Text(
                    'Rentrer le nouveau code de sécurité : ',
                    style: TextStyle(fontSize: (widthScreen * 0.02)),
                  ),
                  SizedBox(height: heightScreen * 0.05),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: (widthScreen * 0.2)),
                    child: TextField(
                      textAlign: TextAlign.center,
                      controller: myRenewPinCode,
                      style: TextStyle(
                        fontSize: widthScreen * 0.02,
                      ),
                      maxLines: 1,
                      maxLength: 4,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          hintText: '',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          )),
                    ),
                  ),
                  SizedBox(height: heightScreen * 0.05),
                  FlatButton(
                    color: Colors.blue[400],
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'VALIDER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widthScreen * 0.02,
                        ),
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    onPressed: () async {
                      if ((myOldPinCode.text.length == 0 || myOldPinCode.text.length < 4) ||
                          ((myNewPinCode.text.length == 0 || myNewPinCode.text.length < 4))) {
                        myUvcToast.setToastDuration(2);
                        myUvcToast.setToastMessage('Veuillez remplir les champs ci-dessus !');
                        myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
                      } else {
                        if (myOldPinCode.text == pinCodeAccess ) {
                          if(myNewPinCode.text == myRenewPinCode.text){
                            _savePINFile(myNewPinCode.text);
                            myUvcToast.setToastDuration(2);
                            myUvcToast.setToastMessage('Merci, Le changement de mot de passe a été pris en compte !');
                            myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
                            myOldPinCode.text = '';
                            myNewPinCode.text = '';
                            myRenewPinCode.text = '';
                            Navigator.pop(context, true);
                          }else{
                            myUvcToast.setToastDuration(2);
                            myUvcToast.setToastMessage('Les codes sont différentes, Veuillez réssayer !');
                            myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
                          }
                        } else {
                          myUvcToast.setToastDuration(2);
                          myUvcToast.setToastMessage('L\'ancien code de sécurité n\'est pas correct !');
                          myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  _savePINFile(String pinCode) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/my_pin_code.txt');
    await file.writeAsString(pinCode);
    print('saved');
  }
}
