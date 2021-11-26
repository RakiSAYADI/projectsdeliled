import 'package:flutter/material.dart';
import 'package:flutteruvcapp/services/CSVfileClass.dart';
import 'package:flutteruvcapp/services/DataVariables.dart';
import 'package:flutteruvcapp/services/languageDataBase.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class EndUVC extends StatefulWidget {
  @override
  _EndUVCState createState() => _EndUVCState();
}

class _EndUVCState extends State<EndUVC> {
  UVCDataFile uvcDataFile;

  bool firstDisplayMainWidget = true;

  void csvDataFile() async {
    uvcDataFile = UVCDataFile();
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
    dateFormat = new DateFormat.yMd(languageCode);
    timeFormat = new DateFormat.Hm(languageCode);
    uvcOperationData.add(timeFormat.format(dateTime));
    uvcOperationData.add(dateFormat.format(dateTime));

    uvcOperationData.add(activationTime.toString());

    if (isTreatmentCompleted) {
      uvcOperationData.add(validTreatmentUVCStateTextLanguageArray[languageArrayIdentifier]);
    } else {
      uvcOperationData.add(notValidTreatmentUVCStateTextLanguageArray[languageArrayIdentifier]);
    }

    uvcData.add(uvcOperationData);

    await uvcDataFile.saveUVCDATA(uvcData);
  }

  @override
  Widget build(BuildContext context) {
    if (firstDisplayMainWidget) {
      firstDisplayMainWidget = false;
      if (myDevice != null) {
        myDevice.disconnect();
      }
      csvDataFile();
    }

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
      title = validTreatmentUVCStateTitleTextLanguageArray[languageArrayIdentifier];
      message = validTreatmentUVCStateMessageTextLanguageArray[languageArrayIdentifier];
      imageGif = 'assets/felicitation_animation.gif';
    } else {
      title = notValidTreatmentUVCStateTitleTextLanguageArray[languageArrayIdentifier];
      message = notValidTreatmentUVCStateMessageTextLanguageArray[languageArrayIdentifier];
      imageGif = 'assets/echec_logo.gif';
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                    textAlign: TextAlign.center,
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
                  TextButton(
                    onPressed: () {
                      myDevice.disconnect();
                      Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
                    },
                    child: Text(
                      newDisinfectionButtonTextLanguageArray[languageArrayIdentifier],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.05,
                      ),
                    ),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[400]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/DataCSVView');
        },
        label: Text('Rapport'),
        icon: Icon(
          Icons.assignment,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue[400],
      ),
    );
  }

  Future<bool> exitApp(BuildContext context) async {
    myDevice.disconnect();
    Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
    return true;
  }
}
