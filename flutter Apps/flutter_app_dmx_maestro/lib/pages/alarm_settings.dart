import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_dmx_maestro/services/DataVariables.dart';
import 'package:flutter_app_dmx_maestro/services/elavated_button.dart';
import 'package:flutter_app_dmx_maestro/services/uvcToast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AlarmClock extends StatefulWidget {
  @override
  _AlarmClockState createState() => _AlarmClockState();
}

class _AlarmClockState extends State<AlarmClock> {
  String daysInHex;
  String activationButtonText = 'Désactivé';
  List<Color> activationButtonColor = [Colors.red, Colors.red, Colors.red, Colors.red, Colors.red, Colors.red, Colors.red];
  bool activationButtonState = false;
  Color saveButtonColor = Colors.blue[400];
  List<bool> days = [true, false, false, false, false, false, false];
  List<bool> daysStates = [false, false, false, false, false, false, false];
  List<bool> alarmOffList = [false, false, false, false, false, false, false];
  int day = 0;

  List<int> hourList = [0, 0, 0, 0, 0, 0, 0];
  List<int> minutesList = [0, 0, 0, 0, 0, 0, 0];
  List<int> secondsList = [0, 0, 0, 0, 0, 0, 0];
  List<int> luminosityMinList = [0, 0, 0, 0, 0, 0, 0];
  List<int> luminosityMaxList = [100, 100, 100, 100, 100, 100, 100];
  List<int> alarmOptionList = [0, 0, 0, 0, 0, 0, 0];
  List<int> alarmAmbiance = [0, 0, 0, 0, 0, 0, 0];

  List<String> dayZones = ['F', 'F', 'F', 'F', 'F', 'F', 'F'];

  String myTimeHoursData = '00';
  String myTimeMinutesData = '00';
  String myTimeSecondsData = '00';
  String alarmAmbianceData = 'Ambiance 1';

  int myTimeHoursPosition = 0;
  int myTimeMinutesPosition = 0;
  int myTimeSecondsPosition = 0;
  int alarmAmbiancePosition = 0;

  ToastyMessage myUvcToast;

  String myAlarmTimeMinuteData = '00';
  String myAlarmTimeSecondData = '00';

  String myAlarmOptionData = 'Basic';

  List<int> myAlarmTimeMinuteList = [0, 0, 0, 0, 0, 0, 0];
  List<int> myAlarmTimeSecondList = [0, 0, 0, 0, 0, 0, 0];

  int myAlarmTimeMinutePosition = 0;
  int myAlarmTimeSecondPosition = 0;
  int myAlarmOptionPosition = 0;

  Map alarmSettingsClassData = {};

  bool firstDisplayMainWidget = true;
  bool alarmOffState = false;

  List<dynamic> ambiance1List, ambiance2List, ambiance3List, ambiance4List, ambiance5List, ambiance6List;

