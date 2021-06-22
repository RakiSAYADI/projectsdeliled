import 'package:flutter_app_dmx_maestro/services/bleDeviceClass.dart';
import 'package:flutter_blue/flutter_blue.dart';

final String appName = 'MAESTRO DMX';

String dataRobotUVC;

Device myDevice;

List<BluetoothDevice> scanDevices = [];

bool startWithOutSettings;
