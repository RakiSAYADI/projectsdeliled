import 'package:flutter/material.dart';
import 'package:flutteruvcapp/services/DataVariables.dart';
import 'package:flutteruvcapp/services/languageDataBase.dart';
import 'package:flutteruvcapp/services/uvcToast.dart';

class DataViewModification extends StatefulWidget {
  @override
  _DataViewModificationState createState() => _DataViewModificationState();
}

class _DataViewModificationState extends State<DataViewModification> {
  Color _checkBoxEnabled = Colors.black;
  Color _checkBoxDisabled = Colors.red;

  String _myStartDataTimeDayData = '01';
  String _myStartDataTimeMonthData = '01';
  String _myStartDataTimeYearsData = '2020';

  String _myEndDataTimeDayData = '01';
  String _myEndDataTimeMonthData = '01';
  String _myEndDataTimeYearsData = '2020';

  int _myStartDataTimeDayPosition = 0;
  int _myStartDataTimeMonthPosition = 0;
  int _myStartDataTimeYearsPosition = 0;

  int _myEndDataTimeDayPosition = 0;
  int _myEndDataTimeMonthPosition = 0;
  int _myEndDataTimeYearsPosition = 0;

  bool _allData = false;
  bool _timedData = false;

  ToastyMessage _myUvcToast;

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
                    selectedTileColor: _checkBoxEnabled,
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
                    selectedTileColor: _checkBoxDisabled,
                    value: _timedData,
                    onChanged: _onTimedDataChanged,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
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
                        eachTimeZoneConfig(context, dayTextLanguageArray[languageArrayIdentifier], _myStartDataTimeDayData, myTimeDays, _myStartDataTimeDayPosition),
                        Text(
                          '/',
                          style: TextStyle(fontSize: screenWidth * 0.02 + screenHeight * 0.02),
                        ),
                        eachTimeZoneConfig(context, monthTextLanguageArray[languageArrayIdentifier], _myStartDataTimeMonthData, myTimeMonths, _myStartDataTimeMonthPosition),
                        Text(
                          '/',
                          style: TextStyle(fontSize: screenWidth * 0.02 + screenHeight * 0.02),
                        ),
                        eachTimeZoneConfig(context, yearTextLanguageArray[languageArrayIdentifier], _myStartDataTimeYearsData, myTimeYears, _myStartDataTimeYearsPosition),
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
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        eachTimeZoneConfig(context, dayTextLanguageArray[languageArrayIdentifier], _myEndDataTimeDayData, myTimeDays, _myEndDataTimeDayPosition),
                        Text(
                          '/',
                          style: TextStyle(fontSize: screenWidth * 0.02 + screenHeight * 0.02),
                        ),
                        eachTimeZoneConfig(context, monthTextLanguageArray[languageArrayIdentifier], _myEndDataTimeMonthData, myTimeMonths, _myEndDataTimeMonthPosition),
                        Text(
                          '/',
                          style: TextStyle(fontSize: screenWidth * 0.02 + screenHeight * 0.02),
                        ),
                        eachTimeZoneConfig(context, yearTextLanguageArray[languageArrayIdentifier], _myEndDataTimeYearsData, myTimeYears, _myEndDataTimeYearsPosition),
                      ],
                    ),
                  ],
                ),
                TextButton(
                  child: Text(
                    confirmTextLanguageArray[languageArrayIdentifier],
                    style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.03 + screenHeight * 0.03),
                  ),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[400]),
                  ),
                  onPressed: () {
                    if (_allData) {
                      Navigator.pushNamed(context, '/DataCSVView');
                    } else if (_timedData) {
                    } else {
                      _myUvcToast.setToastDuration(3);
                      _myUvcToast.setToastMessage(noDataSelectionToastLanguageArray[languageArrayIdentifier]);
                      _myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget eachTimeZoneConfig(BuildContext buildContext, String timeSetting, String timeSettingListData, List<String> timeSettingList, int timeSettingListPosition) {
    double screenWidth = MediaQuery.of(buildContext).size.width;
    double screenHeight = MediaQuery.of(buildContext).size.height;
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 8.0),
            child: Text(
              timeSetting,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: screenWidth * 0.015 + screenHeight * 0.015),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(2.0, 4.0, 2.0, 8.0),
            child: DropdownButton<String>(
              value: timeSettingListData,
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
                  timeSettingListData = data;
                  print(timeSettingListData);
                  timeSettingListPosition = timeSettingList.indexOf(data);
                });
              },
              items: timeSettingList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
