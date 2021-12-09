import 'package:flutter_app_master_uvc/services/bleDeviceClass.dart';
import 'package:flutter_app_master_uvc/services/uvcClass.dart';
import 'package:flutter_blue/flutter_blue.dart';

final String appName = 'MASTER UVC';

String dataRobotUVC;

Device myDevice;

UvcLight myUvcLight;

final String dataRobotUVCDefault = '{\"Company\":\"Votre entreprise\",\"UserName\":\"Utilisateur\",\"Detection\":0,\"RoomName\":\"Chambre 1\",\"TimeData\":[0,0]}';

String languageCode = 'fr';
int languageArrayIdentifier = 0;

List<BluetoothDevice> scanDevices = [];
