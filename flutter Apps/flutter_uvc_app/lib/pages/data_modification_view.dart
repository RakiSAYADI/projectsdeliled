import 'package:flutter/material.dart';
import 'package:flutteruvcapp/services/CSVfileClass.dart';
import 'package:flutteruvcapp/services/DataVariables.dart';
import 'package:flutteruvcapp/services/languageDataBase.dart';
import 'package:flutteruvcapp/services/uvcToast.dart';

class DataViewModification extends StatefulWidget {
  @override
  _DataViewModificationState createState() => _DataViewModificationState();
}

class _DataViewModificationState extends State<DataViewModification> {
  Color _checkBoxEnabled = Colors.grey[200];
  Color _checkBoxDisabled = Colors.grey[800];

  String _myStartDataTimeDayData = '01';
  String _myStartDataTimeMonthData = '01';
  String _myStartDataTimeYearsData = '2020';

  String _myEndDataTimeDayData = '01';
  String _myEndDataTimeMonthData = '12';
  String _myEndDataTimeYearsData = '2020';

  int _myStartDataTimeDayPosition = 0;
  int _myStartDataTimeMonthPosition = 0;
  int _myStartDataTimeYearsPosition = 0;

  int _myEndDataTimeDayPosition = 0;
  int _myEndDataTimeMonthPosition = 0;
  int _myEndDataTimeYearsPosition = 0;

  bool _allData = true;
  bool _timedData = false;

  ToastyMessage _myUvcToast;

  Color enableDateDropDown(bool enable) => enable == true ? _checkBoxEnabled : _checkBoxDisabled;

  @override
  void initState() {
    // TODO: implement initState
    _myUvcToast = ToastyMessage(toastContext: context);
    super.initState();
  }

  void _onAllDataChanged(bool newValue) {
    setState(() {
      _allData = newValue;
      _timedData = !_allData;
    });
  }

