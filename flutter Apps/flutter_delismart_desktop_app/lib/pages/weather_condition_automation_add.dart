import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_delismart_desktop_app/services/data_variables.dart';
import 'package:flutter_delismart_desktop_app/services/language_data_base.dart';
import 'package:get/get.dart';

class WeatherConditionAutomation extends StatefulWidget {
  const WeatherConditionAutomation({Key? key}) : super(key: key);

  @override
  State<WeatherConditionAutomation> createState() => _WeatherConditionAutomationState();
}

class _WeatherConditionAutomationState extends State<WeatherConditionAutomation> {
  List<bool> operator = [true, false, false, false, false];
  String weatherValue = 'sunny';
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
    List<Color> operatorColor = [
      operator[0] ? Colors.green : Colors.red,
      operator[1] ? Colors.green : Colors.red,
      operator[2] ? Colors.green : Colors.red,
      operator[3] ? Colors.green : Colors.red,
      operator[4] ? Colors.green : Colors.red
    ];
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
              'display': {'code': 'condition', 'operator': '==', 'value': weatherValue},
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
                      weatherValue = 'sunny';
                      break;
                    case 1:
                      weatherValue = 'cloudy';
                      break;
                    case 2:
                      weatherValue = 'rainy';
                      break;
                    case 3:
                      weatherValue = 'snowy';
                      break;
                    case 4:
                      weatherValue = 'polluted';
                      break;
                  }
                  setState(() {});
                },
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(weatherSunnyTextLanguageArray[languageArrayIdentifier],
                        style: TextStyle(fontSize: widthScreen * 0.04, color: operatorColor[0], fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(weatherCloudyTextLanguageArray[languageArrayIdentifier],
                        style: TextStyle(fontSize: widthScreen * 0.04, color: operatorColor[1], fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(weatherRainyTextLanguageArray[languageArrayIdentifier],
                        style: TextStyle(fontSize: widthScreen * 0.04, color: operatorColor[2], fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(weatherSnowyTextLanguageArray[languageArrayIdentifier],
                        style: TextStyle(fontSize: widthScreen * 0.04, color: operatorColor[3], fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(weatherPollutedTextLanguageArray[languageArrayIdentifier],
                        style: TextStyle(fontSize: widthScreen * 0.04, color: operatorColor[4], fontWeight: FontWeight.bold), textAlign: TextAlign.center),
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
                                  text: newValue.text.replaceAll('.', ','),
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
                                  text: newValue.text.replaceAll('.', ','),
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
