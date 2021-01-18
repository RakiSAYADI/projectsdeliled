import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/uvcToast.dart';
import 'package:mailer/mailer.dart';

class QrCodeGeneratorData extends StatefulWidget {
  @override
  _QrCodeGeneratorDataState createState() => _QrCodeGeneratorDataState();
}

class _QrCodeGeneratorDataState extends State<QrCodeGeneratorData> with TickerProviderStateMixin {
  ToastyMessage myUvcToast;
  AnimationController animationRefreshIcon;

  final myEmail = TextEditingController();

  Map qrCodeGeneratorDataClassData = {};
  List<Attachment> qrCodeList = [];

  bool firstDisplayMainWidget = false;

  @override
  Widget build(BuildContext context) {
    try {
      qrCodeGeneratorDataClassData =
          qrCodeGeneratorDataClassData.isNotEmpty ? qrCodeGeneratorDataClassData : ModalRoute.of(context).settings.arguments;
      qrCodeList = qrCodeGeneratorDataClassData['myQrcodeListFile'];
      firstDisplayMainWidget = true;
    } catch (e) {
      firstDisplayMainWidget = false;
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () => stopActivity(context),
      child: Scaffold(
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
                          hintText: 'Adresse Email',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          )),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  FlatButton(
                    onPressed: () async {
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                      animationRefreshIcon.repeat();
                      myUvcToast.setAnimationIcon(animationRefreshIcon);
                      myUvcToast.setToastDuration(10);
                      myUvcToast.setToastMessage('Génération en cours !');
                      myUvcToast.showToast(Colors.green, Icons.autorenew, Colors.white);
                      String qrCodeFileName = 'QrCode_${myEmail.text}.png';
                      String qrCodeData = '{\"SAFEUVCDATA\":\"${myEmail.text}\"}';
                      await Future.delayed(Duration(seconds: 5), () async {
                        myUvcToast.clearAllToast();
                        if (!firstDisplayMainWidget) {
                          firstDisplayMainWidget = true;
                        }
                        Navigator.pushReplacementNamed(context, '/Qr_code_Display_Data', arguments: {
                          'myQrcodeListFile': qrCodeList,
                          'myQrcodeFileName': qrCodeFileName,
                          'myEmail': myEmail.text,
                          'myQrcodeData': qrCodeData,
                        });
                      });
                    },
                    child: Text(
                      'Générer',
                      style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.06),
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

  Future<void> stopActivity(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Attention'),
        content: Text('Voulez-vous vraiment quitter l\'application ?'),
        actions: [
          FlatButton(
            child: Text('Oui'),
            onPressed: () {
              Navigator.pop(c, true);
            },
          ),
          FlatButton(
            child: Text('Non'),
            onPressed: () => Navigator.pop(c, false),
          ),
        ],
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
