import 'package:wifiglobalapp/services/uvc_device.dart';

const String appName = 'Global WIFI';
const int port = 3333;
const String ipAddressDevice ='192.168.2.1';
String embeddedTimeZone = 'FR';
Device myDevice = Device(ipAddressDevice, macDevice: '', manufacture: '', nameDevice: '', serialNumberDevice: '');
String languageCode = 'en';
int languageArrayIdentifier = 0;
final int timeSleep = 60000;
String pinCodeAccess = '1234';
bool sleepIsInactivePinAccess = false;
