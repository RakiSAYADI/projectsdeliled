import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterappdentaluvc/services/CSVfileClass.dart';

class UVCAuto extends StatefulWidget {
  @override
  _UVCAutoState createState() => _UVCAutoState();
}

class _UVCAutoState extends State<UVCAuto> {
  List<bool> days;
  List<bool> daysStates = [false, false, false, false, false, false, false];

  List<int> hourList = [0, 0, 0, 0, 0, 0, 0];
  List<int> minutesList = [0, 0, 0, 0, 0, 0, 0];
  List<int> delayList = [0, 0, 0, 0, 0, 0, 0];
  List<int> durationList = [0, 0, 0, 0, 0, 0, 0];

  String daysInHex;
  String activationButtonText;
  Color activationButtonColor;
  bool activationButtonState = false;
  int day = 0;

  UVCDataFile uvcDataFile = UVCDataFile();

  Map<String, dynamic> uvcAutoDataJson;

  int boolToInt(bool a) => a == true ? 1 : 0;

  bool intToBool(int a) => a == 1 ? true : false;

  String myTimeHoursData = '00';
  String myTimeMinutesData = '00';
  String myExtinctionTimeMinuteData = ' 30 sec';
  String myActivationTimeMinuteData = ' 10 sec';

  int myTimeHoursPosition = 0;
  int myTimeMinutesPosition = 0;
  int myExtinctionTimeMinutePosition = 0;
  int myActivationTimeMinutePosition = 0;

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

