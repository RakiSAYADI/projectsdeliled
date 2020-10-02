import 'package:flutter/material.dart';
import 'package:flutterappdentaluvc/services/CSVfileClass.dart';
import 'package:flutterappdentaluvc/services/bleDeviceClass.dart';
import 'package:flutterappdentaluvc/services/uvcClass.dart';

class EndUVC extends StatefulWidget {
  @override
  _EndUVCState createState() => _EndUVCState();
}

class _EndUVCState extends State<EndUVC> {
  Device myDevice;
  bool isTreatmentCompleted;

  Map endUVCClassData = {};

  UVCDataFile uvcDataFile;

  UvcLight myUvcLight;

  List<List<String>> uvcData;

  bool firstDisplayMainWidget = true;

  void csvDataFile() async {
    uvcDataFile = UVCDataFile();
    uvcData = await uvcDataFile.readUVCDATA();
    List<String> uvcOperationData =['default'];
    uvcOperationData.length = 0;

    uvcOperationData.add(myUvcLight.getMachineName());
    uvcOperationData.add(myUvcLight.getOperatorName());
    uvcOperationData.add(myUvcLight.getCompanyName());
    uvcOperationData.add(myUvcLight.getRoomName());
    var now = new DateTime.now();
    uvcOperationData.add(now.toString());
    uvcOperationData.add(myUvcLight.getInfectionTimeOnString());

    if(isTreatmentCompleted){
      uvcOperationData.add('réussi');
    }else{
      uvcOperationData.add('échoué');
    }

    uvcData.add(uvcOperationData);

    await uvcDataFile.saveUVCDATA(uvcData);
  }

  @override
  Widget build(BuildContext context) {
    endUVCClassData = endUVCClassData.isNotEmpty ? endUVCClassData : ModalRoute.of(context).settings.arguments;
    isTreatmentCompleted = endUVCClassData['treatmentCompleted'];
    myDevice = endUVCClassData['myDevice'];
    myUvcLight = endUVCClassData['uvclight'];

    if (firstDisplayMainWidget) {
      firstDisplayMainWidget = false;
      csvDataFile();
    }

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

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          centerTitle: true,
          actions: [
            settingsControl(context),
          ],
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
                        Navigator.pushNamedAndRemoveUntil(context, "/pin_access", (r) => false);
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
      ),
      onWillPop: () => exitApp(context),
    );
  }

  IconButton settingsControl(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.assignment,
        color: Colors.white,
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/DataCSVView', arguments: {
          'isTreatmentCompleted': isTreatmentCompleted,
          'uvclight': myUvcLight,
          'uvcData': uvcData,
        });
        //settingsWidget(context);
      },
    );
  }

  Future<bool> exitApp(BuildContext context) async {
    myDevice.disconnect();
    Navigator.pushNamedAndRemoveUntil(context, "/pin_access", (r) => false);
    return true;
  }
}
