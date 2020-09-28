import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterdmxapp/services/bleDeviceClass.dart';
import 'package:flutterdmxapp/services/uvcClass.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  UvcLight myUvcLight;

  final myCompany = TextEditingController();
  final myName = TextEditingController();
  final myRoomName = TextEditingController();

  String myExtinctionTimeMinuteData = ' 30 sec';
  String myActivationTimeMinuteData = ' 10 sec';

  Map settingsClassData = {};

  Device myDevice;

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
  void dispose() {
    // Clean up the controllers when the widget is disposed.
    myCompany.dispose();
    myName.dispose();
    myRoomName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    settingsClassData = settingsClassData.isNotEmpty
        ? settingsClassData
        : ModalRoute.of(context).settings.arguments;
    myDevice = settingsClassData['myDevice'];

    myDevice.readCharacteristic(2, 0);

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Paramètres'),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/fondapplication.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Etablissement: ',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          maxLines: 1,
                          controller: myCompany,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[200],
                          ),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter a search term',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              )),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Nom de l\'operateur: ',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          maxLines: 1,
                          controller: myName,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[200],
                          ),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter a search term',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              )),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Nom de la piece: ',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          maxLines: 1,
                          controller: myRoomName,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[200],
                          ),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter a search term',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              )),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Temps de désinfection: ',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: DropdownButton<String>(
                          value: myExtinctionTimeMinuteData,
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(color: Colors.grey, fontSize: 18),
                          underline: Container(
                            height: 2,
                            color: Colors.blue[300],
                          ),
                          onChanged: (String data) {
                            setState(() {
                              myExtinctionTimeMinuteData = data;
                            });
                          },
                          items: myExtinctionTimeMinute
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Délais d\'activation: ',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: DropdownButton<String>(
                          value: myActivationTimeMinuteData,
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(color: Colors.grey, fontSize: 18),
                          underline: Container(
                            height: 2,
                            color: Colors.blue[300],
                          ),
                          onChanged: (String data) {
                            setState(() {
                              myActivationTimeMinuteData = data;
                            });
                          },
                          items: myActivationTimeMinute
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {
                          alertSecurity(context);
                        },
                        child: Text('Valider'),
                        color: Colors.grey,
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          myDevice.disconnect();
                        },
                        child: Text('Annuler'),
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      onWillPop: () => disconnection(context),
    );
  }

  Future<void> disconnection(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Attention'),
        content: Text('Voulez-vous vraiment quitter le robot UVC ?'),
        actions: [
          FlatButton(
            child: Text('Oui'),
            onPressed: () {
              //Stop UVC processing
              Navigator.pop(c, true);
              myDevice.disconnect();
              Navigator.pushNamedAndRemoveUntil(
                  context, "/access_pin", (r) => false);
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

  Future<void> waitingWidget(BuildContext context, int waitingSeconds,
      bool firstOrSecondWarning) async {
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: waitingSeconds), () {
          Navigator.of(context).pop(true);
          if (firstOrSecondWarning) {
            firstWarning(context);
          } else {
            secondWarning(context);
          }
        });
        return AlertDialog(
          title: Text('Veuillez patientez s\'il vous plait'),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.3,
            child: SpinKitCircle(
              color: Colors.red,
              size: 100.0,
            ),
          ),
        );
      },
    );
  }

  Future<void> firstWarning(BuildContext context) async {
    String operatorName = myUvcLight.getOperatorName();
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text('Attention'),
            content: Text(
                '$operatorName ,merci de confirmer que la pièce est inoccupée et que vous êtes sorti.'),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'Annuler',
                  style: TextStyle(color: Colors.green),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(
                  'Valider',
                  style: TextStyle(color: Colors.green),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await waitingWidget(context, 1, false);
                },
              ),
            ]);
      },
    );
  }

  Future<void> secondWarning(BuildContext context) async {
    String operatorName = myUvcLight.getOperatorName();
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Attention'),
          content: Text(
            '$operatorName, merci de confirmer que vous avez pris les dispositions pour sécuriser et signaler l\'opération de désinfection qui va débuter dans la pièce',
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Annuler',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                'Valider',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                scanQrCodeWarning(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> scanQrCodeWarning(BuildContext context) async {
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Attention'),
          content: Text(
            'Assurez-vous que personne ne soit present dans la piece, veuillez '
            'egalement sortir, assurez-vous d\'avoir securise l\'environnement '
            'et d\'avoir mis en place les dispositifs de prevention UV-C'
            '(chevalets et/ou accroche porte).\nApres validation il vous sera'
            ' demandé de scanner le QR code de sécurité.',
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Annuler l\'opération',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                'La pièce est sécurisée',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/scan_qrcode_security',
                    arguments: {
                      'uvclight': myUvcLight,
                      'myDevice': myDevice,
                    });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> alertSecurity(BuildContext context) {
    myUvcLight = UvcLight(
        machineName: myDevice.device.name,
        machineMac: myDevice.device.id.toString(),
        company: myCompany.text,
        operatorName: myName.text,
        roomName: myRoomName.text,
        infectionTime: myExtinctionTimeMinuteData,
        activationTime: myActivationTimeMinuteData);

    String machineName = myUvcLight.getMachineName();
    String machineMac = myUvcLight.getMachineMac();

    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Attention'),
          content: Text(
              'Vous confirmer les données enregistrés pour l\'appareil : $machineName de l\'adresse MAC : $machineMac ?'),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Annuler',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                'Confirmer',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () async {
                myDevice.writeCharacteristic(2, 0,
                    '{\"data\":[\"${myUvcLight.company}\",\"${myUvcLight.operatorName}\",\"${myUvcLight.roomName}\",${myUvcLight.getInfectionTime()},${myUvcLight.getActivationTime()}]}');
                Navigator.of(context).pop();
                await waitingWidget(context, 2, true);
              },
            ),
          ],
        );
      },
    );
  }
}