  List<String> myExtinctionTimeMinute = [
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

  List<String> myActivationTimeMinute = [
    ' 10 sec',
    ' 20 sec',
    ' 30 sec',
    ' 40 sec',
    ' 50 sec',
    ' 60 sec',
    ' 70 sec',
    ' 80 sec',
    ' 90 sec',
    '100 sec',
    '110 sec',
    '120 sec',
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readUVCAuto();
    days = [false, false, false, false, false, false, false];
    setState(() {
      if (activationButtonState) {
        activationButtonText = 'Activé';
        activationButtonColor = Colors.green;
      } else {
        activationButtonText = 'Desactivé';
        activationButtonColor = Colors.red;
      }
    });
  }

  void readDayData(String day, int position) {
    String timeDataList = uvcAutoDataJson[day].toString();
    print(timeDataList);
    hourList[position] = _stringListAsciiToListInt(timeDataList.codeUnits)[0];
    minutesList[position] = _stringListAsciiToListInt(timeDataList.codeUnits)[1];
    delayList[position] = _stringListAsciiToListInt(timeDataList.codeUnits)[2];
    durationList[position] = _stringListAsciiToListInt(timeDataList.codeUnits)[3];
  }

  void readUVCAuto() async {
    String uvcAutoData = await uvcDataFile.readUVCAutoData();
    uvcAutoDataJson = jsonDecode(uvcAutoData);
    daysInHex = uvcAutoDataJson['days'];
    int days = int.parse(daysInHex, radix: 16);
    daysStates[0] = intToBool(days % 2);
    daysStates[1] = intToBool(((days % 4) / 2).round());
    daysStates[2] = intToBool(((days % 8) / 4).round());
    daysStates[3] = intToBool(((days % 16) / 8).round());
    daysStates[4] = intToBool(((days % 32) / 16).round());
    daysStates[5] = intToBool(((days % 64) / 32).round());
    daysStates[6] = intToBool((days / 64).round());

    readDayData('Monday', 0);
    readDayData('Tuesday', 1);
    readDayData('Wednesday', 2);
    readDayData('Thursday', 3);
    readDayData('Friday', 4);
    readDayData('Saturday', 5);
    readDayData('Sunday', 6);
  }

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.blue[400],
      appBar: AppBar(
        title: const Text('UVC Automatique'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Builder(builder: (context) {
          return Container(
            child: Column(
              children: [
                SizedBox(height: heightScreen * 0.05),
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
                              activationButtonColor = Colors.green;
                            } else {
                              activationButtonText = 'Desactivé';
                              activationButtonColor = Colors.red;
                            }
                          });

                          myTimeHoursPosition = hourList[day];
                          myTimeMinutesPosition = minutesList[day];
                          myActivationTimeMinutePosition = delayList[day];
                          myExtinctionTimeMinutePosition = durationList[day];

                          myTimeHoursData = myTimeHours.elementAt(myTimeHoursPosition);
                          myTimeMinutesData = myTimeMinutes.elementAt(myTimeMinutesPosition);
                          myActivationTimeMinuteData = myActivationTimeMinute.elementAt(myActivationTimeMinutePosition);
                          myExtinctionTimeMinuteData = myExtinctionTimeMinute.elementAt(myExtinctionTimeMinutePosition);
                        },
                        children: [
                          Container(
                              width: (widthScreen - 84) / 7,
                              child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[new SizedBox(width: 4.0), new Text("Lundi", style: TextStyle(fontSize: 15))])),
                          Container(
                              width: (widthScreen - 84) / 7,
                              child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[new SizedBox(width: 4.0), new Text("Mardi", style: TextStyle(fontSize: 15))])),
                          Container(
                              width: (widthScreen - 84) / 7,
                              child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[new SizedBox(width: 4.0), new Text("Mercredi", style: TextStyle(fontSize: 15))])),
                          Container(
                              width: (widthScreen - 84) / 7,
                              child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[new SizedBox(width: 4.0), new Text("Jeudi", style: TextStyle(fontSize: 15))])),
                          Container(
                              width: (widthScreen - 84) / 7,
                              child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[new SizedBox(width: 4.0), new Text("Vendredi", style: TextStyle(fontSize: 15))])),
                          Container(
                              width: (widthScreen - 84) / 7,
                              child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[new SizedBox(width: 4.0), new Text("Samedi", style: TextStyle(fontSize: 15))])),
                          Container(
                              width: (widthScreen - 84) / 7,
                              child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[new SizedBox(width: 4.0), new Text("Dimanche", style: TextStyle(fontSize: 15))])),
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
                FlatButton(
                  onPressed: () {
                    activationButtonState = daysStates[day];
                    activationButtonState = !activationButtonState;
                    setState(() {
                      if (activationButtonState) {
                        activationButtonText = 'Activé';
                        activationButtonColor = Colors.green;
                      } else {
                        activationButtonText = 'Desactivé';
                        activationButtonColor = Colors.red;
                      }
                    });
                    daysStates[day] = activationButtonState;
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      activationButtonText,
                      style: TextStyle(color: Colors.white, fontSize: widthScreen * 0.02),
                    ),
                  ),
                  color: activationButtonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
                SizedBox(height: heightScreen * 0.02),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Heure d\'activation :',
                      style: TextStyle(
                        fontSize: widthScreen * 0.03,
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
                              myTimeHoursData = data;
                              myTimeHoursPosition = myTimeHours.indexOf(data);
                              hourList[day] = myTimeHoursPosition;
                              print(myTimeHoursPosition);
                            });
                          },
                          items: myTimeHours.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontSize: widthScreen * 0.03,
                                  color: Colors.grey[600],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        Text(
                          ' : ',
                          style: TextStyle(
                            fontSize: widthScreen * 0.03,
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
                              myTimeMinutesData = data;
                              myTimeMinutesPosition = myTimeMinutes.indexOf(data);
                              minutesList[day] = myTimeMinutesPosition;
                              print(myTimeMinutesPosition);
                            });
                          },
                          items: myTimeMinutes.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontSize: widthScreen * 0.03,
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: heightScreen * 0.04),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/delais_logo.png',
                              height: heightScreen * 0.09,
                              width: widthScreen * 0.5,
                            ),
                            SizedBox(height: heightScreen * 0.03),
                            Text(
                              'Délais avant allumage :',
                              style: TextStyle(
                                fontSize: widthScreen * 0.03,
                                color: Colors.black,
                              ),
                            ),
                            DropdownButton<String>(
                              value: myActivationTimeMinuteData,
                              icon: Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                              elevation: 16,
                              style: TextStyle(color: Colors.grey[800], fontSize: 18),
                              onChanged: (String data) {
                                setState(() {
                                  myActivationTimeMinuteData = data;
                                  myActivationTimeMinutePosition = myActivationTimeMinute.indexOf(data);
                                  delayList[day] = myActivationTimeMinutePosition;
                                  print(myActivationTimeMinutePosition);
                                });
                              },
                              items: myActivationTimeMinute.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      fontSize: widthScreen * 0.03,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Image.asset(
                              'assets/duree_logo.png',
                              height: heightScreen * 0.09,
                              width: widthScreen * 0.5,
                            ),
                            SizedBox(height: heightScreen * 0.03),
                            Text(
                              'Durée de la désinfection :',
                              style: TextStyle(
                                fontSize: widthScreen * 0.03,
                                color: Colors.black,
                              ),
                            ),
                            DropdownButton<String>(
                              value: myExtinctionTimeMinuteData,
                              icon: Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                              elevation: 16,
                              style: TextStyle(color: Colors.grey[800], fontSize: widthScreen * 0.04),
                              onChanged: (String data) {
                                setState(() {
                                  myExtinctionTimeMinuteData = data;
                                  myExtinctionTimeMinutePosition = myExtinctionTimeMinute.indexOf(data);
                                  durationList[day] = myExtinctionTimeMinutePosition;
                                  print(myExtinctionTimeMinutePosition);
                                });
                              },
                              items: myExtinctionTimeMinute.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      fontSize: widthScreen * 0.03,
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
                SizedBox(height: heightScreen * 0.04),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Divider(
                    thickness: 1.0,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: heightScreen * 0.04),
                FlatButton(
                  onPressed: () async {
                    String days = ((boolToInt(daysStates[6]) * 64) +
                            (boolToInt(daysStates[5]) * 32) +
                            (boolToInt(daysStates[4]) * 16) +
                            (boolToInt(daysStates[3]) * 8) +
                            (boolToInt(daysStates[2]) * 4) +
                            (boolToInt(daysStates[1]) * 2) +
                            boolToInt(daysStates[0]))
                        .toRadixString(16);
                    String uvcAutoData = '{\"days\":\"$days\",'
                        '\"Monday\":[${hourList[0]},${minutesList[0]},${delayList[0]},${durationList[0]}],'
                        '\"Tuesday\":[${hourList[1]},${minutesList[1]},${delayList[1]},${durationList[1]}],'
                        '\"Wednesday\":[${hourList[2]},${minutesList[2]},${delayList[2]},${durationList[2]}],'
                        '\"Thursday\":[${hourList[3]},${minutesList[3]},${delayList[3]},${durationList[3]}],'
                        '\"Friday\":[${hourList[4]},${minutesList[4]},${delayList[4]},${durationList[4]}],'
                        '\"Saturday\":[${hourList[5]},${minutesList[5]},${delayList[5]},${durationList[5]}],'
                        '\"Sunday\":[${hourList[6]},${minutesList[6]},${delayList[6]},${durationList[6]}]'
                        '}';
                    await uvcDataFile.saveUVCAutoData(uvcAutoData);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Enregistrer',
                      style: TextStyle(color: Colors.white, fontSize: widthScreen * 0.02),
                    ),
                  ),
                  color: Colors.blue[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  List<int> _stringListAsciiToListInt(List<int> listInt) {
    List<int> ourListInt = [0];
    int listIntLength = listInt.length;
    int intNumber = (listIntLength / 4).round();
    ourListInt.length = intNumber;
    int listCounter;
    int listIntCounter = 0;
    String numberString = '';
    if (listInt.first == 91 && listInt.last == 93) {
      for (listCounter = 0; listCounter < listIntLength - 1; listCounter++) {
        if (!((listInt[listCounter] == 91) || (listInt[listCounter] == 93) || (listInt[listCounter] == 32) || (listInt[listCounter] == 44))) {
          numberString = '';
          do {
            numberString += String.fromCharCode(listInt[listCounter]);
            listCounter++;
          } while (!((listInt[listCounter] == 44) || (listInt[listCounter] == 93)));
          ourListInt[listIntCounter] = int.parse(numberString);
          listIntCounter++;
        }
      }
      return ourListInt;
    } else {
      return [0];
    }
  }
}
