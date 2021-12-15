import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterappdentaluvc/services/AutoUVCService.dart';
import 'package:flutterappdentaluvc/services/CSVfileClass.dart';
import 'package:flutterappdentaluvc/services/languageDataBase.dart';
import 'package:flutterappdentaluvc/services/uvcToast.dart';
import 'package:flutterappdentaluvc/services/DataVariables.dart';

class UVCAuto extends StatefulWidget {
  @override
  _UVCAutoState createState() => _UVCAutoState();
}

class _UVCAutoState extends State<UVCAuto> {
  List<bool> days = [true, false, false, false, false, false, false];
  List<bool> daysStates = [false, false, false, false, false, false, false];

  List<int> hourList = [0, 0, 0, 0, 0, 0, 0];
  List<int> minutesList = [0, 0, 0, 0, 0, 0, 0];
  List<int> secondsList = [0, 0, 0, 0, 0, 0, 0];
  List<int> delayList = [0, 0, 0, 0, 0, 0, 0];
  List<int> durationList = [0, 0, 0, 0, 0, 0, 0];

  String daysInHex;
  String activationButtonText = deactivatedTextLanguageArray[languageArrayIdentifier];
  List<Color> activationButtonColor = [Colors.red, Colors.red, Colors.red, Colors.red, Colors.red, Colors.red, Colors.red];
  bool activationButtonState = false;
  Color saveButtonColor = Colors.blue[400];
  int day = 0;

  ToastyMessage myUvcToast;

  UVCDataFile uvcDataFile = UVCDataFile();

  Map<String, dynamic> uvcAutoDataJson;

  int boolToInt(bool a) => a == true ? 1 : 0;

  bool intToBool(int a) => a == 1 ? true : false;

  bool charToBool(String a) => a == '1' ? true : false;

  String myTimeHoursData = '00';
  String myTimeMinutesData = '00';
  String myTimeSecondsData = '00';
  String myExtinctionTimeMinuteData = ' 30 sec';
  String myActivationTimeMinuteData = ' 10 sec';

