import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterappdentaluvc/services/DataVariables.dart';
import 'package:flutterappdentaluvc/services/uvcToast.dart';

class DataCSVSettingsView extends StatefulWidget {
  @override
  _DataCSVSettingsViewState createState() => _DataCSVSettingsViewState();
}

class _DataCSVSettingsViewState extends State<DataCSVSettingsView> {
  ToastyMessage myUvcToast;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myUvcToast = ToastyMessage(toastContext: context);
  }

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('rapport CSV'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: SingleChildScrollView(
          child: Table(
            border: TableBorder.all(width: 2.0),
            children: uvcData.map((item) {
              return TableRow(
                  children: item.map((row) {
                return Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      row.toString(),
                      style: TextStyle(
                        fontSize: widthScreen * 0.015,
                      ),
                    ),
                  ),
                );
              }).toList());
            }).toList(),
          ),
        ),
      ),
    );
  }
}
