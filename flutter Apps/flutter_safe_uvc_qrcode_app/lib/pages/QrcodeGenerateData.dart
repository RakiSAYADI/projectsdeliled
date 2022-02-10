import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/DataVariables.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/languageDataBase.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/uvcToast.dart';

class QrCodeGeneratorData extends StatefulWidget {
  @override
  _QrCodeGeneratorDataState createState() => _QrCodeGeneratorDataState();
}

class _QrCodeGeneratorDataState extends State<QrCodeGeneratorData> with TickerProviderStateMixin {
  ToastyMessage myUvcToast;
  AnimationController animationRefreshIcon;

  final myEmail = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.blue[400],
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        centerTitle: true,
        title: Text(informationTitleTextLanguageArray[languageArrayIdentifier]),
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: screenHeight * 0.01),
                Image.asset(
                  'assets/adresse-mail-logo.png',
                  height: screenHeight * 0.09,
                  width: screenWidth * 0.5,
                ),
                SizedBox(height: screenHeight * 0.01),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.2)),
                  child: TextField(
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    maxLength: 64,
                    controller: myEmail,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey[800],
                    ),
                    decoration: InputDecoration(
                        hintText: emailAddressTextLanguageArray[languageArrayIdentifier],
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        )),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                TextButton(
                  onPressed: () async {
                    if (myEmail.text.isNotEmpty && RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9.*+-_]+\.[a-zA-Z]+").hasMatch(myEmail.text)) {
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                      animationRefreshIcon.repeat();
                      myUvcToast.setAnimationIcon(animationRefreshIcon);
                      myUvcToast.setToastDuration(5);
                      myUvcToast.setToastMessage(generateQrCodeToastTextLanguageArray[languageArrayIdentifier]);
                      myUvcToast.showToast(Colors.green, Icons.autorenew, Colors.white);
                      qrCodeFileName = 'QrCode_${myEmail.text}.png';
                      qrCodeData = '{\"SAFEUVCDATA\":\"${myEmail.text}\"}';
                      await Future.delayed(Duration(seconds: 5), () async {
                        myUvcToast.clearAllToast();
                        qrCodeDataName = myEmail.text;
                        saveToPrint = true;
                        Navigator.pushNamed(context, '/Qr_code_Display');
                      });
                    } else {
                      myUvcToast.setToastDuration(10);
                      myUvcToast.setToastMessage(emailAddressNonValidToastTextLanguageArray[languageArrayIdentifier]);
                      myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
                    }
                  },
                  child: Text(
                    generateTextLanguageArray[languageArrayIdentifier],
                    style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.06),
                  ),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[400]),
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    myUvcToast = ToastyMessage(toastContext: context);
    // initialise the animation
    animationRefreshIcon = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 3),
    );
    super.initState();
  }

  @override
  void dispose() {
    animationRefreshIcon.dispose();
    myEmail.dispose();
    super.dispose();
  }
}
