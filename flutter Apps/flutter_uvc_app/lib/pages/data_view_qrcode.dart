import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutteruvcapp/services/DataVariables.dart';
import 'package:flutteruvcapp/services/languageDataBase.dart';

class DataCSVViewQrCode extends StatefulWidget {
  @override
  _DataCSVViewQrCodeState createState() => _DataCSVViewQrCodeState();
}

class _DataCSVViewQrCodeState extends State<DataCSVViewQrCode> {

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
    return WillPopScope(
      child: Scaffold(
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
          onPressed: () =>     Navigator.pushNamed(context, "/send_email_qr_code"),
          label: Text(rapportUVCButtonTextLanguageArray[languageArrayIdentifier]),
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
    return true;
  }
}
