import 'package:flutter/material.dart';
import 'package:flutterappdentaluvc/services/bleDeviceClass.dart';

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
    endUVCClassData = endUVCClassData.isNotEmpty
        ? endUVCClassData
        : ModalRoute.of(context).settings.arguments;
    isTreatmentCompleted = endUVCClassData['treatmentCompleted'];
    myDevice = endUVCClassData['myDevice'];

    return WillPopScope(
      child: screenResult(context),
      onWillPop: () => exitApp(context),
    );
  }

  Widget screenResult(BuildContext context) {
    if (isTreatmentCompleted) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Désinfection terminée'),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(color: Colors.grey[200]),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Désinfection réalisée avec succès.',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    Image.asset(
                      'assets/felicitation_animation.gif',
                      height: MediaQuery.of(context).size.height * 0.2,
                      width: MediaQuery.of(context).size.width * 0.8,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    FlatButton(
                      onPressed: () {
                        myDevice.disconnect();
                        Navigator.pushNamedAndRemoveUntil(
                            context, "/pin_access", (r) => false);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'Nouvelle désinfection',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width * 0.03,
                          ),
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
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Désinfection annulée'),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(color: Colors.grey[200]),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Désinfection interrompue',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    Image.asset(
                      'assets/echec_logo.gif',
                      height: MediaQuery.of(context).size.height * 0.2,
                      width: MediaQuery.of(context).size.width * 0.8,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    FlatButton(
                      onPressed: () {
                        myDevice.disconnect();
                        Navigator.pushNamedAndRemoveUntil(
                            context, "/pin_access", (r) => false);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'Nouvelle désinfection',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width * 0.03,
                          ),
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
  }

  Future<bool> exitApp(BuildContext context) async {
    myDevice.disconnect();
    Navigator.pushNamedAndRemoveUntil(
        context, "/bluetooth_activation", (r) => false);
    return true;
  }
}
