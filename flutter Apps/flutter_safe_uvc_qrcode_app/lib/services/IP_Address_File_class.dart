import 'dart:io';

import 'package:path_provider/path_provider.dart';

class IpAddressFile {
  final String _ipAddressFileName = 'Ip_Address.txt';

  Future<String> readUserIpAddressDATA() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_ipAddressFileName');
      String ipAddress = await file.readAsString();
      return ipAddress;
    } catch (e) {
      print("Couldn't read file");
      await saveStringIpAddressDATA('');
      return '';
    }
  }

  Future<void> saveStringIpAddressDATA(String ipAddress) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_ipAddressFileName');
    await file.writeAsString(ipAddress);
    print('saveStringIpAddressDATA : saved');
  }
}
