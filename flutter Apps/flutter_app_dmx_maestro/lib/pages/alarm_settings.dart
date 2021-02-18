import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app_dmx_maestro/services/uvcToast.dart';
import 'package:flutter_blue/flutter_blue.dart';
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

  List<Color> hueInitial = [
    Colors.blueAccent,
    Colors.blueAccent,
    Colors.blueAccent,
    Colors.blueAccent,
    Colors.blueAccent,
    Colors.blueAccent,
    Colors.blueAccent
  ];

  List<int> hourList = [0, 0, 0, 0, 0, 0, 0];
  List<int> minutesList = [0, 0, 0, 0, 0, 0, 0];
  List<int> secondsList = [0, 0, 0, 0, 0, 0, 0];

  String myTimeHoursData = '00';
  String myTimeMinutesData = '00';
  String myTimeSecondsData = '00';

  int myTimeHoursPosition = 0;
  int myTimeMinutesPosition = 0;
  int myTimeSecondsPosition = 0;

  Map bleDeviceData = {};
  ToastyMessage myUvcToast;

  Color hueOfTheDay;

  List<String> myTimeHours = [
    '00',
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23'
  ];

  List<String> myTimeMinutes = [
    '00',
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '29',
    '30',
    '31',
    '32',
    '33',
    '34',
    '35',
    '36',
    '37',
    '38',
    '39',
    '40',
    '41',
    '42',
    '43',
    '44',
    '45',
    '46',
    '47',
    '48',
    '49',
    '50',
    '51',
    '52',
    '53',
    '54',
    '55',
    '56',
    '57',
    '58',
    '59'
  ];

  List<String> myTimeSeconds = [
    '00',
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '29',
    '30',
    '31',
    '32',
    '33',
    '34',
    '35',
    '36',
    '37',
    '38',
    '39',
    '40',
    '41',
    '42',
    '43',
    '44',
    '45',
    '46',
    '47',
    '48',
    '49',
    '50',
    '51',
    '52',
    '53',
    '54',
    '55',
    '56',
    '57',
    '58',
    '59'
  ];

  String myAlarmTimeMinuteData = '  5 sec';
  List<int> myAlarmTimeMinuteList = [0, 0, 0, 0, 0, 0, 0];
  int myAlarmTimeMinutePosition = 0;

  List<String> myAlarmTimeMinute = [
    '  5 sec',
    ' 10 sec',
    ' 20 sec',
    ' 30 sec',
    '  1 min',
    '  2 min',
    '  5 min',
    ' 10 min',
    ' 15 min',
    ' 20 min',
    ' 25 min',
    ' 30 min',
    ' 35 min',
    ' 40 min',
    ' 45 min',
    ' 50 min',
    ' 55 min',
    ' 60 min',
    ' 65 min',
    ' 70 min',
    ' 75 min',
    ' 80 min',
    ' 85 min',
    ' 90 min',
    ' 95 min',
    '100 min',
    '105 min',
    '110 min',
    '115 min',
    '120 min',
  ];

  BluetoothCharacteristic characteristicMaestro;
  BluetoothCharacteristic characteristicWifi;
  BluetoothDevice myDevice;

  String dataMaestro;

  bool firstDisplayMainWidget = true;

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
  }

  bool intToBool(int a) => a == 0 ? false : true;

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    bleDeviceData = bleDeviceData.isNotEmpty ? bleDeviceData : ModalRoute.of(context).settings.arguments;
    myDevice = bleDeviceData['bleDevice'];
    characteristicMaestro = bleDeviceData['characteristicMaestro'];
    characteristicWifi = bleDeviceData['characteristicWifi'];
    dataMaestro = bleDeviceData['dataMaestro'];
    try {
      var parsedJson = json.decode('{\"lum\":[0,1400,1,\"FFFFFF\"],'
          '\"mar\":[1,11400,2,\"00FFFF\"],\"mer\":[0,21400,3,\"0000FF\"],'
          '\"jeu\":[1,31400,4,\"000000\"],\"ven\":[0,41400,5,\"FF0000\"],'
          '\"sam\":[1,51400,6,\"FFFF00\"],\"dim\":[0,61400,7,\"FFFFFF\"]}');
      readWakeUpDataPerDay(parsedJson['lum'], 0);
      readWakeUpDataPerDay(parsedJson['mar'], 1);
      readWakeUpDataPerDay(parsedJson['mer'], 2);
      readWakeUpDataPerDay(parsedJson['jeu'], 3);
      readWakeUpDataPerDay(parsedJson['ven'], 4);
      readWakeUpDataPerDay(parsedJson['sam'], 5);
      readWakeUpDataPerDay(parsedJson['dim'], 6);
    } catch (e) {
      print('erreur');
    }
    if (firstDisplayMainWidget) {
      firstDisplayMainWidget = false;
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Alarme Automatique'),
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
                          hueOfTheDay = hueInitial[day];
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
                            child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                              new SizedBox(width: 4.0),
                              new Text("Lun.", style: TextStyle(fontSize: 15, color: activationButtonColor[0], fontWeight: FontWeight.bold))
                            ])),
                        Container(
                            width: (widthScreen - 84) / 7,
                            child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                              new SizedBox(width: 4.0),
                              new Text("Mar.", style: TextStyle(fontSize: 15, color: activationButtonColor[1], fontWeight: FontWeight.bold))
                            ])),
                        Container(
                            width: (widthScreen - 84) / 7,
                            child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                              new SizedBox(width: 4.0),
                              new Text("Mer.", style: TextStyle(fontSize: 15, color: activationButtonColor[2], fontWeight: FontWeight.bold))
                            ])),
                        Container(
                            width: (widthScreen - 84) / 7,
                            child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                              new SizedBox(width: 4.0),
                              new Text("Jeu.", style: TextStyle(fontSize: 15, color: activationButtonColor[3], fontWeight: FontWeight.bold))
                            ])),
                        Container(
                            width: (widthScreen - 84) / 7,
                            child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                              new SizedBox(width: 4.0),
                              new Text("Ven.", style: TextStyle(fontSize: 15, color: activationButtonColor[4], fontWeight: FontWeight.bold))
                            ])),
                        Container(
                            width: (widthScreen - 84) / 7,
                            child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                              new SizedBox(width: 4.0),
                              new Text("Sam.", style: TextStyle(fontSize: 15, color: activationButtonColor[5], fontWeight: FontWeight.bold))
                            ])),
                        Container(
                            width: (widthScreen - 84) / 7,
                            child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                              new SizedBox(width: 4.0),
                              new Text("Dim.", style: TextStyle(fontSize: 15, color: activationButtonColor[6], fontWeight: FontWeight.bold))
                            ])),
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
              child: Divider(
                thickness: 1.0,
                color: Colors.grey[600],
              ),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Divider(
                thickness: 1.0,
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Séléctionner votre couleur :',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: HSLColorPicker(
                onChanged: (colorSelected) {
                  hueInitial[day] = colorSelected.toColor();

                  hueOfTheDay = colorSelected.toColor();
                },
                size: widthScreen * 0.3 + heightScreen * 0.1,
                strokeWidth: 5,
                thumbSize: 9,
                thumbStrokeSize: 3,
                showCenterColorIndicator: true,
                centerColorIndicatorSize: 50,
                initialColor: hueOfTheDay,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Divider(
                thickness: 1.0,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
