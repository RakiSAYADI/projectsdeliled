import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_device.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';
import 'package:get/get.dart';

class DeviceFunctionsSceneModify extends StatefulWidget {
  const DeviceFunctionsSceneModify({Key? key}) : super(key: key);

  @override
  State<DeviceFunctionsSceneModify> createState() => _DeviceFunctionsSceneModifyState();
}

class _DeviceFunctionsSceneModifyState extends State<DeviceFunctionsSceneModify> {
  bool firstDisplay = true;
  DeviceClass? device;
  List<Map<String, dynamic>> functionsState = [];

  List<bool> switchers = [];

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    if (firstDisplay) {
      var args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      device = args['device'] as DeviceClass;
      functionsState = [];
      for (var function in device!.supportedFunctions) {
        switch (function['type']) {
          case 'Boolean':
            functionsState.add({
              'code': function['code'],
              'name': function['name'],
              'type': function['type'],
              'value': false,
              'state': false,
            });
            break;
          case 'Integer':
            debugPrint(function.toString());
            functionsState.add({
              'code': function['code'],
              'name': function['name'],
              'type': function['type'],
              'value': (function['values'] as Map<String, dynamic>)['min'],
              'valueMax': (function['values'] as Map<String, dynamic>)['max'],
              'valueMin': (function['values'] as Map<String, dynamic>)['min'],
              'valueDivision': function['values']['max'] + (function['values']['min'] as int).abs(),
              'valueUnit': (function['values'] as Map<String, dynamic>).containsKey('unit') ? (function['values'] as Map<String, dynamic>)['unit'] as String : '',
              'state': false,
            });
            break;
          case 'Enum':
            List<String> range = [];
            for (var item in function['values']['range']) {
              range.add(item);
            }
            String first = range.first;
            functionsState.add({
              'code': function['code'],
              'name': function['name'],
              'type': function['type'],
              'value': first,
              'range': range,
              'state': false,
            });
            break;
        }
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
          for (var function in functionsState) {
            if (function['state']) {
              sceneActions.add({
                'action_executor': 'dpIssue',
                'entity_id': device!.id,
                'executor_property': {function['code'].toString(): function['value']}
              });
            }
          }
          Get.back();
        },
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
            children: functionsState.map((function) {
          switch (function['type']) {
            case 'Boolean':
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          function['name'] + ' : ' + function['value'].toString(),
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
                          value: function['state'] as bool,
                          onChanged: (state) {
                            setState(() {
                              function['state'] = state!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            case 'Enum':
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          function['name'] + ' : ' + function['value'].toString(),
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
                            items: function['range'].map<DropdownMenuItem<String>>((String value) {
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
                          value: function['state'] as bool,
                          onChanged: (state) {
                            setState(() {
                              function['state'] = state!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            case 'Integer':
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          function['name'] + ' : ' + function['value'].toString() + function['valueUnit'],
                          style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Slider(
                          value: (function['value'] as int).toDouble(),
                          max: (function['valueMax'] as int).toDouble(),
                          min: (function['valueMin'] as int).toDouble(),
                          divisions: function['valueDivision'] as int,
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
                          value: function['state'] as bool,
                          onChanged: (state) {
                            setState(() {
                              function['state'] = state!;
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
