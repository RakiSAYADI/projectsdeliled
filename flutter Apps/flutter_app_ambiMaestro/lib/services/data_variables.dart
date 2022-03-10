import 'package:flutter/material.dart';
import 'package:flutter_app_ambimaestro/services/ble_device_class.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

const String appName = 'ambioMaestro';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

int stateOfSleepAndReadingProcess = 0;
Widget? mainWidgetScreen;
const int timeSleep = 60000;

bool homePageState = false;

String languageCode = 'fr';
int languageArrayIdentifier = 0;

Device? myDevice;
BluetoothCharacteristic? characteristicSensors;
BluetoothCharacteristic? characteristicData;

String dataCharAndroid1 = '';
String dataCharAndroid2 = '';

String dataCharIOS1p1 = '';
String dataCharIOS1p2 = '';
String dataCharIOS1p3 = '';
String dataCharIOS1p4 = '';

String dataCharIOS2p1 = '';
String dataCharIOS2p2 = '';
String dataCharIOS2p3 = '';
String dataCharIOS2p4 = '';

int deviceTimeValue = 1000000;
int detectionTimeValue = 0;
int temperatureValue = 28;
int humidityValue = 50;
int lightValue = 20;
int co2Value = 500;
int tvocValue = 750;
int co2sensorStateValue = 0;
bool deviceWifiState = false;

String appTime = '00:00';
int temperatureMeteoValue = 28;
String weatherState = '01d';

int myExtinctionTimeMinutePosition = 0;
int myActivationTimeMinutePosition = 0;
int activationTime = 0;

String pinCodeAccess = '';

int boolToInt(bool a) => a == true ? 1 : 0;

bool intToBool(int a) => a == 1 ? true : false;

List<List<String>>? uvcData;

List<int> stringListAsciiToListInt(List<int> listInt) {
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

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

Future<String> charDividedIOSRead(BluetoothCharacteristic characteristicIOS) async {
  String data = '';
  data = String.fromCharCodes(await characteristicIOS.read());
  await Future.delayed(const Duration(milliseconds: 300));
  return data;
}

Future<void> waitingConnectionWidget(BuildContext buildContext, String title) async {
  //double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(buildContext).size.height;
  return showDialog<void>(
      context: buildContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SpinKitCircle(
                color: Colors.blue[600],
                size: screenHeight * 0.1,
              ),
            ],
          ),
        );
      });
}

Future<void> savingDataWidget(BuildContext buildContext) async {
  //double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(buildContext).size.height;
  return showDialog<void>(
      context: buildContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Veuillez patienter'),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SpinKitCircle(
                color: Colors.blue[600],
                size: screenHeight * 0.1,
              ),
            ],
          ),
        );
      });
}

List<String> myTimeHours = ['00', '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23'];

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