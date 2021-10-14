import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app_bispectrum/services/DataVariables.dart';
import 'package:hsl_colorpicker/HSLColorPicker.dart';

class AmbiancePage extends StatefulWidget {
  @override
  _AmbiancePageState createState() => _AmbiancePageState();
}

class _AmbiancePageState extends State<AmbiancePage> {
  bool firstDisplayMainWidget = true;

  List<String> ambiance1, ambiance2, ambiance3, ambiance4;

  HSLColor hslColor = HSLColor.fromColor(Colors.blue);

  @override
  Widget build(BuildContext context) {
    if (firstDisplayMainWidget) {
      try {
        var parsedJson = json.decode(dataChar2);
        ambiance1 = [parsedJson['Amb'][0].toString(), parsedJson['Amb'][1].toString()];
        ambiance2 = [parsedJson['Amb'][2].toString(), parsedJson['Amb'][3].toString()];
        ambiance3 = [parsedJson['Amb'][4].toString(), parsedJson['Amb'][5].toString()];
        ambiance4 = [parsedJson['Amb'][6].toString(), parsedJson['Amb'][7].toString()];
      } catch (e) {
        print('erreur');
        ambiance1 = ['Ambiance 1', 'FF0000'];
        ambiance2 = ['Ambiance 2', '000000'];
        ambiance3 = ['Ambiance 3', '00FF00'];
        ambiance4 = ['Ambiance 4', '0000FF'];
      }
      firstDisplayMainWidget = false;
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: WillPopScope(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background-bispectrum.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                      child: ambianceDisplayWidget(context, ambiance1, 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                      child: ambianceDisplayWidget(context, ambiance3, 3),
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                      child: ambianceDisplayWidget(context, ambiance2, 2),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                      child: ambianceDisplayWidget(context, ambiance4, 4),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        onWillPop: () => returnButton(context),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_back),
        onPressed: () => returnButton(context),
        backgroundColor: Colors.blue[400],
      ),
    );
  }

  Widget ambianceDisplayWidget(BuildContext context, List<String> ambiance, int ambianceID) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 3.0),
          child: Text(
            ambiance[0],
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        ambianceCircleDisplay(context, ambiance[1], ambianceID),
        IconButton(
          onPressed: () async {
            ambianceSettingWidget(context, ambiance, ambianceID);
          },
          iconSize: 35.0,
          icon: Icon(Icons.settings),
          color: Colors.white,
        ),
      ],
    );
  }

  Future<void> ambianceSettingWidget(BuildContext context, List<String> ambiance, int ambianceID) async {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final ambianceNameEditor = TextEditingController();
    final color = StringBuffer();
    if (ambiance[1].length == 6 || ambiance[1].length == 7) color.write('ff');
    color.write(ambiance[1].replaceFirst('#', ''));
    ambianceNameEditor.text = ambiance[0];
    String colorHue = ambiance[1];
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier l’ambiance'),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Nom de votre ambiance:'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    maxLength: 10,
                    controller: ambianceNameEditor,
                    style: TextStyle(
                      fontSize: screenHeight * 0.04,
                      color: Colors.grey[800],
                    ),
                    decoration: InputDecoration(
                        hintText: 'exp:amb123',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        )),
                  ),
                ),
                Text('Couleur de votre ambiance:'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: HSLColorPicker(
                    onChanged: (colorSelected) {
                      hslColor = colorSelected;
                      colorHue = colorSelected.toColor().toString().split("0x")[1].toUpperCase().replaceFirst("FF", "").replaceAll(")", "");
                      print(colorHue);
                    },
                    size: screenHeight * 0.4 + screenWidth * 0.1,
                    strokeWidth: screenHeight * 0.04,
                    thumbSize: 0.00001,
                    thumbStrokeSize: screenWidth * 0.005 + screenHeight * 0.005,
                    showCenterColorIndicator: true,
                    centerColorIndicatorSize: screenWidth * 0.05 + screenHeight * 0.05,
                    initialColor: Color(int.parse(color.toString(), radix: 16)),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Sauvegarder',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () async {
                setState(() {
                  ambiance[0] = ambianceNameEditor.text;
                  ambiance[1] = colorHue;
                });
                if (myDevice.getConnectionState()) {
                  await characteristicData.write('{\"couleur$ambianceID\":[${ambiance[0]},${ambiance[1]}]}'.codeUnits);
                }
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Annuler',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget ambianceCircleDisplay(BuildContext context, String ambianceColor, int ambianceID) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    final color = StringBuffer();
    int colorInt = 0;
    try {
      if (ambianceColor.length == 6 || ambianceColor.length == 7) color.write('ff');
      color.write(ambianceColor.replaceFirst('#', ''));
      colorInt = int.parse(color.toString(), radix: 16);
    } catch (e) {
      print('erreur color');
      ambianceColor = "000000";
    }
    return GestureDetector(
      onTap: () async {
        if (myDevice.getConnectionState()) {
          await characteristicData.write('{\"Favoris\":\"Ambiance $ambianceID\"}'.codeUnits);
        }
      },
      child: Container(
        width: widthScreen * 0.4,
        height: heightScreen * 0.2,
        decoration: new BoxDecoration(
          color: Color(colorInt),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black, spreadRadius: 3),
          ],
        ),
      ),
    );
  }

  Future<bool> returnButton(BuildContext context) async {
    stateOfSleepAndReadingProcess = 0;
    Navigator.pop(context, true);
    return true;
  }
}
