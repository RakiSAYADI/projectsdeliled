import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutteruvcapp/services/bleDeviceClass.dart';
import 'package:flutteruvcapp/services/uvcClass.dart';

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
    endUVCClassData = endUVCClassData.isNotEmpty ? endUVCClassData : ModalRoute.of(context).settings.arguments;
    isTreatmentCompleted = endUVCClassData['isTreatmentCompleted'];
    myUvcLight = endUVCClassData['myUvcLight'];
    uvcData = endUVCClassData['uvcData'];

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text('Rapports de désinfection'),
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
                    //color: row.toString().contains("réussi") ? Colors.green : Colors.red,
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
          onPressed: () =>     Navigator.pushNamed(context, "/send_email"),
          label: Text('Envoi'),
          icon: Icon(
            Icons.send,
            color: Colors.white,
          ),
          backgroundColor: Colors.blue[400],
        ),
      ),
      onWillPop: () => exitApp(context),
    );
  }

  Future<bool> exitApp(BuildContext context) async {
    Navigator.pushNamedAndRemoveUntil(context, "/end_uvc", (r) => false, arguments: {
      'treatmentIsSuccessful': isTreatmentCompleted,
      'myUvcLight': myUvcLight,
    });
    return true;
  }
}
