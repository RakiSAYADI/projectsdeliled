import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart' hide Key;
import 'package:flutter/services.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/DataVariables.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/uvcToast.dart';
import 'package:pinput/pin_put/pin_put.dart';

class QrCodeGeneratorFullAuto extends StatefulWidget {
  @override
  _QrCodeGeneratorFullAutoState createState() => _QrCodeGeneratorFullAutoState();
}

class _QrCodeGeneratorFullAutoState extends State<QrCodeGeneratorFullAuto> with TickerProviderStateMixin {
  ToastyMessage myUvcToast;
  AnimationController animationRefreshIcon;

  final myCompany = TextEditingController();
  final myName = TextEditingController();
  final myRoomName = TextEditingController();
  final TextEditingController _pinPutController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.blue[400],
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        centerTitle: true,
        title: Text('Informations'),
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
                  'assets/robot_machine.png',
                  height: screenHeight * 0.09,
                  width: screenWidth * 0.5,
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  uvcName,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
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
                    controller: myCompany,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey[800],
                    ),
                    decoration: InputDecoration(
                        hintText: 'Établissement',
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
                    controller: myName,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey[800],
                    ),
                    decoration: InputDecoration(
                        hintText: 'Opérateur',
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
                    controller: myRoomName,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                    ),
                    decoration: InputDecoration(
                        hintText: 'Pièce/local',
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
                  'Délais avant allumage :',
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
                  'Durée de la désinfection :',
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
                SizedBox(height: screenHeight * 0.03),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                    shape: RoundedRectangleBorder(side: new BorderSide(color: Colors.grey, width: 2.0), borderRadius: BorderRadius.circular(4.0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          'Code PIN :',
                          style: TextStyle(
                            fontSize: screenWidth * 0.06,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: PinPut(
                            fieldsCount: 4,
                            onSubmit: (String pin) => pinCodeAccess = pin,
                            controller: _pinPutController,
                            textStyle: TextStyle(
                              color: Colors.black,
                              fontSize: screenWidth * 0.04,
                            ),
                            submittedFieldDecoration: _pinPutDecoration.copyWith(borderRadius: BorderRadius.circular(20)),
                            selectedFieldDecoration: _pinPutDecoration,
                            followingFieldDecoration: _pinPutDecoration.copyWith(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.grey[600].withOpacity(.5), width: 3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                TextButton(
                  onPressed: () async {
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                    if (_pinPutController.text.isNotEmpty && _pinPutController.text.length < 4) {
                      myUvcToast.setToastDuration(3);
                      myUvcToast.setToastMessage('Veuillez mettre un code PIN à 4 chiffres !');
                      myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
                      _pinPutController.text = '';
                      pinCodeAccess = '';
                    } else {
                      animationRefreshIcon.repeat();
                      myUvcToast.setAnimationIcon(animationRefreshIcon);
                      myUvcToast.setToastDuration(10);
                      myUvcToast.setToastMessage('Génération en cours !');
                      myUvcToast.showToast(Colors.green, Icons.autorenew, Colors.white);
                      qrCodeFileName = 'QrCodeFullAuto_${myCompany.text}_${myName.text}_${myRoomName.text}.png';
                      if (_pinPutController.text.isEmpty) {
                        qrCodeData =
                            '{\"Company\":\"${myCompany.text}\",\"UserName\":\"${myName.text}\",\"RoomName\":\"${myRoomName.text}\"'
                                ',\"TimeData\":[$myExtinctionTimeMinutePosition,$myActivationTimeMinutePosition],\"MAC\":\"$macAddress\"'
                                ',\"NAME\":\"$uvcName\"}';
                      } else {
                        final key = Key.fromUtf8('deeplightsolutionsdedesinfection');
                        final iv = IV.fromLength(16);
                        final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
                        final encrypted = encrypter.encrypt(pinCodeAccess, iv: iv);
                        qrCodeData =
                            '{\"Company\":\"${myCompany.text}\",\"UserName\":\"${myName.text}\",\"RoomName\":\"${myRoomName.text}\"'
                                ',\"TimeData\":[$myExtinctionTimeMinutePosition,$myActivationTimeMinutePosition],\"PIN\":\"${encrypted.base16}\"'
                                ',\"MAC\":\"$macAddress\",\"NAME\":\"$uvcName\"}';
                      }
                      await Future.delayed(Duration(seconds: 5), () async {
                        myUvcToast.clearAllToast();
                        print(qrCodeList);
                        myRoomNameText = myRoomName.text;
                        Navigator.pushNamed(context, '/Qr_code_Display');
                      });
                    }
                  },
                  child: Text(
                    'Générer',
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

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: Colors.blue, width: 3),
      borderRadius: BorderRadius.circular(15),
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
    _pinPutController.dispose();
    animationRefreshIcon.dispose();
    myCompany.dispose();
    myName.dispose();
    myRoomName.dispose();
    super.dispose();
  }
}
