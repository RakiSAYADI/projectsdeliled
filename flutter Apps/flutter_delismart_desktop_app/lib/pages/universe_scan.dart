import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_delismart_desktop_app/cards/universe_widget.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';
import 'package:get/get.dart';

class ScanListUniverse extends StatefulWidget {
  const ScanListUniverse({Key? key}) : super(key: key);

  @override
  _ScanListUniverseState createState() => _ScanListUniverseState();
}

class _ScanListUniverseState extends State<ScanListUniverse> {
  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton.icon(
                onPressed: () => addUniverseRequestWidget(),
                icon: Icon(Icons.add, size: heightScreen * 0.01 + widthScreen * 0.01),
                label: Text(
                  addUniverseButtonTextLanguageArray[languageArrayIdentifier],
                  style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01),
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(scanUniversePageTitleTextLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        backgroundColor: Colors.blue,
        onPressed: () async {
          appClass.users[userIdentifier].universes.clear();
          waitingRequestWidget();
          await appClass.users[userIdentifier].getUniverses();
          if (!requestResponse) {
            showToastMessage('Error request');
          }
          exitRequestWidget();
          setState(() {});
        },
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(children: appClass.users[userIdentifier].universes.map((universe) => UniverseCard(universeClass: universe)).toList()),
      ),
    );
  }

  void addUniverseRequestWidget() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(Get.context!).size.height;
    final myUniverseName = TextEditingController();
    final myUniverseLon = TextEditingController();
    final myUniverseLat = TextEditingController();
    Get.defaultDialog(
      title: newUniverseMessageTextLanguageArray[languageArrayIdentifier],
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            universeNameTextLanguageArray[languageArrayIdentifier],
            style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
            child: TextField(
              textAlign: TextAlign.center,
              controller: myUniverseName,
              maxLines: 1,
              maxLength: 20,
              style: TextStyle(
                fontSize: screenHeight * 0.01 + screenWidth * 0.01,
              ),
              decoration: InputDecoration(
                  hintText: 'Exp: My Home',
                  hintStyle: TextStyle(
                    fontSize: screenHeight * 0.01 + screenWidth * 0.01,
                    color: Colors.grey,
                  )),
            ),
          ),
          SizedBox(height: screenHeight * 0.05),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      universeLonTextLanguageArray[languageArrayIdentifier],
                      style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: myUniverseLon,
                        maxLines: 1,
                        maxLength: 10,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          // for below version 2 use this
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                          // for version 2 and greater you can also use this
                          TextInputFormatter.withFunction(
                            (oldValue, newValue) => newValue.copyWith(
                              text: newValue.text.replaceAll('.', ','),
                            ),
                          ),
                        ],
                        style: TextStyle(
                          fontSize: screenHeight * 0.01 + screenWidth * 0.01,
                        ),
                        decoration: InputDecoration(
                            hintText: 'Exp: 12.34',
                            hintStyle: TextStyle(
                              fontSize: screenHeight * 0.01 + screenWidth * 0.01,
                              color: Colors.grey,
                            )),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      universeLatTextLanguageArray[languageArrayIdentifier],
                      style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: myUniverseLat,
                        maxLines: 1,
                        maxLength: 10,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontSize: screenHeight * 0.01 + screenWidth * 0.01,
                        ),
                        decoration: InputDecoration(
                            hintText: 'Exp: 12.34',
                            hintStyle: TextStyle(
                              fontSize: screenHeight * 0.01 + screenWidth * 0.01,
                              color: Colors.grey,
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      confirm: TextButton.icon(
        onPressed: () async {},
        icon: Icon(Icons.check, size: screenHeight * 0.01 + screenWidth * 0.01),
        label: Text(
          confirmButtonTextLanguageArray[languageArrayIdentifier],
          style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01),
        ),
      ),
      cancel: TextButton.icon(
        onPressed: () => Get.back(),
        icon: Icon(Icons.close, size: screenHeight * 0.01 + screenWidth * 0.01),
        label: Text(
          cancelButtonTextLanguageArray[languageArrayIdentifier],
          style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01),
        ),
      ),
    );
  }
}
