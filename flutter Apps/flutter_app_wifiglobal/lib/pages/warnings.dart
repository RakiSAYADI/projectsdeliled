import 'package:flutter/material.dart';
import 'package:wifiglobalapp/services/data_variables.dart';
import 'package:wifiglobalapp/services/language_database.dart';

class Warnings extends StatefulWidget {
  @override
  _WarningsState createState() => _WarningsState();
}

class _WarningsState extends State<Warnings> {
  bool nextButtonPressedOnce = false;

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(readWarningsTextLanguageArray[languageArrayIdentifier]),
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
                        warningTextLanguageArray[languageArrayIdentifier],
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
                        warningNumberOneTextLanguageArray[languageArrayIdentifier],
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
                        warningNumberTwoTextLanguageArray[languageArrayIdentifier],
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
                        warningNumberThreeTextLanguageArray[languageArrayIdentifier],
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
                    TextButton(
                      onPressed: () async {
                        if (!nextButtonPressedOnce) {
                          nextButtonPressedOnce = true;
                          final bool result = await myDevice.startDisinfectionProcess();
                          if (result) {
                            Navigator.pushNamed(context, '/uvc');
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          nextTextLanguageArray[languageArrayIdentifier],
                          style: TextStyle(color: Colors.white, fontSize: widthScreen * 0.02),
                        ),
                      ),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                      ),
                    ),
                    SizedBox(width: widthScreen * 0.09),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          cancelTextLanguageArray[languageArrayIdentifier],
                          style: TextStyle(color: Colors.white, fontSize: widthScreen * 0.02),
                        ),
                      ),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                      ),
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
