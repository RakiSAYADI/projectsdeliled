import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutterappdentaluvc/services/CSVfileClass.dart';
import 'package:flutterappdentaluvc/services/bleDeviceClass.dart';
import 'package:flutterappdentaluvc/services/uvcClass.dart';
import 'package:flutterappdentaluvc/services/DataVariables.dart';
import 'package:flutterappdentaluvc/services/uvcToast.dart';

class AutoUVCService {
  Device _myDevice;
  BuildContext _buildContext;
  UvcLight _myUVCLight;
  ToastyMessage _myUvcToast;
  bool _serviceState = false;
  UVCDataFile _uvcDataFile = UVCDataFile();
  Map<String, dynamic> _uvcAutoDataJson;
  List<int> _daysStates = [0, 0, 0, 0, 0, 0, 0];
  List<int> _hourList = [0, 0, 0, 0, 0, 0, 0];
  List<int> _minutesList = [0, 0, 0, 0, 0, 0, 0];
  List<int> _secondsList = [0, 0, 0, 0, 0, 0, 0];
  List<int> _delayList = [0, 0, 0, 0, 0, 0, 0];
  List<int> _durationList = [0, 0, 0, 0, 0, 0, 0];

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

  void startUVCService() async {
    //initialize the service
    _serviceState = true;
    await _readUVCAuto();
    DateTime date = DateTime.now();
    _myUvcToast = ToastyMessage(toastContext: _buildContext);
    do {
      if (_serviceState) {
        //service functionality
        date = DateTime.now();
        for (int i = 0; i < _daysStates.length; i++) {
          if ((i + 1) == date.weekday &&
              ((_daysStates[i]) == 1) &&
              (date.hour == _hourList[i]) &&
              (date.minute == _minutesList[i]) &&
              (date.second == _secondsList[i])) {
            if (_myDevice != null && _myDevice.getConnectionState()) {
              print('detection of activation today');
              Map<String, dynamic> user = jsonDecode(_myDevice.getReadCharMessage());
              _myUVCLight = UvcLight(
                  machineName: _myDevice.device.name,
                  machineMac: _myDevice.device.id.toString(),
                  company: user['Company'],
                  operatorName: user['UserName'],
                  roomName: user['RoomName']);
              _myUVCLight.setInfectionTime(myExtinctionTimeMinute[_delayList[i]]);
              _myUVCLight.setActivationTime(myActivationTimeMinute[_durationList[i]]);
              await _myDevice.writeCharacteristic(2, 0,
                  '{\"data\":[\"${_myUVCLight.getCompanyName()}\",\"${_myUVCLight.getOperatorName()}\",\"${_myUVCLight.getRoomName()}\",${_delayList[i]},${_durationList[i]}]}');
              await Future.delayed(const Duration(milliseconds: 200));
              String message = 'UVCTreatement : ON';
              await _myDevice.writeCharacteristic(2, 0, message);
              try {
                myDevice = _myDevice;
                myUvcLight = _myUVCLight;
                Navigator.pushNamed(_buildContext, '/uvc');
              } catch (e) {
                _myUvcToast.setToastDuration(5);
                _myUvcToast.setToastMessage('Execution d\'une desinfection automatique !');
                _myUvcToast.showToast(Colors.green, Icons.thumb_up, Colors.white);
              }
            } else {
              _myUvcToast.setToastDuration(3);
              _myUvcToast.setToastMessage('La désinfection est ignorée car le dispositif UV-C n\'est pas connecté !');
              _myUvcToast.showToast(Colors.red, Icons.warning, Colors.white);
            }
          }
        }
      } else {
        //breaking to stop service
        break;
      }
      await Future.delayed(const Duration(milliseconds: 800));
    } while (true);
  }

  void stopUVCAutoService() {
    _serviceState = false;
  }

  void setUVCDevice(Device device) {
    _myDevice = device;
  }

  void setContext(BuildContext context) {
    _buildContext = context;
  }

  bool getUVCAutoServiceState() {
    return _serviceState;
  }

  Future<void> _readUVCAuto() async {
    String uvcAutoData = await _uvcDataFile.readUVCAutoData();
    _uvcAutoDataJson = jsonDecode(uvcAutoData);

    _readDayData('Monday', 0);
    _readDayData('Tuesday', 1);
    _readDayData('Wednesday', 2);
    _readDayData('Thursday', 3);
    _readDayData('Friday', 4);
    _readDayData('Saturday', 5);
    _readDayData('Sunday', 6);
  }

  void _readDayData(String day, int position) {
    String timeDataList = _uvcAutoDataJson[day].toString();
    List<int> timeDataIntList = _stringListAsciiToListInt(timeDataList.codeUnits);
    _daysStates[position] = timeDataIntList[0];
    _hourList[position] = timeDataIntList[1];
    _minutesList[position] = timeDataIntList[2];
    _secondsList[position] = timeDataIntList[3];
    _delayList[position] = timeDataIntList[4];
    _durationList[position] = timeDataIntList[5];
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
