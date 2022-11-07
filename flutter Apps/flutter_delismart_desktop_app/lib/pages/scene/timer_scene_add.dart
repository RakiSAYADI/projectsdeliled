import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';
import 'package:get/get.dart';

class TimerSceneAdd extends StatefulWidget {
  const TimerSceneAdd({Key? key}) : super(key: key);

  @override
  State<TimerSceneAdd> createState() => _TimerSceneAddState();
}

class _TimerSceneAddState extends State<TimerSceneAdd> {
  String sceneDelayHour = '00';
  String sceneDelayMinute = '00';
  String sceneDelaySecond = '00';

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(addTimePageTitleTextLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                addTimePageTitleTextLanguageArray[languageArrayIdentifier],
                style: TextStyle(color: Colors.grey[800], fontSize: heightScreen * 0.03 + widthScreen * 0.03),
                textAlign: TextAlign.center,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<String>(
                    value: sceneDelayHour,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    itemHeight: 150,
                    style: TextStyle(color: Colors.grey[800], fontSize: heightScreen * 0.05 + widthScreen * 0.05),
                    onChanged: (String? data) {
                      setState(() {
                        sceneDelayHour = data!;
                      });
                    },
                    items: sceneHour.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[800], fontSize: heightScreen * 0.05 + widthScreen * 0.05),
                        ),
                      );
                    }).toList(),
                  ),
                  Text(
                    ':',
                    style: TextStyle(color: Colors.grey[800], fontSize: heightScreen * 0.05 + widthScreen * 0.05),
                    textAlign: TextAlign.center,
                  ),
                  DropdownButton<String>(
                    value: sceneDelayMinute,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 32,
                    itemHeight: 150,
                    style: TextStyle(color: Colors.grey[800], fontSize: heightScreen * 0.05 + widthScreen * 0.05),
                    onChanged: (String? data) {
                      setState(() {
                        sceneDelayMinute = data!;
                      });
                    },
                    items: minute.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[800], fontSize: heightScreen * 0.05 + widthScreen * 0.05),
                        ),
                      );
                    }).toList(),
                  ),
                  Text(
                    ':',
                    style: TextStyle(color: Colors.grey[800], fontSize: heightScreen * 0.05 + widthScreen * 0.05),
                    textAlign: TextAlign.center,
                  ),
                  DropdownButton<String>(
                    itemHeight: 150,
                    value: sceneDelaySecond,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    style: TextStyle(color: Colors.grey[800], fontSize: heightScreen * 0.05 + widthScreen * 0.05),
                    onChanged: (String? data) {
                      setState(() {
                        sceneDelaySecond = data!;
                      });
                    },
                    items: second.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        alignment: AlignmentDirectional.center,
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            value,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[800], fontSize: heightScreen * 0.05 + widthScreen * 0.05),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: heightScreen * 0.05),
              TextButton(
                onPressed: () {
                  if (sceneDelayHour == '05' && (sceneDelayMinute != '00' || sceneDelaySecond != '00')) {
                    showToastMessage('Max timer is : 05:00:00');
                  } else {
                    sceneActions.add({
                      'action_executor': 'delay',
                      'executor_property': {'hours': sceneDelayHour, 'minutes': sceneDelayMinute, 'seconds': sceneDelaySecond}
                    });
                    Get.back();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    addButtonTextLanguageArray[languageArrayIdentifier],
                    style: TextStyle(color: Colors.white, fontSize: widthScreen * 0.02 + heightScreen * 0.02),
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