  void _onTimedDataChanged(bool newValue) {
    setState(() {
      _timedData = newValue;
      _allData = !_timedData;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(settingsRapportUVCTitleTextLanguageArray[languageArrayIdentifier]),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    selectUVCDataTitleTextLanguageArray[languageArrayIdentifier],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: screenWidth * 0.03 + screenHeight * 0.03),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CheckboxListTile(
                    title: Text(
                      allReportTextLanguageArray[languageArrayIdentifier],
                      style: TextStyle(fontSize: screenWidth * 0.02 + screenHeight * 0.02),
                    ),
                    value: _allData,
                    onChanged: _onAllDataChanged,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CheckboxListTile(
                    title: Text(
                      determinedTimeTextLanguageArray[languageArrayIdentifier],
                      style: TextStyle(fontSize: screenWidth * 0.02 + screenHeight * 0.02),
                    ),
                    value: _timedData,
                    onChanged: _onTimedDataChanged,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
                Visibility(
                  visible: _timedData,
                  child: Card(
                    margin: EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(side: new BorderSide(color: Colors.black, width: 2.0), borderRadius: BorderRadius.circular(18.0)),
                    color: enableDateDropDown(_timedData),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 16.0, 0),
                              child: Text(
                                fromTextLanguageArray[languageArrayIdentifier],
                                style: TextStyle(fontSize: screenWidth * 0.02 + screenHeight * 0.02),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 8.0),
                                        child: Text(
                                          dayTextLanguageArray[languageArrayIdentifier],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: screenWidth * 0.015 + screenHeight * 0.015),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(2.0, 4.0, 2.0, 8.0),
                                        child: DropdownButton<String>(
                                          value: _myStartDataTimeDayData,
                                          icon: Icon(Icons.arrow_drop_down),
                                          iconSize: 24,
                                          elevation: 16,
                                          style: TextStyle(color: Colors.black, fontSize: 18),
                                          underline: Container(
                                            height: 2,
                                            color: Colors.blue[300],
                                          ),
                                          onChanged: (String data) {
                                            setState(() {
                                              _myStartDataTimeDayData = data;
                                              _myStartDataTimeDayPosition = myTimeDays.indexOf(data);
                                            });
                                          },
                                          items: myTimeDays.map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value, textAlign: TextAlign.center),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '\n/',
                                  style: TextStyle(fontSize: screenWidth * 0.02 + screenHeight * 0.02),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 8.0),
                                        child: Text(
                                          monthTextLanguageArray[languageArrayIdentifier],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: screenWidth * 0.015 + screenHeight * 0.015),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(2.0, 4.0, 2.0, 8.0),
                                        child: DropdownButton<String>(
                                          value: _myStartDataTimeMonthData,
                                          icon: Icon(Icons.arrow_drop_down),
                                          iconSize: 24,
                                          elevation: 16,
                                          style: TextStyle(color: Colors.black, fontSize: 18),
                                          underline: Container(
                                            height: 2,
                                            color: Colors.blue[300],
                                          ),
                                          onChanged: (String data) {
                                            setState(() {
                                              _myStartDataTimeMonthData = data;
                                              _myStartDataTimeMonthPosition = myTimeMonths.indexOf(data);
                                            });
                                          },
                                          items: myTimeMonths.map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value, textAlign: TextAlign.center),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '\n/',
                                  style: TextStyle(fontSize: screenWidth * 0.02 + screenHeight * 0.02),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 8.0),
                                        child: Text(
                                          yearTextLanguageArray[languageArrayIdentifier],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: screenWidth * 0.015 + screenHeight * 0.015),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(2.0, 4.0, 2.0, 8.0),
                                        child: DropdownButton<String>(
                                          value: _myStartDataTimeYearsData,
                                          icon: Icon(Icons.arrow_drop_down),
                                          iconSize: 24,
                                          elevation: 16,
                                          style: TextStyle(color: Colors.black, fontSize: 18),
                                          underline: Container(
                                            height: 2,
                                            color: Colors.blue[300],
                                          ),
                                          onChanged: (String data) {
                                            setState(() {
                                              _myStartDataTimeYearsData = data;
                                              _myStartDataTimeYearsPosition = myTimeYears.indexOf(data);
                                            });
                                          },
                                          items: myTimeYears.map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value, textAlign: TextAlign.center),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 16.0, 0),
                              child: Text(
                                toTextLanguageArray[languageArrayIdentifier],
                                style: TextStyle(fontSize: screenWidth * 0.02 + screenHeight * 0.02),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 8.0),
                                        child: Text(
                                          dayTextLanguageArray[languageArrayIdentifier],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: screenWidth * 0.015 + screenHeight * 0.015),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(2.0, 4.0, 2.0, 8.0),
                                        child: DropdownButton<String>(
                                          value: _myEndDataTimeDayData,
                                          icon: Icon(Icons.arrow_drop_down),
                                          iconSize: 24,
                                          elevation: 16,
                                          style: TextStyle(color: Colors.black, fontSize: 18),
                                          underline: Container(
                                            height: 2,
                                            color: Colors.blue[300],
                                          ),
                                          onChanged: (String data) {
                                            setState(() {
                                              _myEndDataTimeDayData = data;
                                              _myEndDataTimeDayPosition = myTimeDays.indexOf(data);
                                            });
                                          },
                                          items: myTimeDays.map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value, textAlign: TextAlign.center),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '\n/',
                                  style: TextStyle(fontSize: screenWidth * 0.02 + screenHeight * 0.02),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 8.0),
                                        child: Text(
                                          monthTextLanguageArray[languageArrayIdentifier],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: screenWidth * 0.015 + screenHeight * 0.015),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(2.0, 4.0, 2.0, 8.0),
                                        child: DropdownButton<String>(
                                          value: _myEndDataTimeMonthData,
                                          icon: Icon(Icons.arrow_drop_down),
                                          iconSize: 24,
                                          elevation: 16,
                                          style: TextStyle(color: Colors.black, fontSize: 18),
                                          underline: Container(
                                            height: 2,
                                            color: Colors.blue[300],
                                          ),
                                          onChanged: (String data) {
                                            setState(() {
                                              _myEndDataTimeMonthData = data;
                                              _myEndDataTimeMonthPosition = myTimeMonths.indexOf(data);
                                            });
                                          },
                                          items: myTimeMonths.map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value, textAlign: TextAlign.center),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '\n/',
                                  style: TextStyle(fontSize: screenWidth * 0.02 + screenHeight * 0.02),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 8.0),
                                        child: Text(
                                          yearTextLanguageArray[languageArrayIdentifier],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: screenWidth * 0.015 + screenHeight * 0.015),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(2.0, 4.0, 2.0, 8.0),
                                        child: DropdownButton<String>(
                                          value: _myEndDataTimeYearsData,
                                          icon: Icon(Icons.arrow_drop_down),
                                          iconSize: 24,
                                          elevation: 16,
                                          style: TextStyle(color: Colors.black, fontSize: 18),
                                          underline: Container(
                                            height: 2,
                                            color: Colors.blue[300],
                                          ),
                                          onChanged: (String data) {
                                            setState(() {
                                              _myEndDataTimeYearsData = data;
                                              _myEndDataTimeYearsPosition = myTimeYears.indexOf(data);
                                            });
                                          },
                                          items: myTimeYears.map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value, textAlign: TextAlign.center),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    child: Text(
                      confirmTextLanguageArray[languageArrayIdentifier],
                      style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.03 + screenHeight * 0.03),
                    ),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[400]),
                    ),
                    onPressed: () async {
                      UVCDataFile uvcDataFile = UVCDataFile();
                      uvcData = await uvcDataFile.readUVCDATA();
                      if (_allData) {
                        if (openWithQrCode) {
                          Navigator.pushNamed(context, '/DataCSVViewQrCode');
                        } else {
                          Navigator.pushNamed(context, '/DataCSVView');
                        }
                      } else if (_timedData) {
                        DateTime d1 = DateTime.utc(int.parse(_myStartDataTimeYearsData), int.parse(_myStartDataTimeMonthData), int.parse(_myStartDataTimeDayData));
                        DateTime d2 = DateTime.utc(int.parse(_myEndDataTimeYearsData), int.parse(_myEndDataTimeMonthData), int.parse(_myEndDataTimeDayData));
                        print(d1.toString());
                        print(d2.toString());
                        DateTime d3;
                        for (int i = 1; i < uvcData.length; i++) {
                          d3 = DateTime.parse(
                              '${uvcData[i][5].split('/')[2].replaceAll(' ', '')}-${uvcData[i][5].split('/')[1].replaceAll(' ', '')}-${uvcData[i][5].split('/')[0].replaceAll(' ', '')}');
                          print(d3.toString());
                          if (d3.isAfter(d1) && d3.isBefore(d2)) {
                            print("good date $d3");
                          } else {
                            print("bad date $d3");
                          }
                        }
                      } else {
                        _myUvcToast.setToastDuration(3);
                        _myUvcToast.setToastMessage(noDataSelectionToastLanguageArray[languageArrayIdentifier]);
                        _myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}