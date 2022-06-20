import 'package:get/get.dart';
import 'package:wifiglobalapp/services/data_variables.dart';

class AutoUVCService {
  bool _serviceState = false;

  void startUVCService() async {
    //initialize the service
    _serviceState = true;
    DateTime date = DateTime.now();
    do {
      if (_serviceState) {
        //service functionality
        date = DateTime.now();
        for (int day = 0; day < myDevice.autoDaysState.length; day++) {
          if ((day) == date.weekday && (myDevice.autoDaysState[day]) && (((date.hour * 3600) + (date.minute * 60) + date.second) == myDevice.autoDaysTrigTime[day])) {
            myDevice.activationTime = myDevice.autoDaysActivationTime[day];
            myDevice.disinfectionTime = myDevice.autoDaysDisinfectionTime[day];
            if (await myDevice.getDeviceData()) {
              Get.toNamed('/uvc');
            }
          }
        }
      } else {
        //breaking to stop service
        break;
      }
      await Future.delayed(const Duration(seconds: 1));
    } while (true);
  }

  void stopUVCAutoService() {
    _serviceState = false;
  }

  bool getServiceState() {
    return _serviceState;
  }
}
