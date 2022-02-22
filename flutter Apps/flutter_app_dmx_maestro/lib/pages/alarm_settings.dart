import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_dmx_maestro/services/DataVariables.dart';
import 'package:flutter_app_dmx_maestro/services/uvcToast.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:hsl_colorpicker/HSLColorPicker.dart';

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
  int day = 0;

  List<int> hourList = [0, 0, 0, 0, 0, 0, 0];
  List<int> minutesList = [0, 0, 0, 0, 0, 0, 0];
  List<int> secondsList = [0, 0, 0, 0, 0, 0, 0];

  List<int> luminosityMinList = [0, 0, 0, 0, 0, 0, 0];
  List<int> luminosityMaxList = [100, 100, 100, 100, 100, 100, 100];
  List<String> dayZones = ['F', 'F', 'F', 'F', 'F', 'F', 'F'];

  String myTimeHoursData = '00';
  String myTimeMinutesData = '00';
  String myTimeSecondsData = '00';

  int myTimeHoursPosition = 0;
  int myTimeMinutesPosition = 0;
  int myTimeSecondsPosition = 0;

  ToastyMessage myUvcToast;

  String myAlarmTimeMinuteData = '  5 sec';
  List<int> myAlarmTimeMinuteList = [0, 0, 0, 0, 0, 0, 0];
  int myAlarmTimeMinutePosition = 0;

  bool firstDisplayMainWidget = true;

  List<Color> hueInitial = [Colors.blueAccent, Colors.blueAccent, Colors.blueAccent, Colors.blueAccent, Colors.blueAccent, Colors.blueAccent, Colors.blueAccent];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myUvcToast = ToastyMessage(toastContext: context);
  }

  void readWakeUpDataPerDay(List<dynamic> day, int dayID) {
    daysStates[dayID] = intToBool(day[0]);
    int timeSelection = day[1];
    hourList[dayID] = timeSelection ~/ 3600;
    minutesList[dayID] = (timeSelection % 3600) ~/ 60;
    secondsList[dayID] = timeSelection % 60;
    myAlarmTimeMinuteList[dayID] = day[2];
    final color = StringBuffer();
    if (day[3].length == 6 || day[3].length == 7) color.write('ff');
    color.write(day[3].replaceFirst('#', ''));
    hueInitial[dayID] = Color(int.parse(color.toString(), radix: 16));
    luminosityMinList[dayID] = day[4];
    luminosityMaxList[dayID] = day[5];
    dayZones[dayID] = day[6];
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
    if (firstDisplayMainWidget) {
      try {
        var parsedJson;
        if (Platform.isAndroid) {
          parsedJson = json.decode(dataMaestro2);
          readWakeUpDataPerDay(parsedJson['lun'], 0);
          readWakeUpDataPerDay(parsedJson['mar'], 1);
          readWakeUpDataPerDay(parsedJson['mer'], 2);
          readWakeUpDataPerDay(parsedJson['jeu'], 3);
          readWakeUpDataPerDay(parsedJson['ven'], 4);
          readWakeUpDataPerDay(parsedJson['sam'], 5);
          readWakeUpDataPerDay(parsedJson['dim'], 6);
        }
        if (Platform.isIOS) {
          parsedJson = json.decode(dataMaestroIOS4);
          readWakeUpDataPerDay(parsedJson['lun'], 0);
          readWakeUpDataPerDay(parsedJson['mar'], 1);
          readWakeUpDataPerDay(parsedJson['mer'], 2);
          readWakeUpDataPerDay(parsedJson['jeu'], 3);
          parsedJson = json.decode(dataMaestroIOS5);
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

        myTimeHoursData = myTimeHours.elementAt(myTimeHoursPosition);
        myTimeMinutesData = myTimeMinutes.elementAt(myTimeMinutesPosition);
        myTimeSecondsData = myTimeSeconds.elementAt(myTimeSecondsPosition);

        myAlarmTimeMinuteData = myAlarmTimeMinute.elementAt(myAlarmTimeMinutePosition);
      } catch (e) {
        print('erreur');
      }
      firstDisplayMainWidget = false;
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Planning d\'ambiances',
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 10.0,
        color: Colors.grey[200],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                thickness: 1.0,
                color: Colors.grey[600],
              ),
            ),
            IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  VerticalDivider(
                    thickness: 1.0,
                    color: Colors.grey[600],
                  ),
                  FlatButton(
                    onPressed: () async {
                      setState(() {
                        saveButtonColor = Colors.blue[400];
                      });
                      if (myDevice.getConnectionState()) {
                        await characteristicMaestro.write('{\"lun\":[${alarmDayData(0)}],'
                                '\"mar\":[${alarmDayData(1)}],\"mer\":[${alarmDayData(2)}],'
                                '\"jeu\":[${alarmDayData(3)}],\"ven\":[${alarmDayData(4)}],'
                                '\"sam\":[${alarmDayData(5)}],\"dim\":[${alarmDayData(6)}]}'
                            .codeUnits);
                        await Future.delayed(Duration(milliseconds: 500));
                        dataMaestro = String.fromCharCodes(await characteristicWifi.read());
                        await Future.delayed(Duration(milliseconds: 500));
                        dataMaestro2 = String.fromCharCodes(await characteristicWifi.read());
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'Enregistrer',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                    color: saveButtonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  VerticalDivider(
                    thickness: 1.0,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                thickness: 1.0,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
              child: Align(
                alignment: Alignment.topCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ToggleButtons(
                      isSelected: days,
                      onPressed: (int index) async {
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
                        });

                        setState(() {
                          if (daysStates[day]) {
                            activationButtonText = 'Activé';
                            activationButtonColor[day] = Colors.green;
                          } else {
                            activationButtonText = 'Désactivé';
                            activationButtonColor[day] = Colors.red;
                          }
                          hueInitial[day] = hueInitial[day];
                        });

                        myTimeHoursPosition = hourList[day];
                        myTimeMinutesPosition = minutesList[day];
                        myTimeSecondsPosition = secondsList[day];
                        myAlarmTimeMinutePosition = myAlarmTimeMinuteList[day];

                        myTimeHoursData = myTimeHours.elementAt(myTimeHoursPosition);
                        myTimeMinutesData = myTimeMinutes.elementAt(myTimeMinutesPosition);
                        myTimeSecondsData = myTimeSeconds.elementAt(myTimeSecondsPosition);

                        myAlarmTimeMinuteData = myAlarmTimeMinute.elementAt(myAlarmTimeMinutePosition);
                      },
                      children: [
                        Container(
                            width: (widthScreen - 84) / 7,
                            child: new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[new SizedBox(width: 4.0), new Text("Lun.", style: TextStyle(fontSize: 15, color: activationButtonColor[0], fontWeight: FontWeight.bold))])),
                        Container(
                            width: (widthScreen - 84) / 7,
                            child: new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[new SizedBox(width: 4.0), new Text("Mar.", style: TextStyle(fontSize: 15, color: activationButtonColor[1], fontWeight: FontWeight.bold))])),
                        Container(
                            width: (widthScreen - 84) / 7,
                            child: new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[new SizedBox(width: 4.0), new Text("Mer.", style: TextStyle(fontSize: 15, color: activationButtonColor[2], fontWeight: FontWeight.bold))])),
                        Container(
                            width: (widthScreen - 84) / 7,
                            child: new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[new SizedBox(width: 4.0), new Text("Jeu.", style: TextStyle(fontSize: 15, color: activationButtonColor[3], fontWeight: FontWeight.bold))])),
                        Container(
                            width: (widthScreen - 84) / 7,
                            child: new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[new SizedBox(width: 4.0), new Text("Ven.", style: TextStyle(fontSize: 15, color: activationButtonColor[4], fontWeight: FontWeight.bold))])),
                        Container(
                            width: (widthScreen - 84) / 7,
                            child: new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[new SizedBox(width: 4.0), new Text("Sam.", style: TextStyle(fontSize: 15, color: activationButtonColor[5], fontWeight: FontWeight.bold))])),
                        Container(
                            width: (widthScreen - 84) / 7,
                            child: new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[new SizedBox(width: 4.0), new Text("Dim.", style: TextStyle(fontSize: 15, color: activationButtonColor[6], fontWeight: FontWeight.bold))])),
                      ],
                      borderWidth: 2,
                      color: Colors.grey,
                      selectedBorderColor: Colors.black,
                      selectedColor: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
            ),
            FlatButton(
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
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
              color: activationButtonColor[day],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                    child: Image.asset(
                      'assets/reveil-dmx.png',
                      height: heightScreen * 0.1,
                      width: widthScreen * 0.2,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Heure d\'activation :',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Row(
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
                                    color: Colors.grey[600],
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
                                    color: Colors.grey[600],
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
                                    color: Colors.grey[600],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  bigCircle(50, 50),
                  Text(
                    'Couleur \n à appliquer',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () async {
                      await colorSettingWidget(context);
                      setState(() {
                        hueInitial[day] = hueInitial[day];
                      });
                    },
                    color: Colors.black,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Divider(
                thickness: 3.0,
                color: Colors.grey[600],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                    child: Image.asset(
                      'assets/sablier-dmx.png',
                      height: heightScreen * 0.15,
                      width: widthScreen * 0.2,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Durée d\'activation :',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: (widthScreen * 0.1)),
                        child: DropdownButton<String>(
                          value: myAlarmTimeMinuteData,
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
                              myAlarmTimeMinuteData = data;
                              myAlarmTimeMinutePosition = myAlarmTimeMinute.indexOf(data);
                              myAlarmTimeMinuteList[day] = myAlarmTimeMinutePosition;
                            });
                          },
                          items: myAlarmTimeMinute.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Séléctionner la luminosité ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'de départ ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    Image.asset(
                      'assets/arrivee.png',
                      height: heightScreen * 0.05,
                      width: widthScreen * 0.05,
                    ),
                    Text(
                      ' d\'arrivée',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    Image.asset(
                      'assets/depart.png',
                      height: heightScreen * 0.05,
                      width: widthScreen * 0.05,
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
              child: FlutterSlider(
                values: [luminosityMinList[day].toDouble(), luminosityMaxList[day].toDouble()],
                max: 100,
                min: 0,
                rangeSlider: true,
                handlerAnimation: FlutterSliderHandlerAnimation(curve: Curves.elasticOut, reverseCurve: null, duration: Duration(milliseconds: 700), scale: 1.4),
                onDragging: (handlerIndex, lowerValue, upperValue) {
                  luminosityMinList[day] = lowerValue.toInt();
                  luminosityMaxList[day] = upperValue.toInt();
                  setState(() {});
                },
                handler: FlutterSliderHandler(
                  decoration: BoxDecoration(),
                  child: Image.asset(
                    'assets/arrivee.png',
                    height: heightScreen * 0.1,
                    width: widthScreen * 0.1,
                  ),
                ),
                rightHandler: FlutterSliderHandler(
                  decoration: BoxDecoration(),
                  child: Image.asset(
                    'assets/depart.png',
                    height: heightScreen * 0.1,
                    width: widthScreen * 0.1,
                  ),
                ),
                trackBar: FlutterSliderTrackBar(activeTrackBar: BoxDecoration(color: Colors.grey[700]), activeTrackBarHeight: 15, inactiveTrackBarHeight: 15),
                hatchMark: FlutterSliderHatchMark(
                  density: 0.5, // means 50 lines, from 0 to 100 percent
                  labels: [
                    FlutterSliderHatchMarkLabel(percent: 0, label: Text('0%')),
                    FlutterSliderHatchMarkLabel(percent: 100, label: Text('100%')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bigCircle(double width, double height) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      child: Container(
        width: width,
        height: height,
        decoration: new BoxDecoration(
          color: hueInitial[day],
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black, spreadRadius: 3),
          ],
        ),
      ),
    );
  }

  Future<void> colorSettingWidget(BuildContext context) async {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Changer votre Ambiance'),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: HSLColorPicker(
                    onChanged: (colorSelected) {
                      hueInitial[day] = colorSelected.toColor();
                    },
                    size: screenWidth * 0.4 + screenHeight * 0.1,
                    strokeWidth: screenWidth * 0.04,
                    thumbSize: 0.00001,
                    thumbStrokeSize: screenWidth * 0.005 + screenHeight * 0.005,
                    showCenterColorIndicator: true,
                    centerColorIndicatorSize: screenWidth * 0.05 + screenHeight * 0.05,
                    initialColor: hueInitial[day],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Sauvgarder',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                'Annuler',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String alarmDayData(int dayID) {
    return '${boolToInt(daysStates[dayID])},${(hourList[dayID] * 3600) + (minutesList[dayID] * 60) + (secondsList[dayID])},'
        '${myAlarmTimeMinuteList[dayID]},\"${hueInitial[dayID].toString().split("0x")[1].toUpperCase().replaceFirst("FF", "").replaceAll(")", "")}\",'
        '${luminosityMinList[dayID]},${luminosityMaxList[dayID]},\"${dayZones[dayID]}\"';
  }
}