  int myTimeHoursPosition = 0;
  int myTimeMinutesPosition = 0;
  int myTimeSecondsPosition = 0;
  int myExtinctionTimeMinutePosition = 0;
  int myActivationTimeMinutePosition = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myUvcToast = ToastyMessage(toastContext: context);
    autoUVCService.setContext(context);
    readUVCAuto();
  }

  void readDayData(String day, int position) {
    String timeDataList = uvcAutoDataJson[day].toString();
    List<int> timeDataIntList = _stringListAsciiToListInt(timeDataList.codeUnits);
    daysStates[position] = intToBool(timeDataIntList[0]);
    hourList[position] = timeDataIntList[1];
    minutesList[position] = timeDataIntList[2];
    secondsList[position] = timeDataIntList[3];
    delayList[position] = timeDataIntList[4];
    durationList[position] = timeDataIntList[5];
  }

  void readUVCAuto() async {
    String uvcAutoData = await uvcDataFile.readUVCAutoData();
    uvcAutoDataJson = jsonDecode(uvcAutoData);

    readDayData('Monday', 0);
    readDayData('Tuesday', 1);
    readDayData('Wednesday', 2);
    readDayData('Thursday', 3);
    readDayData('Friday', 4);
    readDayData('Saturday', 5);
    readDayData('Sunday', 6);

    setState(() {
      for (int i = 0; i < daysStates.length; i++) {
        if (daysStates[i]) {
          activationButtonColor[i] = Colors.green;
        } else {
          activationButtonColor[i] = Colors.red;
        }
      }
      if (daysStates[0]) {
        activationButtonText = activatedTextLanguageArray[languageArrayIdentifier];
        activationButtonColor[0] = Colors.green;
      } else {
        activationButtonText = deactivatedTextLanguageArray[languageArrayIdentifier];
        activationButtonColor[0] = Colors.red;
      }
    });

    myTimeHoursPosition = hourList[0];
    myTimeMinutesPosition = minutesList[0];
    myTimeSecondsPosition = secondsList[0];
    myActivationTimeMinutePosition = delayList[0];
    myExtinctionTimeMinutePosition = durationList[0];

    myTimeHoursData = myTimeHours.elementAt(myTimeHoursPosition);
    myTimeMinutesData = myTimeMinutes.elementAt(myTimeMinutesPosition);
    myTimeSecondsData = myTimeSeconds.elementAt(myTimeSecondsPosition);
    myActivationTimeMinuteData = myActivationTimeMinute.elementAt(myActivationTimeMinutePosition);
    myExtinctionTimeMinuteData = myExtinctionTimeMinute.elementAt(myExtinctionTimeMinutePosition);
  }

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.blue[400],
      appBar: AppBar(
        title: Text(autoUVCTitleTextLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Builder(builder: (context) {
          return Container(
            child: SingleChildScrollView(
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
                                activationButtonText = activatedTextLanguageArray[languageArrayIdentifier];
                                activationButtonColor[day] = Colors.green;
                              } else {
                                activationButtonText = deactivatedTextLanguageArray[languageArrayIdentifier];
                                activationButtonColor[day] = Colors.red;
                              }
                            });

                            myTimeHoursPosition = hourList[day];
                            myTimeMinutesPosition = minutesList[day];
                            myTimeSecondsPosition = secondsList[day];
                            myActivationTimeMinutePosition = delayList[day];
                            myExtinctionTimeMinutePosition = durationList[day];

                            myTimeHoursData = myTimeHours.elementAt(myTimeHoursPosition);
                            myTimeMinutesData = myTimeMinutes.elementAt(myTimeMinutesPosition);
                            myTimeSecondsData = myTimeSeconds.elementAt(myTimeSecondsPosition);
                            myActivationTimeMinuteData = myActivationTimeMinute.elementAt(myActivationTimeMinutePosition);
                            myExtinctionTimeMinuteData = myExtinctionTimeMinute.elementAt(myExtinctionTimeMinutePosition);
                          },
                          children: [
                            Container(
                                width: (widthScreen - 84) / 7,
                                child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                                  new SizedBox(width: 4.0),
                                  new Text(mondayTextLanguageArray[languageArrayIdentifier], style: TextStyle(fontSize: 15, color: activationButtonColor[0], fontWeight: FontWeight.bold))
                                ])),
                            Container(
                                width: (widthScreen - 84) / 7,
                                child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                                  new SizedBox(width: 4.0),
                                  new Text(tuesdayTextLanguageArray[languageArrayIdentifier], style: TextStyle(fontSize: 15, color: activationButtonColor[1], fontWeight: FontWeight.bold))
                                ])),
                            Container(
                                width: (widthScreen - 84) / 7,
                                child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                                  new SizedBox(width: 4.0),
                                  new Text(wednesdayTextLanguageArray[languageArrayIdentifier], style: TextStyle(fontSize: 15, color: activationButtonColor[2], fontWeight: FontWeight.bold))
                                ])),
                            Container(
                                width: (widthScreen - 84) / 7,
                                child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                                  new SizedBox(width: 4.0),
                                  new Text(thursdayTextLanguageArray[languageArrayIdentifier], style: TextStyle(fontSize: 15, color: activationButtonColor[3], fontWeight: FontWeight.bold))
                                ])),
                            Container(
                                width: (widthScreen - 84) / 7,
                                child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                                  new SizedBox(width: 4.0),
                                  new Text(fridayTextLanguageArray[languageArrayIdentifier], style: TextStyle(fontSize: 15, color: activationButtonColor[4], fontWeight: FontWeight.bold))
                                ])),
                            Container(
                                width: (widthScreen - 84) / 7,
                                child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                                  new SizedBox(width: 4.0),
                                  new Text(saturdayTextLanguageArray[languageArrayIdentifier], style: TextStyle(fontSize: 15, color: activationButtonColor[5], fontWeight: FontWeight.bold))
                                ])),
                            Container(
                                width: (widthScreen - 84) / 7,
                                child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                                  new SizedBox(width: 4.0),
                                  new Text(sundayTextLanguageArray[languageArrayIdentifier], style: TextStyle(fontSize: 15, color: activationButtonColor[6], fontWeight: FontWeight.bold))
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
                  TextButton(
                    onPressed: () {
                      activationButtonState = daysStates[day];
                      activationButtonState = !activationButtonState;
                      setState(() {
                        saveButtonColor = Colors.grey[400];
                        if (activationButtonState) {
                          activationButtonText = activatedTextLanguageArray[languageArrayIdentifier];
                          activationButtonColor[day] = Colors.green;
                        } else {
                          activationButtonText = deactivatedTextLanguageArray[languageArrayIdentifier];
                          activationButtonColor[day] = Colors.red;
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
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(activationButtonColor[day]),
                    ),
                  ),
                  SizedBox(height: heightScreen * 0.02),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        activationTimeTextLanguageArray[languageArrayIdentifier],
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
                                ignitionTimeTextLanguageArray[languageArrayIdentifier],
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
                                    saveButtonColor = Colors.grey[400];
                                    myActivationTimeMinuteData = data;
                                    myActivationTimeMinutePosition = myActivationTimeMinute.indexOf(data);
                                    delayList[day] = myActivationTimeMinutePosition;
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
                                durationDisinfectionTextLanguageArray[languageArrayIdentifier],
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
                                    saveButtonColor = Colors.grey[400];
                                    myExtinctionTimeMinuteData = data;
                                    myExtinctionTimeMinutePosition = myExtinctionTimeMinute.indexOf(data);
                                    durationList[day] = myExtinctionTimeMinutePosition;
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
                  TextButton(
                    onPressed: () async {
                      setState(() {
                        saveButtonColor = Colors.blue[400];
                      });
                      String uvcAutoData = '{'
                          '\"Monday\":[${boolToInt(daysStates[0])},${hourList[0]},${minutesList[0]},${secondsList[0]},${delayList[0]},${durationList[0]}],'
                          '\"Tuesday\":[${boolToInt(daysStates[1])},${hourList[1]},${minutesList[1]},${secondsList[1]},${delayList[1]},${durationList[1]}],'
                          '\"Wednesday\":[${boolToInt(daysStates[2])},${hourList[2]},${minutesList[2]},${secondsList[2]},${delayList[2]},${durationList[2]}],'
                          '\"Thursday\":[${boolToInt(daysStates[3])},${hourList[3]},${minutesList[3]},${secondsList[3]},${delayList[3]},${durationList[3]}],'
                          '\"Friday\":[${boolToInt(daysStates[4])},${hourList[4]},${minutesList[4]},${secondsList[4]},${delayList[4]},${durationList[4]}],'
                          '\"Saturday\":[${boolToInt(daysStates[5])},${hourList[5]},${minutesList[5]},${secondsList[5]},${delayList[5]},${durationList[5]}],'
                          '\"Sunday\":[${boolToInt(daysStates[6])},${hourList[6]},${minutesList[6]},${secondsList[6]},${delayList[6]},${durationList[6]}]'
                          '}';
                      await uvcDataFile.saveUVCAutoData(uvcAutoData);
                      myUvcToast.setToastDuration(3);
                      myUvcToast.setToastMessage(savedConfigurationTextLanguageArray[languageArrayIdentifier]);
                      myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
                      print(autoUVCService.getUVCAutoServiceState());
                      Navigator.pop(context, true);
                      if (!autoUVCService.getUVCAutoServiceState()) {
                        autoUVCService.startUVCService();
                      } else {
                        autoUVCService.stopUVCAutoService();
                        await Future.delayed(const Duration(seconds: 2));
                        autoUVCService.startUVCService();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        saveTextLanguageArray[languageArrayIdentifier],
                        style: TextStyle(color: Colors.white, fontSize: widthScreen * 0.02),
                      ),
                    ),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(saveButtonColor),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  List<int> _stringListAsciiToListInt(List<int> listInt) {
    List<int> ourListInt = [0];
    int listIntLength = listInt.length;
    int intNumber = 1;
    for (int i = 0; i < listIntLength; i++) {
      if (listInt[i] == 44) {
        intNumber++;
      }
    }
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
