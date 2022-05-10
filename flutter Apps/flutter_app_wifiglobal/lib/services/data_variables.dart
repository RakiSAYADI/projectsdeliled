import 'package:wifiglobalapp/services/aes_cbc_crypt.dart';
import 'package:wifiglobalapp/services/uvc_device.dart';

const String appName = 'Global WIFI';
const int port = 3333;
AESCbcCrypt aesCbcCrypt = AESCbcCrypt('AA:BB:CC:DD:EE:FF', textString: 'test');
List<Device> listOfDevices = [];
String languageCode = 'en';
int languageArrayIdentifier = 0;
final int timeSleep = 60000;
String pinCodeAccess = '1234';
bool sleepIsInactivePinAccess = false;
