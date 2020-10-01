import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DataCSVView extends StatefulWidget {
  @override
  _DataCSVViewState createState() => _DataCSVViewState();
}

class _DataCSVViewState extends State<DataCSVView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Table(
          columnWidths: {
            0: FixedColumnWidth(100.0),
            1: FixedColumnWidth(200.0),
          },
          border: TableBorder.all(width: 1.0),
          children: data.map((item) {
            return TableRow(
                children: item.map((row) {
              return Container(
                color: row.toString().contains("NA") ? Colors.red : Colors.green,
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
    );
  }
}
