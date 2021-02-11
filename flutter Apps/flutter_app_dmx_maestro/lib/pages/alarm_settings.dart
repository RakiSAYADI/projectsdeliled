import 'package:flutter/material.dart';
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

  String myTimeHoursData = '00';
  String myTimeMinutesData = '00';
  String myTimeSecondsData = '00';

  int myTimeHoursPosition = 0;
  int myTimeMinutesPosition = 0;
  int myTimeSecondsPosition = 0;

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

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
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
      body: Container(
        child: Center(
          child: Builder(builder: (context) {
            return SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    SizedBox(height: heightScreen * 0.01),
                    Align(
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
                              });

                              myTimeHoursPosition = hourList[day];
                              myTimeMinutesPosition = minutesList[day];
                              myTimeSecondsPosition = secondsList[day];

                              myTimeHoursData = myTimeHours.elementAt(myTimeHoursPosition);
                              myTimeMinutesData = myTimeMinutes.elementAt(myTimeMinutesPosition);
                              myTimeSecondsData = myTimeSeconds.elementAt(myTimeSecondsPosition);
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
                    SizedBox(height: heightScreen * 0.02),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Divider(
                        thickness: 1.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: heightScreen * 0.02),
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
                    SizedBox(height: heightScreen * 0.05),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Heure d\'activation :',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: heightScreen * 0.02),
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
                    SizedBox(height: heightScreen * 0.04),
                    Text(
                      'Durée d\'activation :',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: heightScreen * 0.02),
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
                    SizedBox(height: heightScreen * 0.04),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Divider(
                        thickness: 1.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: heightScreen * 0.04),
                    Text(
                      'Séléctionner votre couleur :',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: heightScreen * 0.02),
                    HSLColorPicker(
                      onChanged: (colorSelected) {},
                      size: widthScreen * 0.3 + heightScreen * 0.2,
                      strokeWidth: 5,
                      thumbSize: 9,
                      thumbStrokeSize: 3,
                      showCenterColorIndicator: true,
                      centerColorIndicatorSize: 80,
                      initialColor: Colors.blueAccent,
                    ),
                    SizedBox(height: heightScreen * 0.04),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Divider(
                        thickness: 1.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: heightScreen * 0.04),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
