import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutteruvcapp/services/CSVfileClass.dart';
import 'package:flutteruvcapp/services/bleDeviceClass.dart';
import 'package:flutteruvcapp/services/uvcClass.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class EndUVC extends StatefulWidget {
  @override
  _EndUVCState createState() => _EndUVCState();
}

class _EndUVCState extends State<EndUVC> {
  Device myDevice;
  bool isTreatmentCompleted;

  String dataRobotUVC = '';

  Map endUVCClassData = {};

  UVCDataFile uvcDataFile;

  UvcLight myUvcLight;

  List<List<String>> uvcData;

  bool firstDisplayMainWidget = true;

  int activationTime;

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
    dateFormat = new DateFormat.yMd('fr');
    timeFormat = new DateFormat.Hm('fr');
    uvcOperationData.add(timeFormat.format(dateTime));
    uvcOperationData.add(dateFormat.format(dateTime));

    uvcOperationData.add(activationTime.toString());

    if (isTreatmentCompleted) {
      uvcOperationData.add('Valide');
    } else {
      uvcOperationData.add('Incident');
    }

    uvcData.add(uvcOperationData);

    await uvcDataFile.saveUVCDATA(uvcData);
  }

  @override
  void initState() {
    // TODO: implement initState
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    endUVCClassData = endUVCClassData.isNotEmpty ? endUVCClassData : ModalRoute.of(context).settings.arguments;
    isTreatmentCompleted = endUVCClassData['treatmentIsSuccessful'];
    activationTime = endUVCClassData['myactivationtime'];
    myDevice = endUVCClassData['myDevice'];
    myUvcLight = endUVCClassData['myUvcLight'];

    if (firstDisplayMainWidget) {
      firstDisplayMainWidget = false;
/*      if (myDevice != null) {
        myDevice.disconnect();
      }*/
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
      title = 'Désinfection terminée';
      message = 'Désinfection réalisée avec succès.';
      imageGif = 'assets/felicitation_animation.gif';
    } else {
      title = 'Désinfection annulée';
      message = 'Désinfection interrompue.';
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
/*                  SizedBox(height: screenHeight * 0.05),
                  FlatButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, "/profiles", (r) => false, arguments: {
                        'myDevice': myDevice,
                        'dataRead': dataRobotUVC,
                      });
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
                  ),*/
                  SizedBox(height: screenHeight * 0.05),
                  FlatButton(
                    onPressed: () {
                      myDevice.disconnect();
                      Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
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
/*      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/DataCSVView', arguments: {
            'isTreatmentCompleted': isTreatmentCompleted,
            'myUvcLight': myUvcLight,
            'uvcData': uvcData,
          });
        },
        label: Text('Rapport'),
        icon: Icon(
          Icons.assignment,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue[400],
      ),*/
    );
  }

  Future<bool> exitApp(BuildContext context) async {
    Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
    return true;
  }
}
