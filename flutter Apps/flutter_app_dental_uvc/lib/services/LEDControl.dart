import 'dart:convert';
import 'dart:io';

class LedControl {
  final String _processName = 'su';
  final String _commandOperation = 'echo w';
  final String _packageName = '> ./sys/devices/platform/led_con_h/zigbee_reset';
  final String _exitCommand = 'exit';

  Future<bool> setLedColor(String ledColor) async {
    String colorHex;
    switch (ledColor) {
      case 'OFF':
        colorHex = '0x02';
        break;
      case 'ON':
        colorHex = '0x03';
        break;
      case 'RED':
        colorHex = '0x04';
        break;
      case 'GREEN':
        colorHex = '0x05';
        break;
      case 'BLUE':
        colorHex = '0x06';
        break;
      case 'WHITE':
        colorHex = '0x07';
        break;
      case 'ORANGE':
        colorHex = '0x08';
        break;
      case 'CYAN':
        colorHex = '0x09';
        break;
      case 'PURPLE':
        colorHex = '0x0a';
        break;
      default:
        return false;
        break;
    }
    try {
      await Process.start(_processName, []).then((Process process) {
        process.stdout.transform(utf8.decoder).listen((data) {
          print(data);
        });
        process.stdin.writeln('$_commandOperation $colorHex $_packageName');
        process.stdin.writeln(_exitCommand);
      });
      await Future.delayed(const Duration(milliseconds: 50));
      return true;
    } catch (e) {
      return false;
    }
  }
}
