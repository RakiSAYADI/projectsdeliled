import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/cards/scene/scene_element_mini_widgets.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_automation.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_device.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_scene.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';

class SceneModify extends StatefulWidget {
  const SceneModify({Key? key}) : super(key: key);

  @override
  State<SceneModify> createState() => _SceneModifyState();
}

class _SceneModifyState extends State<SceneModify> {
  final mySceneName = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    for (var element in appClass.users[userIdentifier].universes[universeIdentifier].scenes[sceneIdentifier].actions) {
      sceneActions.add(element);
    }
    mySceneName.text = appClass.users[userIdentifier].universes[universeIdentifier].scenes[sceneIdentifier].name;
    super.initState();
  }

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
          title: Text(modifySceneTitleMessageTextLanguageArray[languageArrayIdentifier]),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.refresh),
          backgroundColor: Colors.blue,
          onPressed: () {
            setState(() {});
          },
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
                    maxLength: 100,
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
                Center(
                  child: Container(
                    width: screenWidth * 0.7,
                    color: Colors.grey,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: sceneActions.map((element) {
                          switch (element['action_executor']) {
                            case 'delay':
                              return DelaySceneCard(delayData: element);
                            case 'dpIssue':
                              for (DeviceClass device in appClass.users[userIdentifier].universes[universeIdentifier].devices) {
                                if (element['entity_id'] == device.id) {
                                  return DeviceSceneCard(deviceClass: device, mapData: element);
                                }
                              }
                              return Container();
                            case 'deviceGroupDpIssue':
                              return DeviceGroupSceneCard(mapData: element);
                            case 'ruleEnable':
                            case 'ruleDisable':
                            case 'ruleTrigger':
                              for (AutomationClass automation in appClass.users[userIdentifier].universes[universeIdentifier].automations) {
                                if (element['entity_id'] == automation.id) {
                                  return AutomationSceneCard(elementName: automation.name, mapData: element, sceneOrAutomation: true);
                                }
                              }
                              for (SceneClass scene in appClass.users[userIdentifier].universes[universeIdentifier].scenes) {
                                if (element['entity_id'] == scene.id) {
                                  return AutomationSceneCard(elementName: scene.name, mapData: element, sceneOrAutomation: true);
                                }
                              }
                              return Container();
                            default:
                              return Container();
                          }
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                TextButton.icon(
                  onPressed: () => addSceneElementRequestWidget(),
                  icon: Icon(Icons.add, size: screenHeight * 0.01 + screenWidth * 0.01, color: Colors.blue),
                  label: Text(
                    addElementButtonTextLanguageArray[languageArrayIdentifier],
                    style: TextStyle(fontSize: screenHeight * 0.007 + screenWidth * 0.007, color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                TextButton(
                  onPressed: () async {
                    if (mySceneName.text.isNotEmpty) {
                      if (sceneActions.isNotEmpty) {
                        if (sceneActions.last['action_executor'] != 'delay') {
                          await appClass.users[userIdentifier].universes[universeIdentifier].scenes[sceneIdentifier].modifyScene(
                            mySceneName.text,
                            'https://images.tuyaeu.com/smart/rule/cover/air.png',
                            sceneActions,
                          );
                          if (!requestResponse) {
                            showToastMessage('Error request');
                          } else {
                            showToastMessage('request is valid');
                          }
                        } else {
                          showToastMessage('delay can not be the last action!');
                        }
                      } else {
                        showToastMessage('list is empty');
                      }
                    } else {
                      showToastMessage('empty text fields !');
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      modifyUserButtonTextLanguageArray[languageArrayIdentifier],
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
