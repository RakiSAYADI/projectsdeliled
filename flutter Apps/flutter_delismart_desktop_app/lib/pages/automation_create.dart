import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/cards/automation_element_mini_widgets.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_device.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';
import 'package:get/get.dart';

class AutomationCreate extends StatefulWidget {
  const AutomationCreate({Key? key}) : super(key: key);

  @override
  State<AutomationCreate> createState() => _AutomationCreateState();
}

class _AutomationCreateState extends State<AutomationCreate> {
  final myAutomationName = TextEditingController();

  bool preconditionsSwitch = false;
  bool conditionEquationVisibility = false;

  @override
  void initState() {
    // TODO: implement initState
    automationActions.clear();
    automationPreconditions = {
      "display": {"start": "00:00", "end": "23:59", "loops": "1111111", "timezone_id": "Europe/Paris"},
      "cond_type": "timeCheck"
    };
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    myAutomationName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        automationActions.clear();
        automationConditions.clear();
        automationPreconditions.clear();
        return Future<bool>.value(true);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(newAutomationMessageTextLanguageArray[languageArrayIdentifier]),
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
                SizedBox(
                  height: screenHeight * 0.03,
                  child: Container(color: Colors.white),
                ),
                Text(
                  nameTextLanguageArray[languageArrayIdentifier],
                  style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
                  child: TextField(
                    textAlign: TextAlign.center,
                    controller: myAutomationName,
                    maxLines: 1,
                    maxLength: 100,
                    style: TextStyle(
                      fontSize: screenHeight * 0.01 + screenWidth * 0.01,
                    ),
                    decoration: InputDecoration(
                        hintText: 'Exp: My Automation',
                        hintStyle: TextStyle(
                          fontSize: screenHeight * 0.01 + screenWidth * 0.01,
                          color: Colors.grey,
                        )),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                Center(
                  child: SizedBox(
                    width: screenWidth * 0.7,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          preconditionsTextLanguageArray[languageArrayIdentifier],
                          style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01),
                        ),
                        preconditionsWidget(context),
                        SizedBox(
                          height: screenHeight * 0.03,
                          child: Container(color: Colors.white),
                        ),
                        Text(
                          conditionsTextLanguageArray[languageArrayIdentifier],
                          style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: automationConditions.map((element) {
                              switch (element['entity_type']) {
                                case 1:
                                  for (DeviceClass device in appClass.users[userIdentifier].universes[universeIdentifier].devices) {
                                    if (element['entity_id'] == device.id) {
                                      return DeviceAutomationConditionCard(deviceClass: device, mapData: element, deleteVisibility: true);
                                    }
                                  }
                                  return Container();
                                case 3:
                                  return WeatherAutomationConditionCard(weatherData: element, deleteVisibility: true);
                                case 6:
                                  return TimeAutomationConditionCard(timeData: element, deleteVisibility: true);
                                case 15:
                                  return ExternalAutomationConditionCard(mapData: element, deleteVisibility: true);
                                default:
                                  return Container();
                              }
                            }).toList(),
                          ),
                        ),
                        SizedBox(
                          height: screenHeight * 0.03,
                          child: Container(color: Colors.white),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Visibility(
                              visible: automationConditions.length >= 2 ? true : false,
                              child: TextButton.icon(
                                onPressed: () {
                                  matchType = 3;
                                  conditionRule = '1&&2||3';
                                  Get.toNamed('/condition_automation_modify');
                                },
                                icon: Icon(Icons.edit, size: screenHeight * 0.01 + screenWidth * 0.01, color: Colors.green),
                                label: Text(
                                  configureConditionsButtonTextLanguageArray[languageArrayIdentifier],
                                  style: TextStyle(fontSize: screenHeight * 0.007 + screenWidth * 0.007, color: Colors.green),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => addAutomationConditionsRequestWidget(),
                              icon: Icon(Icons.add, size: screenHeight * 0.01 + screenWidth * 0.01, color: Colors.blue),
                              label: Text(
                                addElementButtonTextLanguageArray[languageArrayIdentifier],
                                style: TextStyle(fontSize: screenHeight * 0.007 + screenWidth * 0.007, color: Colors.blue),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: screenHeight * 0.03,
                          child: Container(color: Colors.white),
                        ),
                        Text(
                          actionsTextLanguageArray[languageArrayIdentifier],
                          style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: automationActions.map((element) {
                              switch (element['action_executor']) {
                                case 'delay':
                                  return DelayAutomationActionCard(timeData: element);
                                case 'dpIssue':
                                  for (DeviceClass device in appClass.users[userIdentifier].universes[universeIdentifier].devices) {
                                    if (element['entity_id'] == device.id) {
                                      return DeviceAutomationActionCard(deviceClass: device, mapData: element);
                                    }
                                  }
                                  return Container();
                                /*case 'deviceGroupDpIssue':
                                  return DeviceSceneCard(deviceClass: element);*/
                                default:
                                  return Container();
                              }
                            }).toList(),
                          ),
                        ),
                        SizedBox(
                          height: screenHeight * 0.03,
                          child: Container(color: Colors.white),
                        ),
                        TextButton.icon(
                          onPressed: () => addAutomationActionsRequestWidget(),
                          icon: Icon(Icons.add, size: screenHeight * 0.01 + screenWidth * 0.01, color: Colors.blue),
                          label: Text(
                            addElementButtonTextLanguageArray[languageArrayIdentifier],
                            style: TextStyle(fontSize: screenHeight * 0.007 + screenWidth * 0.007, color: Colors.blue),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                TextButton(
                  onPressed: () async {
                    if (myAutomationName.text.isNotEmpty) {
                      if (automationActions.isNotEmpty) {
                        if (automationActions.last['action_executor'] != 'delay') {
                          /*await appClass.users[userIdentifier].universes[universeIdentifier]
                              .addAnimation(myAutomationName.text, '', automationActions, automationConditions, preconditionsSwitch ? automationPreconditions : {});*/
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
                      createButtonTextLanguageArray[languageArrayIdentifier],
                      style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.02 + screenHeight * 0.02),
                    ),
                  ),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(60.0))),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.03,
                  child: Container(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget preconditionsWidget(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    String loops = (automationPreconditions['display'] as Map<String, dynamic>)['loops'];
    List<bool> days = [charToBool(loops[0]), charToBool(loops[1]), charToBool(loops[2]), charToBool(loops[3]), charToBool(loops[4]), charToBool(loops[5]), charToBool(loops[6])];
    List<Color> daysColor = [
      days[0] ? Colors.green : Colors.red,
      days[1] ? Colors.green : Colors.red,
      days[2] ? Colors.green : Colors.red,
      days[3] ? Colors.green : Colors.red,
      days[4] ? Colors.green : Colors.red,
      days[5] ? Colors.green : Colors.red,
      days[6] ? Colors.green : Colors.red
    ];
    return Container(
      height: screenHeight * 0.3,
      width: screenWidth * 0.7,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'State : ' + (preconditionsSwitch ? 'On ' : 'Off'),
                style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              Switch(
                value: preconditionsSwitch,
                onChanged: (value) {
                  setState(() {
                    preconditionsSwitch = value;
                  });
                },
                activeTrackColor: Colors.lightGreenAccent,
                activeColor: Colors.green,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      startTextLanguageArray[languageArrayIdentifier],
                      style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButton<String>(
                          value: ((automationPreconditions['display'] as Map<String, dynamic>)['start'] as String).split(':')[0],
                          icon: const Icon(Icons.arrow_drop_down),
                          iconSize: 16,
                          itemHeight: 50,
                          style: TextStyle(color: Colors.grey[800], fontSize: screenHeight * 0.015 + screenWidth * 0.015),
                          onChanged: (String? data) {
                            setState(() {
                              (automationPreconditions['display'] as Map<String, dynamic>)['start'] =
                                  data! + ':' + ((automationPreconditions['display'] as Map<String, dynamic>)['start'] as String).split(':')[1];
                            });
                          },
                          items: hour.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[800], fontSize: screenHeight * 0.015 + screenWidth * 0.015),
                              ),
                            );
                          }).toList(),
                        ),
                        Text(
                          ': ',
                          style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01),
                        ),
                        DropdownButton<String>(
                          value: ((automationPreconditions['display'] as Map<String, dynamic>)['start'] as String).split(':')[1],
                          icon: const Icon(Icons.arrow_drop_down),
                          iconSize: 16,
                          itemHeight: 50,
                          style: TextStyle(color: Colors.grey[800], fontSize: screenHeight * 0.015 + screenWidth * 0.015),
                          onChanged: (String? data) {
                            setState(() {
                              (automationPreconditions['display'] as Map<String, dynamic>)['start'] =
                                  ((automationPreconditions['display'] as Map<String, dynamic>)['start'] as String).split(':')[0] + ':' + data!;
                            });
                          },
                          items: minute.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[800], fontSize: screenHeight * 0.015 + screenWidth * 0.015),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      endTextLanguageArray[languageArrayIdentifier],
                      style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButton<String>(
                          value: ((automationPreconditions['display'] as Map<String, dynamic>)['end'] as String).split(':')[0],
                          icon: const Icon(Icons.arrow_drop_down),
                          iconSize: 16,
                          itemHeight: 50,
                          style: TextStyle(color: Colors.grey[800], fontSize: screenHeight * 0.015 + screenWidth * 0.015),
                          onChanged: (String? data) {
                            setState(() {
                              (automationPreconditions['display'] as Map<String, dynamic>)['end'] =
                                  data! + ':' + ((automationPreconditions['display'] as Map<String, dynamic>)['end'] as String).split(':')[1];
                            });
                          },
                          items: hour.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[800], fontSize: screenHeight * 0.015 + screenWidth * 0.015),
                              ),
                            );
                          }).toList(),
                        ),
                        Text(
                          ': ',
                          style: TextStyle(fontSize: screenHeight * 0.01 + screenWidth * 0.01),
                        ),
                        DropdownButton<String>(
                          value: ((automationPreconditions['display'] as Map<String, dynamic>)['end'] as String).split(':')[1],
                          icon: const Icon(Icons.arrow_drop_down),
                          iconSize: 16,
                          itemHeight: 50,
                          style: TextStyle(color: Colors.grey[800], fontSize: screenHeight * 0.015 + screenWidth * 0.015),
                          onChanged: (String? data) {
                            setState(() {
                              (automationPreconditions['display'] as Map<String, dynamic>)['end'] =
                                  ((automationPreconditions['display'] as Map<String, dynamic>)['end'] as String).split(':')[0] + ':' + data!;
                            });
                          },
                          items: minute.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[800], fontSize: screenHeight * 0.015 + screenWidth * 0.015),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          ToggleButtons(
            borderRadius: BorderRadius.circular(18.0),
            isSelected: days,
            onPressed: (int index) {
              String newLoops = '';
              for (int i = 0; i < loops.length; i++) {
                if (i == index) {
                  newLoops += changeCharState(loops[index]);
                } else {
                  newLoops += loops[i];
                }
              }
              (automationPreconditions['display'] as Map<String, dynamic>)['loops'] = newLoops;
              setState(() {});
            },
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(sundayTextLanguageArray[languageArrayIdentifier],
                    style: TextStyle(fontSize: screenWidth * 0.015, color: daysColor[0], fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(mondayTextLanguageArray[languageArrayIdentifier],
                    style: TextStyle(fontSize: screenWidth * 0.015, color: daysColor[1], fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(tuesdayTextLanguageArray[languageArrayIdentifier],
                    style: TextStyle(fontSize: screenWidth * 0.015, color: daysColor[2], fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(wednesdayTextLanguageArray[languageArrayIdentifier],
                    style: TextStyle(fontSize: screenWidth * 0.015, color: daysColor[3], fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(thursdayTextLanguageArray[languageArrayIdentifier],
                    style: TextStyle(fontSize: screenWidth * 0.015, color: daysColor[4], fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(fridayTextLanguageArray[languageArrayIdentifier],
                    style: TextStyle(fontSize: screenWidth * 0.015, color: daysColor[5], fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(saturdayTextLanguageArray[languageArrayIdentifier],
                    style: TextStyle(fontSize: screenWidth * 0.015, color: daysColor[6], fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
            ],
            selectedColor: Colors.black,
            selectedBorderColor: Colors.black,
            fillColor: Colors.white.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}
