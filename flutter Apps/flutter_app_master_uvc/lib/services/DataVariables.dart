import 'package:flutter_app_master_uvc/services/bleDeviceClass.dart';
import 'package:flutter_app_master_uvc/services/uvcClass.dart';
import 'package:flutter_blue/flutter_blue.dart';

final String appName = 'MASTER UVC';

String dataRobotUVC;

Device myDevice;

UvcLight myUvcLight;

List<BluetoothDevice> scanDevices = [];
