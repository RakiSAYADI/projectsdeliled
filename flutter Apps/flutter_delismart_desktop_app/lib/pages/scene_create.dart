import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/cards/scene_element_mini_widgets.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';

class SceneCreate extends StatefulWidget {
  const SceneCreate({Key? key}) : super(key: key);

  @override
  State<SceneCreate> createState() => _SceneCreateState();
}

class _SceneCreateState extends State<SceneCreate> {
  final mySceneName = TextEditingController();
  List<Map<String, dynamic>> sceneActions = [];

  @override
  void dispose() {
    // TODO: implement dispose
    mySceneName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        sceneActions.clear();
        return Future<bool>.value(true);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(newSceneMessageTextLanguageArray[languageArrayIdentifier]),
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
                    controller: mySceneName,
                    maxLines: 1,
                    maxLength: 20,
                    style: TextStyle(
                      fontSize: screenHeight * 0.01 + screenWidth * 0.01,
                    ),
                    decoration: InputDecoration(
                        hintText: 'Exp: My Scene',
                        hintStyle: TextStyle(
                          fontSize: screenHeight * 0.01 + screenWidth * 0.01,
                          color: Colors.grey,
                        )),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                Row(
                  children: [
                    Container(
                      color: Colors.grey,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: sceneActions.map((element) {
                            switch (element['action_executor']) {
                              case 'delay':
                                return DelayCard(delayData: element);
                              case 'dpIssue':
                                return DeviceSceneCard(deviceSceneData: element);
                              case 'deviceGroupDpIssue':
                                return DeviceSceneCard(deviceSceneData: element);
                              default:
                                return Container();
                            }
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.05),
                TextButton(
                  onPressed: () async {
                    if (mySceneName.text.isNotEmpty) {
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
      ),
    );
  }
}
