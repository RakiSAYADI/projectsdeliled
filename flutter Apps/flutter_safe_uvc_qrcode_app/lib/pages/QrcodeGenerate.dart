import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/languageDataBase.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/uvcToast.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/DataVariables.dart';

class QrCodeGenerator extends StatefulWidget {
  @override
  _QrCodeGeneratorState createState() => _QrCodeGeneratorState();
}

class _QrCodeGeneratorState extends State<QrCodeGenerator> with TickerProviderStateMixin {
  ToastyMessage myUvcToast;
  AnimationController animationRefreshIcon;

  final myCompany = TextEditingController();
  final myName = TextEditingController();
  final myRoomName = TextEditingController();

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
                  'assets/etablissement_logo.png',
                  height: screenHeight * 0.09,
                  width: screenWidth * 0.5,
                ),
                SizedBox(height: screenHeight * 0.01),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.2)),
                  child: TextField(
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    maxLength: 15,
                    controller: myCompany,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey[800],
                    ),
                    decoration: InputDecoration(
                        hintText: establishmentHintTextLanguageArray[languageArrayIdentifier],
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        )),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                Image.asset(
                  'assets/operateur_logo.png',
                  height: screenHeight * 0.09,
                  width: screenWidth * 0.5,
                ),
                SizedBox(height: screenHeight * 0.01),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.2)),
                  child: TextField(
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    maxLength: 15,
                    controller: myName,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey[800],
                    ),
                    decoration: InputDecoration(
                        hintText: userHintTextLanguageArray[languageArrayIdentifier],
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        )),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                Image.asset(
                  'assets/piece_logo.png',
                  height: screenHeight * 0.09,
                  width: screenWidth * 0.5,
                ),
                SizedBox(height: screenHeight * 0.01),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.2)),
                  child: TextField(
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    maxLength: 15,
                    controller: myRoomName,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                    ),
                    decoration: InputDecoration(
                        hintText: roomHintTextLanguageArray[languageArrayIdentifier],
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        )),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                Image.asset(
                  'assets/delais_logo.png',
                  height: screenHeight * 0.09,
                  width: screenWidth * 0.5,
                ),
                SizedBox(height: screenHeight * 0.03),
                Text(
                  beforeStartTextLanguageArray[languageArrayIdentifier],
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.black,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
                  child: DropdownButton<String>(
                    value: myActivationTimeMinuteData,
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.grey[800], fontSize: 18),
                    underline: Container(
                      height: 2,
                      color: Colors.blue[300],
                    ),
                    onChanged: (String data) {
                      setState(() {
                        myActivationTimeMinuteData = data;
                        myActivationTimeMinutePosition = myActivationTimeMinute.indexOf(data);
                      });
                    },
                    items: myActivationTimeMinute.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                Image.asset(
                  'assets/duree_logo.png',
                  height: screenHeight * 0.09,
                  width: screenWidth * 0.5,
                ),
                SizedBox(height: screenHeight * 0.03),
                Text(
                  durationDisinfectionTextLanguageArray[languageArrayIdentifier],
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.black,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
                  child: DropdownButton<String>(
                    value: myExtinctionTimeMinuteData,
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.grey[800], fontSize: 18),
                    underline: Container(
                      height: 2,
                      color: Colors.blue[300],
                    ),
                    onChanged: (String data) {
                      setState(() {
                        myExtinctionTimeMinuteData = data;
                        myExtinctionTimeMinutePosition = myExtinctionTimeMinute.indexOf(data);
                      });
                    },
                    items: myExtinctionTimeMinute.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                TextButton(
                  onPressed: () async {
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                    animationRefreshIcon.repeat();
                    myUvcToast.setAnimationIcon(animationRefreshIcon);
                    myUvcToast.setToastDuration(10);
                    myUvcToast.setToastMessage(generateQrCodeToastTextLanguageArray[languageArrayIdentifier]);
                    myUvcToast.showToast(Colors.green, Icons.autorenew, Colors.white);
                    qrCodeFileName = 'QrCode_${myCompany.text}_${myName.text}_${myRoomName.text}.png';
                    qrCodeData = '{\"Company\":\"${myCompany.text}\",\"UserName\":\"${myName.text}\",\"RoomName\":\"${myRoomName.text}\",'
                        '\"TimeData\":[$myExtinctionTimeMinutePosition,$myActivationTimeMinutePosition]}';
                    await Future.delayed(Duration(seconds: 5), () async {
                      myUvcToast.clearAllToast();
                      qrCodeDataName = myRoomName.text;
                      saveToPrint = true;
                      Navigator.pushNamed(context, '/Qr_code_Display');
                    });
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
    myCompany.dispose();
    myName.dispose();
    myRoomName.dispose();
    super.dispose();
  }
}
