import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/classes/tuya_device.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';

class DeviceFunctionsSceneModify extends StatefulWidget {
  const DeviceFunctionsSceneModify({Key? key}) : super(key: key);

  @override
  State<DeviceFunctionsSceneModify> createState() => _DeviceFunctionsSceneModifyState();
}

class _DeviceFunctionsSceneModifyState extends State<DeviceFunctionsSceneModify> {
  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    var args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    DeviceClass device = args['device'] as DeviceClass;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(addAndModifyFunctionsPageTitleTextLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
            children: device.functions.map((function) {
          switch (function['code']) {
            case 'switch_led':
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'State LED : ' + function['value'].toString(),
                        style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      Switch(
                        value: function['value'] as bool,
                        onChanged: (value) {
                          setState(() {
                            function['value'] = value;
                          });
                        },
                        activeTrackColor: Colors.lightGreenAccent,
                        activeColor: Colors.green,
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
                      Text(
                        'Mode: ' + function['value'].toString(),
                        style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
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
