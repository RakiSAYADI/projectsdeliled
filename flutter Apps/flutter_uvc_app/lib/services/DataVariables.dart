import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutteruvcapp/services/bleDeviceClass.dart';
import 'package:flutteruvcapp/services/uvcClass.dart';

final String appName = 'SAFE UVC';

Device myDevice;

UvcLight myUvcLight;

int languageArrayIdentifier = 0;

int myExtinctionTimeMinutePosition;
int myActivationTimeMinutePosition;
int activationTime;

List<BluetoothDevice> scanDevices;
List<List<String>> uvcData;

String pinCodeAccess;
String userEmail;
String languageCode = 'fr';

bool isTreatmentCompleted;
bool qrCodeConnectionOrSecurity;
bool startWithOutSettings;
