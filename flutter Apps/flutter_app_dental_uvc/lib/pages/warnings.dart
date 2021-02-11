import 'package:flutter/material.dart';
import 'package:flutterappdentaluvc/services/bleDeviceClass.dart';
import 'package:flutterappdentaluvc/services/uvcClass.dart';

class Warnings extends StatefulWidget {
  @override
  _WarningsState createState() => _WarningsState();
}

class _WarningsState extends State<Warnings> {
  Map warningsClassData = {};

  Device myDevice;
  UvcLight myUvcLight;

  bool nextButtonPressedOnce = false;

  @override
  Widget build(BuildContext context) {
    warningsClassData = warningsClassData.isNotEmpty ? warningsClassData : ModalRoute.of(context).settings.arguments;
    myDevice = warningsClassData['myDevice'];
    myUvcLight = warningsClassData['myUvcLight'];

    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('À lire attentivement'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  color: Colors.orange,
                  width: widthScreen,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning,
                        size: widthScreen * 0.1 * heightScreen * 0.001,
                        color: Colors.white,
                      ),
                      SizedBox(width: widthScreen * 0.03),
                      Text(
                        'Attention !',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widthScreen * 0.1 * heightScreen * 0.0005,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: heightScreen * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(flex: 1, child: SizedBox(width: widthScreen * 0.01)),
                    Container(
                      child: Container(
                        width: 100,
                        height: 100,
                        child: Center(
                            child: Text(
                          '1',
                          style: TextStyle(color: Colors.white, fontSize: widthScreen * 0.04),
                        )),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(200),
                        ),
                        color: Colors.blue[300],
                      ),
                    ),
                    Expanded(flex: 1, child: SizedBox(width: widthScreen * 0.01)),
                    Expanded(
                      flex: 9,
                      child: Text(
                        'Vérifiez que la pièce soit innocupée.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: widthScreen * 0.03),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: heightScreen * 0.025),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Divider(
                    thickness: 1.0,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: heightScreen * 0.025),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(flex: 1, child: SizedBox(width: widthScreen * 0.01)),
                    Container(
                      child: Container(
                        width: 100,
                        height: 100,
                        child: Center(
                            child: Text(
                          '2',
                          style: TextStyle(color: Colors.white, fontSize: widthScreen * 0.04),
                        )),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(200),
                        ),
                        color: Colors.blue[300],
                      ),
                    ),
                    Expanded(flex: 1, child: SizedBox(width: widthScreen * 0.01)),
                    Expanded(
                      flex: 9,
                      child: Text(
                        'Fermer la porte et les fenêtres.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: widthScreen * 0.03),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: heightScreen * 0.025),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Divider(
                    thickness: 1.0,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: heightScreen * 0.025),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(flex: 1, child: SizedBox(width: widthScreen * 0.01)),
                    Container(
                      child: Container(
                        width: 100,
                        height: 100,
                        child: Center(
                            child: Text(
                          '3',
                          style: TextStyle(color: Colors.white, fontSize: widthScreen * 0.04),
                        )),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(200),
                        ),
                        color: Colors.blue[300],
                      ),
                    ),
                    Expanded(flex: 1, child: SizedBox(width: widthScreen * 0.01)),
                    Expanded(
                      flex: 9,
                      child: Text(
                        'Signalez la désinfection en cours \n grâce aux accroche-portes et/ou au chevalet.',
                        overflow: TextOverflow.visible,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: widthScreen * 0.03),
                      ),
                    ),
                  ],
                ),
                //here is the image or gif
                SizedBox(height: heightScreen * 0.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                      onPressed: () async {
                        if (!nextButtonPressedOnce) {
                          nextButtonPressedOnce = true;
                          String message = 'UVCTreatement : ON';
                          await myDevice.writeCharacteristic(2, 0, message);
                          Navigator.pushNamed(context, '/uvc', arguments: {
                            'uvclight': myUvcLight,
                            'myDevice': myDevice,
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'SUIVANT',
                          style: TextStyle(color: Colors.white, fontSize: widthScreen * 0.02),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      color: Colors.blue[400],
                    ),
                    SizedBox(width: widthScreen * 0.09),
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'ANNULER',
                          style: TextStyle(color: Colors.white, fontSize: widthScreen * 0.02),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      color: Colors.red[400],
                    ),
                  ],
                ),
                SizedBox(height: heightScreen * 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
