import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';
import 'package:get/get.dart';

class WindSpeedConditionAutomation extends StatefulWidget {
  const WindSpeedConditionAutomation({Key? key}) : super(key: key);

  @override
  State<WindSpeedConditionAutomation> createState() => _WindSpeedConditionAutomationState();
}

class _WindSpeedConditionAutomationState extends State<WindSpeedConditionAutomation> {
  String operatorData = '==';
  List<bool> operator = [false, true, false];
  double windSpeedValue = 0;
  final myWeatherLon = TextEditingController();
  final myWeatherLat = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    myWeatherLon.dispose();
    myWeatherLat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    List<Color> operatorColor = [operator[0] ? Colors.green : Colors.red, operator[1] ? Colors.green : Colors.red, operator[2] ? Colors.green : Colors.red];
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(addWeatherTextLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.check),
        backgroundColor: Colors.green,
        onPressed: () async {
          if (myWeatherLon.text.isEmpty || myWeatherLat.text.isEmpty) {
            showToastMessage('must have lon and lat');
          } else {
            await appClass.getCityInfo(lon: myWeatherLon.text, lat: myWeatherLat.text);
            automationConditions.add({
              'display': {'code': 'windSpeed', 'operator': operatorData, 'value': windSpeedValue.toInt()},
              'entity_id': cityInfo['city_id'].toString(),
              'entity_type': 3,
              'order_num': automationConditions.length + 1
            });
            Get.back();
          }
        },
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: heightScreen * 0.05),
              ToggleButtons(
                borderRadius: BorderRadius.circular(18.0),
                isSelected: operator,
                onPressed: (int index) {
                  for (int i = 0; i < operator.length; i++) {
                    if (i == index) {
                      operator[index] = true;
                    } else {
                      operator[i] = false;
                    }
                  }
                  switch (index) {
                    case 0:
                      operatorData = '<';
                      break;
                    case 1:
                      operatorData = '==';
                      break;
                    case 2:
                      operatorData = '>';
                      break;
                  }
                  setState(() {});
                },
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('<', style: TextStyle(fontSize: widthScreen * 0.04, color: operatorColor[0], fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('=', style: TextStyle(fontSize: widthScreen * 0.04, color: operatorColor[1], fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('>', style: TextStyle(fontSize: widthScreen * 0.04, color: operatorColor[2], fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                ],
                selectedColor: Colors.black,
                selectedBorderColor: Colors.black,
                fillColor: Colors.white.withOpacity(0.5),
              ),
              SizedBox(height: heightScreen * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    windSpeedValue.round().toString(),
                    style: TextStyle(fontSize: heightScreen * 0.02 + widthScreen * 0.02, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    ' m/s',
                    style: TextStyle(fontSize: heightScreen * 0.02 + widthScreen * 0.02),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(flex: 1, child: SizedBox(width: widthScreen * 0.05)),
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Slider(
                        value: windSpeedValue,
                        max: 100,
                        min: 0,
                        divisions: 100,
                        label: windSpeedValue.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            windSpeedValue = value;
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(flex: 1, child: SizedBox(width: widthScreen * 0.05)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      '0 m/s',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: heightScreen * 0.015 + widthScreen * 0.015),
                    ),
                  ),
                  Expanded(flex: 4, child: SizedBox(width: widthScreen * 0.05)),
                  Expanded(
                    flex: 3,
                    child: Text(
                      '62 m/s',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: heightScreen * 0.015 + widthScreen * 0.015),
                    ),
                  ),
                ],
              ),
              SizedBox(height: heightScreen * 0.05),
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
                          style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: (widthScreen * 0.1)),
                          child: TextField(
                            textAlign: TextAlign.center,
                            controller: myWeatherLon,
                            maxLines: 1,
                            maxLength: 10,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                              TextInputFormatter.withFunction(
                                (oldValue, newValue) => newValue.copyWith(
                                  text: newValue.text.replaceAll(',', '.'),
                                ),
                              ),
                            ],
                            style: TextStyle(
                              fontSize: heightScreen * 0.01 + widthScreen * 0.01,
                            ),
                            decoration: InputDecoration(
                                hintText: 'Exp: 12.34',
                                hintStyle: TextStyle(
                                  fontSize: heightScreen * 0.01 + widthScreen * 0.01,
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
                          style: TextStyle(fontSize: heightScreen * 0.01 + widthScreen * 0.01),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: (widthScreen * 0.1)),
                          child: TextField(
                            textAlign: TextAlign.center,
                            controller: myWeatherLat,
                            maxLines: 1,
                            maxLength: 10,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                              TextInputFormatter.withFunction(
                                (oldValue, newValue) => newValue.copyWith(
                                  text: newValue.text.replaceAll(',', '.'),
                                ),
                              ),
                            ],
                            style: TextStyle(
                              fontSize: heightScreen * 0.01 + widthScreen * 0.01,
                            ),
                            decoration: InputDecoration(
                                hintText: 'Exp: 12.34',
                                hintStyle: TextStyle(
                                  fontSize: heightScreen * 0.01 + widthScreen * 0.01,
                                  color: Colors.grey,
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
