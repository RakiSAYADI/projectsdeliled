import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';

class UniverseCreate extends StatefulWidget {
  const UniverseCreate({Key? key}) : super(key: key);

  @override
  State<UniverseCreate> createState() => _UniverseCreateState();
}

class _UniverseCreateState extends State<UniverseCreate> {
  final myUniverseName = TextEditingController();
  final myUniverseAddress = TextEditingController();
  final myUniverseLon = TextEditingController();
  final myUniverseLat = TextEditingController();
  final myUniverseRoom = TextEditingController();

  List<String> rooms = [];

  @override
  void dispose() {
    // TODO: implement dispose
    myUniverseName.dispose();
    myUniverseAddress.dispose();
    myUniverseLon.dispose();
    myUniverseLat.dispose();
    myUniverseRoom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(newUniverseMessageTextLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                nameTextLanguageArray[languageArrayIdentifier],
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
              Text(
                universeAddressTextLanguageArray[languageArrayIdentifier],
                style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
                child: TextField(
                  textAlign: TextAlign.center,
                  controller: myUniverseAddress,
                  maxLines: 1,
                  maxLength: 100,
                  style: TextStyle(
                    fontSize: screenHeight * 0.01 + screenWidth * 0.01,
                  ),
                  decoration: InputDecoration(
                      hintText: 'Exp: 123 Rue de France',
                      hintStyle: TextStyle(
                        fontSize: screenHeight * 0.01 + screenWidth * 0.01,
                        color: Colors.grey,
                      )),
                ),
              ),
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
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
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
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
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
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            universeRoomsTextLanguageArray[languageArrayIdentifier],
                            style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01),
                          ),
                        ],
                      ),
                    ),
                    const Expanded(
                      flex: 2,
                      child: Icon(Icons.arrow_forward),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SelectableText(
                            rooms.toString(),
                            style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
                child: TextField(
                  textAlign: TextAlign.center,
                  controller: myUniverseRoom,
                  maxLines: 1,
                  maxLength: 100,
                  onSubmitted: (value) {
                    rooms.add(myUniverseRoom.text);
                    myUniverseRoom.text = '';
                    setState(() {});
                  },
                  style: TextStyle(
                    fontSize: screenHeight * 0.01 + screenWidth * 0.01,
                  ),
                  decoration: InputDecoration(
                      hintText: 'Exp: Cuisine',
                      hintStyle: TextStyle(
                        fontSize: screenHeight * 0.01 + screenWidth * 0.01,
                        color: Colors.grey,
                      )),
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              TextButton(
                onPressed: () async {
                  if (myUniverseName.text.isNotEmpty && myUniverseAddress.text.isNotEmpty) {
                    await appClass.users[userIdentifier].createUniverse(myUniverseAddress.text, myUniverseName.text, myUniverseLon.text, myUniverseLat.text, rooms);
                    if (!requestResponse) {
                      showToastMessage('Error request');
                    } else {
                      showToastMessage('request is valid');
                    }
                  } else {
                    showToastMessage('empty text fields !');
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    createButtonTextLanguageArray[languageArrayIdentifier],
                    style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.02 + screenHeight * 0.02),
                  ),
                ),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(60.0))),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
