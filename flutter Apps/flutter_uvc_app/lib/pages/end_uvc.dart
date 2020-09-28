import 'package:flutter/material.dart';
import 'package:flutteruvcapp/services/bleDeviceClass.dart';

class EndUVC extends StatefulWidget {
  @override
  _EndUVCState createState() => _EndUVCState();
}

class _EndUVCState extends State<EndUVC> {
  Device myDevice;
  bool isTreatmentCompleted;

  Map endUVCClassData = {};

  @override
  Widget build(BuildContext context) {
    endUVCClassData = endUVCClassData.isNotEmpty ? endUVCClassData : ModalRoute.of(context).settings.arguments;
    isTreatmentCompleted = endUVCClassData['treatmentCompleted'];
    myDevice = endUVCClassData['myDevice'];

    return WillPopScope(
      child: screenResult(context),
      onWillPop: () => exitApp(context),
    );
  }

  Widget screenResult(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    String title;
    String message;
    String imageGif;

    if (isTreatmentCompleted) {
      title = 'Désinfection terminée';
      message = 'Désinfection réalisée avec succès.';
      imageGif = 'assets/felicitation_animation.gif';
    } else {
      title = 'Désinfection annulée';
      message = 'Désinfection interrompue.';
      imageGif = 'assets/echec_logo.gif';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Container(
          width: screenWidth,
          height: screenHeight,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Image.asset(
                    imageGif,
                    height: screenHeight * 0.2,
                    width: screenWidth * 0.8,
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  FlatButton(
                    onPressed: () {
                      myDevice.disconnect();
                      Navigator.pushNamedAndRemoveUntil(context, "/bluetooth_activation", (r) => false);
                    },
                    child: Text(
                      'Nouvelle désinfection',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.05,
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
      ),
    );
  }

  Future<bool> exitApp(BuildContext context) async {
    myDevice.disconnect();
    Navigator.pushNamedAndRemoveUntil(context, "/bluetooth_activation", (r) => false);
    return true;
  }
}