  List<dynamic> ambianceList = ['Ambiance 1', true, true, 'FF0000', 50, 100, true, true, 'FF0000', 50, 100, true, true, 'FF0000', 50, 100, true, true, 'FF0000', 50, 100];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myUvcToast = ToastyMessage(toastContext: context);
  }

  void readWakeUpDataPerDay(List<dynamic> day, int dayID) {
    daysStates[dayID] = intToBool(day[0]);
    hourList[dayID] = day[1] ~/ 3600;
    minutesList[dayID] = (day[1] % 3600) ~/ 60;
    secondsList[dayID] = day[1] % 60;
    myAlarmTimeMinuteList[dayID] = day[2] ~/ 60;
    myAlarmTimeSecondList[dayID] = day[2] % 60;
    alarmAmbiance[dayID] = day[3];
    luminosityMinList[dayID] = day[4];
    luminosityMaxList[dayID] = day[5];
    dayZones[dayID] = day[6];
    alarmOptionList[dayID] = day[7];
    alarmOffList[dayID] = intToBool(day[8]);
    if (daysStates[dayID]) {
      activationButtonText = 'Activé';
      activationButtonColor[dayID] = Colors.green;
    } else {
      activationButtonText = 'Désactivé';
      activationButtonColor[dayID] = Colors.red;
    }
  }

  bool intToBool(int a) => a == 0 ? false : true;

  int boolToInt(bool a) => a == true ? 1 : 0;

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    if (appMode) {
      backGroundColorSelect = 0;
    } else {
      backGroundColorSelect = 1;
    }
    if (firstDisplayMainWidget) {
      try {
        alarmSettingsClassData = alarmSettingsClassData.isNotEmpty ? alarmSettingsClassData : ModalRoute.of(context).settings.arguments;
        ambiance1List = alarmSettingsClassData['ambiance1list'];
        ambiance2List = alarmSettingsClassData['ambiance2list'];
        ambiance3List = alarmSettingsClassData['ambiance3list'];
        ambiance4List = alarmSettingsClassData['ambiance4list'];
        ambiance5List = alarmSettingsClassData['ambiance5list'];
        ambiance6List = alarmSettingsClassData['ambiance6list'];

        myAmbiances = [ambiance1List[0], ambiance2List[0], ambiance3List[0], ambiance4List[0], ambiance5List[0], ambiance6List[0]];
        var parsedJson;
        if (Platform.isAndroid) {
          parsedJson = json.decode(dataMaestro4);
          readWakeUpDataPerDay(parsedJson['lun'], 0);
          readWakeUpDataPerDay(parsedJson['mar'], 1);
          readWakeUpDataPerDay(parsedJson['mer'], 2);
          readWakeUpDataPerDay(parsedJson['jeu'], 3);
          readWakeUpDataPerDay(parsedJson['ven'], 4);
          readWakeUpDataPerDay(parsedJson['sam'], 5);
          readWakeUpDataPerDay(parsedJson['dim'], 6);
        }
        if (Platform.isIOS) {
          parsedJson = json.decode(dataMaestroIOS8);
          readWakeUpDataPerDay(parsedJson['lun'], 0);
          readWakeUpDataPerDay(parsedJson['mar'], 1);
          readWakeUpDataPerDay(parsedJson['mer'], 2);
          readWakeUpDataPerDay(parsedJson['jeu'], 3);
          parsedJson = json.decode(dataMaestroIOS9);
          readWakeUpDataPerDay(parsedJson['ven'], 4);
          readWakeUpDataPerDay(parsedJson['sam'], 5);
          readWakeUpDataPerDay(parsedJson['dim'], 6);
        }

        day = 0;
        if (daysStates[day]) {
          activationButtonText = 'Activé';
          activationButtonColor[day] = Colors.green;
        } else {
          activationButtonText = 'Désactivé';
          activationButtonColor[day] = Colors.red;
        }
        myTimeHoursPosition = hourList[day];
        myTimeMinutesPosition = minutesList[day];
        myTimeSecondsPosition = secondsList[day];
        myAlarmTimeMinutePosition = myAlarmTimeMinuteList[day];
        myAlarmTimeSecondPosition = myAlarmTimeSecondList[day];
        alarmAmbiancePosition = alarmAmbiance[day];
        myAlarmOptionPosition = alarmOptionList[day];
        alarmOffState = alarmOffList[day];

        myTimeHoursData = myTimeHours.elementAt(myTimeHoursPosition);
        myTimeMinutesData = myTimeMinutes.elementAt(myTimeMinutesPosition);
        myTimeSecondsData = myTimeSeconds.elementAt(myTimeSecondsPosition);

        alarmAmbianceData = myAmbiances.elementAt(alarmAmbiancePosition);

        myAlarmTimeMinuteData = myTimeMinutes.elementAt(myAlarmTimeMinutePosition);
        myAlarmTimeSecondData = myTimeSeconds.elementAt(myAlarmTimeSecondPosition);

        myAlarmOptionData = myAlarmOption.elementAt(myAlarmOptionPosition);

        switch (alarmAmbiancePosition) {
          case 0:
            ambianceList = ambiance1List;
            break;
          case 1:
            ambianceList = ambiance2List;
            break;
          case 2:
            ambianceList = ambiance3List;
            break;
          case 3:
            ambianceList = ambiance4List;
            break;
          case 4:
            ambianceList = ambiance5List;
            break;
          case 5:
            ambianceList = ambiance6List;
            break;
        }
      } catch (e) {
        debugPrint(e.toString());
        debugPrint('error alarm');
        ambiance1List = ['Ambiance 1', true, true, 'FF0000', 50, 100, true, true, 'FF0000', 50, 100, true, true, 'FF0000', 50, 100, true, true, 'FF0000', 50, 100];
        ambiance2List = ['Ambiance 2', true, true, 'FF0000', 50, 100, true, true, 'FF0000', 50, 100, true, true, 'FF0000', 50, 100, true, true, 'FF0000', 50, 100];
        ambiance3List = ['Ambiance 3', true, true, 'FF0000', 50, 100, true, true, 'FF0000', 50, 100, true, true, 'FF0000', 50, 100, true, true, 'FF0000', 50, 100];
        ambiance4List = ['Ambiance 4', true, true, 'FF0000', 50, 100, true, true, 'FF0000', 50, 100, true, true, 'FF0000', 50, 100, true, true, 'FF0000', 50, 100];
        ambiance5List = ['Ambiance 5', true, true, 'FF0000', 50, 100, true, true, 'FF0000', 50, 100, true, true, 'FF0000', 50, 100, true, true, 'FF0000', 50, 100];
        ambiance6List = ['Ambiance 6', true, true, 'FF0000', 50, 100, true, true, 'FF0000', 50, 100, true, true, 'FF0000', 50, 100, true, true, 'FF0000', 50, 100];
        alarmAmbianceData = ambiance1List[0];
      }

      firstDisplayMainWidget = false;
    }

    return Scaffold(
      backgroundColor: backGroundColor[backGroundColorSelect],
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: modeColor[backGroundColorSelect]),
          ),
        ),
        iconTheme: IconThemeData(
          color: textColor[backGroundColorSelect],
        ),
        title: Text(
          'Planning d\'ambiances',
          style: TextStyle(fontSize: 18, color: textColor[backGroundColorSelect]),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 10.0,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 20.0, 12.0, 20.0),
          child: MyElevatedButton(
            onPressed: () async {
              if (myDevice.getConnectionState()) {
                displayAlert(
                  context,
                  'Enregistrement en cours',
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SpinKitCircle(
                        color: Colors.blue[600],
                        size: heightScreen * 0.1,
                      ),
                    ],
                  ),
                  null,
                );
                if (Platform.isAndroid) {
                  await characteristicMaestro.write('{\"lun\":[${alarmDayData(0)}],'
                          '\"mar\":[${alarmDayData(1)}],\"mer\":[${alarmDayData(2)}],'
                          '\"jeu\":[${alarmDayData(3)}],\"ven\":[${alarmDayData(4)}],'
                          '\"sam\":[${alarmDayData(5)}],\"dim\":[${alarmDayData(6)}]}'
                      .codeUnits);
                  await Future.delayed(Duration(milliseconds: 500));
                }
                if (Platform.isIOS) {
                  await characteristicMaestro.write('{\"lun\":[${alarmDayData(0)}],'
                          '\"mar\":[${alarmDayData(1)}],\"mer\":[${alarmDayData(2)}],'
                          '\"jeu\":[${alarmDayData(3)}]}'
                      .codeUnits);
                  await Future.delayed(Duration(milliseconds: 500));
                  await characteristicMaestro.write('{\"ven\":[${alarmDayData(4)}],'
                          '\"sam\":[${alarmDayData(5)}],\"dim\":[${alarmDayData(6)}]}'
                      .codeUnits);
                  await Future.delayed(Duration(milliseconds: 500));
                }
                await readBLEData();
                myUvcToast.setToastDuration(5);
                myUvcToast.setToastMessage('Données enregistrées !');
                myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
                // double popup for the alert dialog and the page
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Enregistrer',
                style: TextStyle(color: textColor[backGroundColorSelect], fontSize: 15),
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return ToggleButtons(
                      constraints: BoxConstraints.expand(width: constraints.maxWidth / 8),
                      isSelected: days,
                      onPressed: (int index) {
                        day = index;
                        setState(() {
                          days[day] = !days[day];
                          for (int buttonIndex = 0; buttonIndex < days.length; buttonIndex++) {
                            if (buttonIndex == day) {
                              days[buttonIndex] = true;
                            } else {
                              days[buttonIndex] = false;
                            }
                          }
                          if (daysStates[day]) {
                            activationButtonText = 'Activé';
                            activationButtonColor[day] = Colors.green;
                          } else {
                            activationButtonText = 'Désactivé';
                            activationButtonColor[day] = Colors.red;
                          }
                          alarmAmbiance[day] = alarmAmbiance[day];
                        });

                        myTimeHoursPosition = hourList[day];
                        myTimeMinutesPosition = minutesList[day];
                        myTimeSecondsPosition = secondsList[day];
                        myAlarmTimeMinutePosition = myAlarmTimeMinuteList[day];
                        myAlarmTimeSecondPosition = myAlarmTimeSecondList[day];
                        alarmAmbiancePosition = alarmAmbiance[day];
                        myAlarmOptionPosition = alarmOptionList[day];
                        alarmOffState = alarmOffList[day];

                        myTimeHoursData = myTimeHours.elementAt(myTimeHoursPosition);
                        myTimeMinutesData = myTimeMinutes.elementAt(myTimeMinutesPosition);
                        myTimeSecondsData = myTimeSeconds.elementAt(myTimeSecondsPosition);

                        alarmAmbianceData = myAmbiances.elementAt(alarmAmbiancePosition);

                        switch (alarmAmbiancePosition) {
                          case 0:
                            ambianceList = ambiance1List;
                            break;
                          case 1:
                            ambianceList = ambiance2List;
                            break;
                          case 2:
                            ambianceList = ambiance3List;
                            break;
                          case 3:
                            ambianceList = ambiance4List;
                            break;
                          case 4:
                            ambianceList = ambiance5List;
                            break;
                          case 5:
                            ambianceList = ambiance6List;
                            break;
                        }

                        myAlarmTimeMinuteData = myTimeMinutes.elementAt(myAlarmTimeMinutePosition);
                        myAlarmTimeSecondData = myTimeSeconds.elementAt(myAlarmTimeSecondPosition);

                        myAlarmOptionData = myAlarmOption.elementAt(myAlarmOptionPosition);
                      },
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "L",
                            style: TextStyle(
                              fontSize: widthScreen * 0.03 + heightScreen * 0.01,
                              color: activationButtonColor[0],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "M",
                            style: TextStyle(
                              fontSize: widthScreen * 0.03 + heightScreen * 0.01,
                              color: activationButtonColor[1],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "M",
                            style: TextStyle(
                              fontSize: widthScreen * 0.03 + heightScreen * 0.01,
                              color: activationButtonColor[2],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "J",
                            style: TextStyle(
                              fontSize: widthScreen * 0.03 + heightScreen * 0.01,
                              color: activationButtonColor[3],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "V",
                            style: TextStyle(
                              fontSize: widthScreen * 0.03 + heightScreen * 0.01,
                              color: activationButtonColor[4],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "S",
                            style: TextStyle(
                              fontSize: widthScreen * 0.03 + heightScreen * 0.01,
                              color: activationButtonColor[5],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "D",
                            style: TextStyle(
                              fontSize: widthScreen * 0.03 + heightScreen * 0.01,
                              color: activationButtonColor[6],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      borderWidth: 2,
                      color: Colors.grey,
                      selectedBorderColor: Colors.black,
                      selectedColor: Colors.blue,
                    );
                  },
                ),
              ),
              MyElevatedButton(
                onPressed: () {
                  activationButtonState = daysStates[day];
                  activationButtonState = !activationButtonState;
                  setState(() {
                    saveButtonColor = Colors.grey[400];
                    if (activationButtonState) {
                      activationButtonText = 'Activé';
                      activationButtonColor[day] = Colors.green;
                    } else {
                      activationButtonText = 'Désactivé';
                      activationButtonColor[day] = Colors.red;
                    }
                  });
                  daysStates[day] = activationButtonState;
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    activationButtonText,
                    style: TextStyle(color: activationButtonColor[day], fontSize: 15),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.alarm,
                          size: heightScreen * 0.03 + widthScreen * 0.05,
                          color: textColor[backGroundColorSelect],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Heure d\'activation :',
                            style: TextStyle(
                              fontSize: 18,
                              color: textColor[backGroundColorSelect],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(20), color: Colors.white),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DropdownButton<String>(
                            value: myTimeHoursData,
                            icon: Icon(Icons.arrow_drop_down),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle(color: Colors.grey[800], fontSize: 18),
                            onChanged: (String data) {
                              setState(() {
                                saveButtonColor = Colors.grey[400];
                                myTimeHoursData = data;
                                myTimeHoursPosition = myTimeHours.indexOf(data);
                                hourList[day] = myTimeHoursPosition;
                              });
                            },
                            items: myTimeHours.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          Text(
                            ' : ',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          DropdownButton<String>(
                            value: myTimeMinutesData,
                            icon: Icon(Icons.arrow_drop_down),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle(color: Colors.grey[800], fontSize: 18),
                            onChanged: (String data) {
                              setState(() {
                                saveButtonColor = Colors.grey[400];
                                myTimeMinutesData = data;
                                myTimeMinutesPosition = myTimeMinutes.indexOf(data);
                                minutesList[day] = myTimeMinutesPosition;
                              });
                            },
                            items: myTimeMinutes.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          Text(
                            ' : ',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          DropdownButton<String>(
                            value: myTimeSecondsData,
                            icon: Icon(Icons.arrow_drop_down),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle(color: Colors.grey[800], fontSize: 18),
                            onChanged: (String data) {
                              setState(() {
                                saveButtonColor = Colors.grey[400];
                                myTimeSecondsData = data;
                                myTimeSecondsPosition = myTimeSeconds.indexOf(data);
                                secondsList[day] = myTimeSecondsPosition;
                              });
                            },
                            items: myTimeMinutes.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.workspaces_outline,
                    size: heightScreen * 0.03 + widthScreen * 0.05,
                    color: textColor[backGroundColorSelect],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Ambiances :',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: textColor[backGroundColorSelect],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(20), color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: DropdownButton<String>(
                            value: alarmAmbianceData,
                            icon: Icon(Icons.arrow_drop_down),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle(color: Colors.grey[800], fontSize: 18),
                            onChanged: (String data) {
                              setState(() {
                                saveButtonColor = Colors.grey[400];
                                alarmAmbianceData = data;
                                alarmAmbiancePosition = myAmbiances.indexOf(data);
                                alarmAmbiance[day] = alarmAmbiancePosition;
                                switch (alarmAmbiancePosition) {
                                  case 0:
                                    ambianceList = ambiance1List;
                                    break;
                                  case 1:
                                    ambianceList = ambiance2List;
                                    break;
                                  case 2:
                                    ambianceList = ambiance3List;
                                    break;
                                  case 3:
                                    ambianceList = ambiance4List;
                                    break;
                                  case 4:
                                    ambianceList = ambiance5List;
                                    break;
                                  case 5:
                                    ambianceList = ambiance6List;
                                    break;
                                }
                              });
                            },
                            items: myAmbiances.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ambianceCircleDisplay(context, ambianceList),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.hourglass_bottom,
                    size: heightScreen * 0.03 + widthScreen * 0.05,
                    color: textColor[backGroundColorSelect],
                  ),
                  Text(
                    'Durée d\'activation :',
                    style: TextStyle(
                      fontSize: 18,
                      color: textColor[backGroundColorSelect],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(20), color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DropdownButton<String>(
                        value: myAlarmTimeMinuteData,
                        icon: Icon(Icons.arrow_drop_down),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(color: Colors.grey[800], fontSize: 18),
                        onChanged: (String data) {
                          setState(() {
                            saveButtonColor = Colors.grey[400];
                            myAlarmTimeMinuteData = data;
                            myAlarmTimeMinutePosition = myTimeMinutes.indexOf(data);
                            myAlarmTimeMinuteList[day] = myAlarmTimeMinutePosition;
                          });
                        },
                        items: myTimeMinutes.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      Text(
                        ' : ',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      DropdownButton<String>(
                        value: myAlarmTimeSecondData,
                        icon: Icon(Icons.arrow_drop_down),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(color: Colors.grey[800], fontSize: 18),
                        onChanged: (String data) {
                          setState(() {
                            saveButtonColor = Colors.grey[400];
                            myAlarmTimeSecondData = data;
                            myAlarmTimeSecondPosition = myTimeSeconds.indexOf(data);
                            myAlarmTimeSecondList[day] = myAlarmTimeSecondPosition;
                          });
                        },
                        items: myTimeSeconds.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(20), color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Option de réveil',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: (widthScreen * 0.1)),
                        child: DropdownButton<String>(
                          value: myAlarmOptionData,
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(color: Colors.grey[800], fontSize: 18),
                          underline: Container(
                            height: 2,
                            color: Colors.blue[300],
                          ),
                          onChanged: (String data) {
                            setState(() {
                              saveButtonColor = Colors.grey[400];
                              myAlarmOptionData = data;
                              myAlarmOptionPosition = myAlarmOption.indexOf(data);
                              alarmOptionList[day] = myAlarmOptionPosition;
                            });
                          },
                          items: myAlarmOption.map<DropdownMenuItem<String>>((String value) {
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
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(20), color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Switch(
                        value: alarmOffState,
                        onChanged: (value) async {
                          alarmOffState = value;
                          alarmOffList[day] = alarmOffState;
                          setState(() {});
                        },
                        activeTrackColor: Colors.grey,
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.red,
                      ),
                      Text(
                        'Extinction au fin durée',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget ambianceCircleDisplay(BuildContext context, List<dynamic> ambianceColors) {
    final colorZone1 = getColors(ambianceColors[3].toString());
    final colorZone2 = getColors(ambianceColors[8].toString());
    final colorZone3 = getColors(ambianceColors[13].toString());
    final colorZone4 = getColors(ambianceColors[18].toString());
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ambianceZoneColor(context, Color(int.parse(colorZone1.toString(), radix: 16)), whiteSelection(ambianceColors[4]), intToBool(ambianceColors[1]), intToBool(ambianceColors[2])),
        ambianceZoneColor(context, Color(int.parse(colorZone2.toString(), radix: 16)), whiteSelection(ambianceColors[9]), intToBool(ambianceColors[6]), intToBool(ambianceColors[7])),
        ambianceZoneColor(context, Color(int.parse(colorZone3.toString(), radix: 16)), whiteSelection(ambianceColors[14]), intToBool(ambianceColors[11]), intToBool(ambianceColors[12])),
        ambianceZoneColor(context, Color(int.parse(colorZone4.toString(), radix: 16)), whiteSelection(ambianceColors[19]), intToBool(ambianceColors[16]), intToBool(ambianceColors[17])),
      ],
    );
  }

  Widget ambianceZoneColor(BuildContext context, Color zoneColor, Color zoneWhite, bool zoneState, bool colorState) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    Color finalColor;
    if (zoneState) {
      if (colorState) {
        finalColor = zoneWhite;
      } else {
        finalColor = zoneColor;
      }
    } else {
      finalColor = Colors.black;
    }
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        width: widthScreen * 0.06,
        height: heightScreen * 0.06,
        decoration: BoxDecoration(shape: BoxShape.circle, color: finalColor),
      ),
    );
  }

  String alarmDayData(int dayID) {
    return '${boolToInt(daysStates[dayID])},${(hourList[dayID] * 3600) + (minutesList[dayID] * 60) + (secondsList[dayID])},'
        '${myAlarmTimeMinuteList[dayID] * 60 + (myAlarmTimeSecondList[dayID])},${alarmAmbiance[dayID]},${luminosityMinList[dayID]},${luminosityMaxList[dayID]},'
        '\"${dayZones[dayID]}\",${alarmOptionList[dayID]},${boolToInt(alarmOffList[dayID])}';
  }
}
