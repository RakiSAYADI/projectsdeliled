import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wifiglobalapp/services/data_variables.dart';
import 'package:wifiglobalapp/services/language_database.dart';
import 'package:wifiglobalapp/services/uvc_toast.dart';

class UVCAuto extends StatefulWidget {
  @override
  _UVCAutoState createState() => _UVCAutoState();
}

class _UVCAutoState extends State<UVCAuto> {
  // set monday true by default
  List<bool> days = [true, false, false, false, false, false, false];
  List<bool> daysStates = [false, false, false, false, false, false, false];

  List<int> hourList = [0, 0, 0, 0, 0, 0, 0];
  List<int> minutesList = [0, 0, 0, 0, 0, 0, 0];
  List<int> secondsList = [0, 0, 0, 0, 0, 0, 0];
  List<int> delayList = [0, 0, 0, 0, 0, 0, 0];
  List<int> durationList = [0, 0, 0, 0, 0, 0, 0];

  String daysInHex = '';
  String activationButtonText = deactivatedTextLanguageArray[languageArrayIdentifier];
  List<Color> activationButtonColor = [Colors.red, Colors.red, Colors.red, Colors.red, Colors.red, Colors.red, Colors.red];
  bool activationButtonState = false;
  Color saveButtonColor = Colors.blue;
  int day = 0;

  ToastyMessage myUvcToast = ToastyMessage();

  String myTimeHoursData = '00';
  String myTimeMinutesData = '00';
  String myTimeSecondsData = '00';
  String myExtinctionTimeMinuteData = ' 10 sec';
  String myActivationTimeMinuteData = ' 30 sec';

  int myTimeHoursPosition = 0;
  int myTimeMinutesPosition = 0;
  int myTimeSecondsPosition = 0;
  int myExtinctionTimeMinutePosition = 0;
  int myActivationTimeMinutePosition = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myUvcToast.setContext(context);
    readUVCAuto();
  }

  void readUVCAuto() {
    int j = 1;
    for (int i = 0; i < daysStates.length; i++) {
      daysStates[i] = myDevice.autoDaysState.elementAt(j);
      hourList[i] = myDevice.autoDaysTrigTime.elementAt(j) ~/ 3600;
      minutesList[i] = (myDevice.autoDaysTrigTime.elementAt(j) % 3600) ~/ 60;
      secondsList[i] = myDevice.autoDaysTrigTime.elementAt(j) % 60;
      delayList[i] = timeToDisinfectionArrayPosition(myDevice.autoDaysDisinfectionTime.elementAt(j));
      durationList[i] = timeToActivationArrayPosition(myDevice.autoDaysActivationTime.elementAt(j));
      if (j == daysStates.length - 1) {
        j = 0;
      } else {
        j++;
      }
    }
    // set monday by default
    setDaySettings(0);
  }

  void saveUVCAuto() {
    int j = 1;
    for (int i = 0; i < daysStates.length; i++) {
      myDevice.autoDaysState[j] = daysStates.elementAt(i);
      myDevice.autoDaysTrigTime[j] = hourList.elementAt(i) * 3600 + minutesList.elementAt(i) * 60 + secondsList.elementAt(i);
      myDevice.autoDaysDisinfectionTime[j] = disinfectionArrayPositionToTime(delayList.elementAt(i));
      myDevice.autoDaysActivationTime[j] = activationArrayPositionToTime(durationList.elementAt(i));
      if (j == daysStates.length - 1) {
        j = 0;
      } else {
        j++;
      }
    }
  }

  void setDaySettings(int selectedDay) {
    day = selectedDay;
    days[day] = !days[day];
    for (int buttonIndex = 0; buttonIndex < days.length; buttonIndex++) {
      if (buttonIndex == day) {
        days[buttonIndex] = true;
      } else {
        days[buttonIndex] = false;
      }
    }
    if (daysStates[day]) {
      activationButtonText = activatedTextLanguageArray[languageArrayIdentifier];
      activationButtonColor[day] = Colors.green;
    } else {
      activationButtonText = deactivatedTextLanguageArray[languageArrayIdentifier];
      activationButtonColor[day] = Colors.red;
    }

    myTimeHoursPosition = hourList[day];
    myTimeMinutesPosition = minutesList[day];
    myTimeSecondsPosition = secondsList[day];
    myExtinctionTimeMinutePosition = delayList[day];
    myActivationTimeMinutePosition = durationList[day];

    myTimeHoursData = myTimeHours.elementAt(myTimeHoursPosition);
    myTimeMinutesData = myTimeMinutes.elementAt(myTimeMinutesPosition);
    myTimeSecondsData = myTimeSeconds.elementAt(myTimeSecondsPosition);
    myExtinctionTimeMinuteData = myExtinctionTimeMinute.elementAt(myExtinctionTimeMinutePosition);
    myActivationTimeMinuteData = myActivationTimeMinute.elementAt(myActivationTimeMinutePosition);
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
                            setDaySettings(index);
                            setState(() {});
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
                        saveButtonColor = Colors.grey;
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
                            onChanged: (String? data) {
                              setState(() {
                                saveButtonColor = Colors.grey;
                                myTimeHoursData = data!;
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
                            onChanged: (String? data) {
                              setState(() {
                                saveButtonColor = Colors.grey;
                                myTimeMinutesData = data!;
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
                            onChanged: (String? data) {
                              setState(() {
                                saveButtonColor = Colors.grey;
                                myTimeSecondsData = data!;
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
                                value: myExtinctionTimeMinuteData,
                                icon: Icon(Icons.arrow_drop_down),
                                iconSize: 24,
                                elevation: 16,
                                style: TextStyle(color: Colors.grey[800], fontSize: widthScreen * 0.04),
                                onChanged: (String? data) {
                                  setState(() {
                                    saveButtonColor = Colors.grey;
                                    myExtinctionTimeMinuteData = data!;
                                    myExtinctionTimeMinutePosition = myExtinctionTimeMinute.indexOf(data);
                                    delayList[day] = myExtinctionTimeMinutePosition;
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
                                value: myActivationTimeMinuteData,
                                icon: Icon(Icons.arrow_drop_down),
                                iconSize: 24,
                                elevation: 16,
                                style: TextStyle(color: Colors.grey[800], fontSize: 18),
                                onChanged: (String? data) {
                                  setState(() {
                                    saveButtonColor = Colors.grey;
                                    myActivationTimeMinuteData = data!;
                                    myActivationTimeMinutePosition = myActivationTimeMinute.indexOf(data);
                                    durationList[day] = myActivationTimeMinutePosition;
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
                      saveUVCAuto();
                      setState(() {
                        saveButtonColor = Colors.blue;
                      });
                      final bool result = await myDevice.setAutoUvcData();
                      if (result) {
                        Navigator.pop(context);
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
}
