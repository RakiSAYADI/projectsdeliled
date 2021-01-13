import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DataCSVViewQrCode extends StatefulWidget {
  @override
  _DataCSVViewQrCodeState createState() => _DataCSVViewQrCodeState();
}

class _DataCSVViewQrCodeState extends State<DataCSVViewQrCode> {
  Map dataCSVQRCodeClassData = {};
  List<List<String>> uvcData;
  String userEmail;

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
    dataCSVQRCodeClassData = dataCSVQRCodeClassData.isNotEmpty ? dataCSVQRCodeClassData : ModalRoute.of(context).settings.arguments;
    uvcData = dataCSVQRCodeClassData['uvcData'];
    userEmail = dataCSVQRCodeClassData['userEmail'];

    double screenWidth = MediaQuery.of(context).size.width;

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
          onPressed: () =>     Navigator.pushNamed(context, "/send_email_qr_code", arguments: {
            'userEmail': userEmail,
            'uvcData': uvcData,
          }),
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
    Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
    return true;
  }
}
