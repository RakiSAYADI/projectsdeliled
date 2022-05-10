class Device {
  String macDevice = '';
  String manufacture = '';
  String nameDevice = '';
  String serialNumberDevice = '';
  String deviceAddress = '192.168.2.1';

  Device(this.deviceAddress, {required this.macDevice, required this.manufacture, required this.nameDevice, required this.serialNumberDevice});
  
}
