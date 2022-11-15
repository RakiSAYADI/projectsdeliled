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
            case 'switch_usb1':
            case 'switch_usb2':
            case 'switch_usb3':
            case 'switch_usb4':
            case 'switch_usb5':
            case 'switch_usb6':
            case 'switch_backlight':
            case 'switch_1':
            case 'switch_2':
            case 'switch_3':
            case 'switch_4':
            case 'switch_5':
            case 'switch_6':
            case 'child_lock':
            case 'doorcontact_state':
            case 'temper_alarm':
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          function['code'] + ' : ' + function['value'].toString(),
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
                          function['code'] + ' : ' + function['value'].toString(),
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
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            case 'relay_status':
            case 'relay_status_1':
            case 'relay_status_2':
            case 'relay_status_3':
            case 'relay_status_4':
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          function['code'] + ' : ' + function['value'].toString(),
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
                            items: relayStateList.map<DropdownMenuItem<String>>((String value) {
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
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            case 'doorbell_volume':
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          function['code'] + ' : ' + function['value'].toString(),
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
                            items: doorBellVolumeList.map<DropdownMenuItem<String>>((String value) {
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
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            case 'doorbell_ringtone':
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          function['code'] + ' : ' + function['value'].toString(),
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
                            items: doorBellRingtoneList.map<DropdownMenuItem<String>>((String value) {
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
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            case 'light_mode':
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          function['code'] + ' : ' + function['value'].toString(),
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
                            items: lightModeList.map<DropdownMenuItem<String>>((String value) {
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
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            case 'switch_value':
            case 'switch1_value':
            case 'switch2_value':
            case 'switch3_value':
            case 'switch4_value':
            case 'switch5_value':
            case 'switch6_value':
            case 'switch7_value':
            case 'switch8_value':
            case 'switch9_value':
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          function['code'] + ' : ' + function['value'].toString(),
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
                            items: switchValueList.map<DropdownMenuItem<String>>((String value) {
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
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            case 'switch_mode':
            case 'switch_mode1':
            case 'switch_mode2':
            case 'switch_mode3':
            case 'switch_mode4':
            case 'switch_mode5':
            case 'switch_mode6':
            case 'switch_mode7':
            case 'switch_mode8':
            case 'switch_mode9':
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          function['code'] + ' : ' + function['value'].toString(),
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
                            items: switchModeList.map<DropdownMenuItem<String>>((String value) {
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              function['code'] + ' : ' + function['value'].toString(),
                              style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: (widthScreen * 0.1)),
                              child: DropdownButton<String>(
                                value: function['operator'].toString(),
                                icon: const Icon(Icons.arrow_drop_down),
                                iconSize: 24,
                                elevation: 16,
                                style: TextStyle(color: Colors.grey[800], fontSize: 18),
                                underline: Container(
                                  height: 2,
                                  color: Colors.blue[300],
                                ),
                                onChanged: (String? data) {
                                  setState(() {
                                    function['operator'] = data!;
                                  });
                                },
                                items: conditions.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
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
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            case 'bright_value':
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              function['code'] + ' : ' + function['value'].toString(),
                              style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: (widthScreen * 0.1)),
                              child: DropdownButton<String>(
                                value: function['operator'].toString(),
                                icon: const Icon(Icons.arrow_drop_down),
                                iconSize: 24,
                                elevation: 16,
                                style: TextStyle(color: Colors.grey[800], fontSize: 18),
                                underline: Container(
                                  height: 2,
                                  color: Colors.blue[300],
                                ),
                                onChanged: (String? data) {
                                  setState(() {
                                    function['operator'] = data!;
                                  });
                                },
                                items: conditions.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      device!.category == 'dj'
                          ? Expanded(
                              flex: 4,
                              child: Slider(
                                value: (function['value'] as int).toDouble(),
                                max: 255,
                                min: 25,
                                divisions: 230,
                                label: function['value'].round().toString(),
                                onChanged: (double value) {
                                  setState(() {
                                    function['value'] = value.toInt();
                                  });
                                },
                              ),
                            )
                          : Expanded(
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
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            case 'temp_value':
            case 'temp_value_v2':
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              function['code'] + ' : ' + function['value'].toString(),
                              style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: (widthScreen * 0.1)),
                              child: DropdownButton<String>(
                                value: function['operator'].toString(),
                                icon: const Icon(Icons.arrow_drop_down),
                                iconSize: 24,
                                elevation: 16,
                                style: TextStyle(color: Colors.grey[800], fontSize: 18),
                                underline: Container(
                                  height: 2,
                                  color: Colors.blue[300],
                                ),
                                onChanged: (String? data) {
                                  setState(() {
                                    function['operator'] = data!;
                                  });
                                },
                                items: conditions.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
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
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            case 'countdown_1':
            case 'countdown_2':
            case 'countdown_3':
            case 'countdown_4':
            case 'countdown_5':
            case 'countdown_6':
            case 'countdown_usb1':
            case 'countdown_usb2':
            case 'countdown_usb3':
            case 'countdown_usb4':
            case 'countdown_usb5':
            case 'countdown_usb6':
            case 'countdown_led':
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              function['code'] + ' : ' + function['value'].toString(),
                              style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: (widthScreen * 0.1)),
                              child: DropdownButton<String>(
                                value: function['operator'].toString(),
                                icon: const Icon(Icons.arrow_drop_down),
                                iconSize: 24,
                                elevation: 16,
                                style: TextStyle(color: Colors.grey[800], fontSize: 18),
                                underline: Container(
                                  height: 2,
                                  color: Colors.blue[300],
                                ),
                                onChanged: (String? data) {
                                  setState(() {
                                    function['operator'] = data!;
                                  });
                                },
                                items: conditions.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Slider(
                          value: (function['value'] as int).toDouble(),
                          max: 86400,
                          min: 0,
                          divisions: 86400,
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
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            default:
              return const Center(child: Text('UNKNOWN DATA'));
          }
        }).toList()),
      ),
    );
  }
}
