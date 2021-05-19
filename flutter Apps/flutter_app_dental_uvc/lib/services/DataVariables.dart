import 'package:flutterappdentaluvc/services/bleDeviceClass.dart';
import 'package:flutterappdentaluvc/services/uvcClass.dart';

Device myDevice;

UvcLight myUvcLight;

int myExtinctionTimeMinutePosition = 0;
int myActivationTimeMinutePosition = 0;
int activationTime;

String pinCodeAccess;

List<List<String>> uvcData;

bool isTreatmentCompleted;