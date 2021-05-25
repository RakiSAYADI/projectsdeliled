import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutteruvcapp/services/bleDeviceClass.dart';
import 'package:flutteruvcapp/services/uvcClass.dart';

Device myDevice;

UvcLight myUvcLight;

int myExtinctionTimeMinutePosition;
int myActivationTimeMinutePosition;
int activationTime;

List<BluetoothDevice> scanDevices;
List<List<String>> uvcData;

String pinCodeAccess;
String userEmail;

bool isTreatmentCompleted;
bool qrCodeConnectionOrSecurity;
bool startWithOutSettings;
