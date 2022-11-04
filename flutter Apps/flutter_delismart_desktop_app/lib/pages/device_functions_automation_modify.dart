import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_device.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';
import 'package:get/get.dart';

class DeviceFunctionsAutomationModify extends StatefulWidget {
  const DeviceFunctionsAutomationModify({Key? key}) : super(key: key);

  @override
  State<DeviceFunctionsAutomationModify> createState() => _DeviceFunctionsAutomationModifyState();
}

class _DeviceFunctionsAutomationModifyState extends State<DeviceFunctionsAutomationModify> {
  bool firstDisplay = true;
  DeviceClass? device;
  Map<Map<String, dynamic>, bool> functionsState = {};

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    if (firstDisplay) {
      var args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      device = args['device'] as DeviceClass;
      functionsState = {};
      for (var function in device!.functions) {
        functionsState.addAll({function: false});
      }
      firstDisplay = false;
    }
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(addAndModifyFunctionsPageTitleTextLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.check),
        backgroundColor: Colors.green,
        onPressed: () {
          functionsState.forEach((function, state) {
            if (state) {
              automationActions.add({
                'action_executor': 'dpIssue',
                'entity_id': device!.id,
                'executor_property': {function['code'].toString(): function['value']}
              });
            }
          });
          Get.back();
        },
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
            children: device!.functions.map((function) {
          switch (function['code']) {
            case 'switch_led':
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'State LED : ' + function['value'].toString(),
                          style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Switch(
                          value: function['value'] as bool,
                          onChanged: (value) {
                            setState(() {
                              function['value'] = value;
                            });
                          },
                          activeTrackColor: Colors.lightGreenAccent,
                          activeColor: Colors.green,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Checkbox(
                          value: functionsState[function],
                          onChanged: (state) {
                            setState(() {
                              functionsState[function] = state!;
                              debugPrint(functionsState[function].toString());
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            case 'work_mode':
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Mode: ' + function['value'].toString(),
                          style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: (widthScreen * 0.1)),
                          child: DropdownButton<String>(
                            value: function['value'].toString(),
                            icon: const Icon(Icons.arrow_drop_down),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle(color: Colors.grey[800], fontSize: heightScreen * 0.01 + widthScreen * 0.01),
                            underline: Container(
                              height: 2,
                              color: Colors.blue[300],
                            ),
                            onChanged: (String? data) {
                              setState(() {
                                function['value'] = data!;
                              });
                            },
                            items: workModeList.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Checkbox(
                          value: functionsState[function],
                          onChanged: (state) {
                            setState(() {
                              functionsState[function] = state!;
                              debugPrint(functionsState[function].toString());
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            case 'bright_value_v2':
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Lum: ' + function['value'].toString(),
                          style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Slider(
                          value: (function['value'] as int).toDouble(),
                          max: 1000,
                          min: 10,
                          divisions: 990,
                          label: function['value'].round().toString(),
                          onChanged: (double value) {
                            setState(() {
                              function['value'] = value.toInt();
                            });
                          },
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Checkbox(
                          value: functionsState[function],
                          onChanged: (state) {
                            setState(() {
                              functionsState[function] = state!;
                              debugPrint(functionsState[function].toString());
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            case 'temp_value_v2':
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Temp: ' + function['value'].toString(),
                          style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Slider(
                          value: (function['value'] as int).toDouble(),
                          max: 1000,
                          min: 0,
                          divisions: 1000,
                          label: function['value'].round().toString(),
                          onChanged: (double value) {
                            setState(() {
                              function['value'] = value.toInt();
                            });
                          },
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Checkbox(
                          value: functionsState[function],
                          onChanged: (state) {
                            setState(() {
                              functionsState[function] = state!;
                              debugPrint(functionsState[function].toString());
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            default:
              return const Text('UNKNOWN DATA');
          }
        }).toList()),
      ),
    );
  }
}
