import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterappdentaluvc/services/uvcClass.dart';

class DataCSVView extends StatefulWidget {
  @override
  _DataCSVViewState createState() => _DataCSVViewState();
}

class _DataCSVViewState extends State<DataCSVView> {
  Map endUVCClassData = {};
  List<List<String>> uvcData;

  bool isTreatmentCompleted;
  UvcLight myUvcLight;

  @override
  Widget build(BuildContext context) {
    endUVCClassData = endUVCClassData.isNotEmpty ? endUVCClassData : ModalRoute.of(context).settings.arguments;
    isTreatmentCompleted = endUVCClassData['isTreatmentCompleted'];
    myUvcLight = endUVCClassData['myUvcLight'];
    uvcData = endUVCClassData['uvcData'];

    return Scaffold(
      appBar: AppBar(
        title: Text('rapport CSV'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: SingleChildScrollView(
          child: Table(
            columnWidths: {
              0: FixedColumnWidth(100.0),
              1: FixedColumnWidth(200.0),
            },
            border: TableBorder.all(width: 2.0),
            children: uvcData.map((item) {
              return TableRow(
                  children: item.map((row) {
                return Container(
                  //color: row.toString().contains("réussi") ? Colors.green : Colors.red,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      row.toString(),
                      style: TextStyle(fontSize: 20.0),
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
