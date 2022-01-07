import 'package:flutter/material.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/DataVariables.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/languageDataBase.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/zebraPrinterDeviceClass.dart';

class PrinterBleCard extends StatelessWidget {
  final ZebraBLEPrinter printer;
  final Function send;

  PrinterBleCard({this.printer, this.send});

  @override
  Widget build(BuildContext context) {
    String deviceName;
    if ((printer.zebraPrinter.name == null) || (printer.zebraPrinter.name.isEmpty)) {
      deviceName = noNameDeviceTextLanguageArray[languageArrayIdentifier];
    } else {
      deviceName = printer.zebraPrinter.name;
    }
    return Card(
      margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              deviceName,
              style: TextStyle(fontSize: 16.0, color: Colors.grey[800]),
            ),
            Text(
              printer.zebraPrinter.id.id,
              style: TextStyle(fontSize: 10.0, color: Colors.grey[600]),
            ),
            TextButton.icon(onPressed: send, icon: Icon(Icons.send), label: Text(selectTextLanguageArray[languageArrayIdentifier]))
          ],
        ),
      ),
    );
  }
}
