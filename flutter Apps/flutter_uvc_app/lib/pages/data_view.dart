import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutteruvcapp/services/DataVariables.dart';
import 'package:flutteruvcapp/services/languageDataBase.dart';

class DataCSVView extends StatefulWidget {
  @override
  _DataCSVViewState createState() => _DataCSVViewState();
}

class _DataCSVViewState extends State<DataCSVView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(rapportUVCTitleTextLanguageArray[languageArrayIdentifier]),
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
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        row.toString(),
                        style: TextStyle(
                          fontSize: screenWidth * 0.017,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList());
            }).toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, "/send_email"),
        label: Text(rapportUVCButtonTextLanguageArray[languageArrayIdentifier]),
        icon: Icon(
          Icons.send,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue[400],
      ),
    );
  }
}
