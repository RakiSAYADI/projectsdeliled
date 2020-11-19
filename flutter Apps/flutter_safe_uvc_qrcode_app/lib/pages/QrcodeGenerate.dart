import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/uvcToast.dart';
import 'package:mailer/mailer.dart';

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

  String myExtinctionTimeMinuteData = ' 30 sec';
  String myActivationTimeMinuteData = ' 10 sec';

  int myExtinctionTimeMinutePosition = 0;
  int myActivationTimeMinutePosition = 0;

  bool firstDisplayMainWidget = false;

  Map qrCodeGeneratorClassData = {};
  List<Attachment> qrCodeList = [];

  List<String> myExtinctionTimeMinute = [
    ' 30 sec',
    '  1 min',
    '  2 min',
    '  5 min',
    ' 10 min',
    ' 15 min',
    ' 20 min',
    ' 25 min',
    ' 30 min',
    ' 35 min',
    ' 40 min',
    ' 45 min',
    ' 50 min',
    ' 55 min',
    ' 60 min',
    ' 65 min',
    ' 70 min',
    ' 75 min',
    ' 80 min',
    ' 85 min',
    ' 90 min',
    ' 95 min',
    '100 min',
    '105 min',
    '110 min',
    '115 min',
    '120 min',
  ];

  List<String> myActivationTimeMinute = [
    ' 10 sec',
    ' 20 sec',
    ' 30 sec',
    ' 40 sec',
    ' 50 sec',
    ' 60 sec',
    ' 70 sec',
    ' 80 sec',
    ' 90 sec',
    '100 sec',
    '110 sec',
    '120 sec',
  ];

  @override
  Widget build(BuildContext context) {
    try{
      qrCodeGeneratorClassData = qrCodeGeneratorClassData.isNotEmpty ? qrCodeGeneratorClassData : ModalRoute.of(context).settings.arguments;
      qrCodeList = qrCodeGeneratorClassData['myQrcodeListFile'];
      firstDisplayMainWidget =true;
    }catch(e) {
      firstDisplayMainWidget = false;
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.blue[400],
        appBar: AppBar(
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
                  SizedBox(height: screenHeight * 0.04),
                  FlatButton(
                    onPressed: () async {
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                      animationRefreshIcon.repeat();
                      myUvcToast.setAnimationIcon(animationRefreshIcon);
                      myUvcToast.setToastDuration(10);
                      myUvcToast.setToastMessage('Génération en cours !');
                      myUvcToast.showToast(Colors.green, Icons.autorenew, Colors.white);
                      String qrCodeFileName = 'QrCode_${myCompany.text}_${myName.text}_${myRoomName.text}.png';
                      String qrCodeData = '{\"Company\":\"${myCompany.text}\",\"UserName\":\"${myName.text}\",\"RoomName\":\"${myRoomName.text}\",\"TimeData\":[$myExtinctionTimeMinutePosition,$myActivationTimeMinutePosition]}';
                      await Future.delayed(Duration(seconds: 5), () async {
                        myUvcToast.clearAllToast();
                        if (!firstDisplayMainWidget) {
                          firstDisplayMainWidget = true;
                        }
                        Navigator.pushReplacementNamed(context, '/Qr_code_Display', arguments: {
                          'myQrcodeListFile': qrCodeList,
                          'myQrcodeFileName': qrCodeFileName,
                          'myRoomName':myRoomName.text,
                          'myQrcodeData': qrCodeData,
                        });
                      });
                    },
                    child: Text(
                      'Générer',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.blue[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                ],
              ),
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
