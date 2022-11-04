import 'package:flutter/material.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';
import 'package:get/get.dart';

class TimerAutomationAdd extends StatefulWidget {
  const TimerAutomationAdd({Key? key}) : super(key: key);

  @override
  State<TimerAutomationAdd> createState() => _TimerAutomationAddState();
}

class _TimerAutomationAddState extends State<TimerAutomationAdd> {
  String automationDelayHour = '00';
  String automationDelayMinute = '00';
  String automationDelaySecond = '00';

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
                    value: automationDelayHour,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    itemHeight: 150,
                    style: TextStyle(color: Colors.grey[800], fontSize: heightScreen * 0.05 + widthScreen * 0.05),
                    onChanged: (String? data) {
                      setState(() {
                        automationDelayHour = data!;
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
                    value: automationDelayMinute,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 32,
                    itemHeight: 150,
                    style: TextStyle(color: Colors.grey[800], fontSize: heightScreen * 0.05 + widthScreen * 0.05),
                    onChanged: (String? data) {
                      setState(() {
                        automationDelayMinute = data!;
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
                    value: automationDelaySecond,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    style: TextStyle(color: Colors.grey[800], fontSize: heightScreen * 0.05 + widthScreen * 0.05),
                    onChanged: (String? data) {
                      setState(() {
                        automationDelaySecond = data!;
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
                  if (automationDelayHour == '05' && (automationDelayMinute != '00' || automationDelaySecond != '00')) {
                    showToastMessage('Max timer is : 05:00:00');
                  } else {
                    automationActions.add({
                      'action_executor': 'delay',
                      'executor_property': {'hours': automationDelayHour, 'minutes': automationDelayMinute, 'seconds': automationDelaySecond}
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
