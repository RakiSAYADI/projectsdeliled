import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_safe_uvc_qrcode_app/services/DataVariables.dart';

class ChooseQrCode extends StatefulWidget {
  @override
  _ChooseQrCodeState createState() => _ChooseQrCodeState();
}

class _ChooseQrCodeState extends State<ChooseQrCode> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.blue[400],
      appBar: AppBar(
        title: const Text('Choix des QRcodes'),
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: () async {
                await displayQrCodeDATA(context);
              },
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  Container(
                    width: screenWidth * 0.13,
                    height: screenHeight * 0.07,
                    decoration: new BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Icon(Icons.article, color: Colors.blue[400]),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Builder(
          builder: (context) {
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    qrCodeGenerator(
                        context: context,
                        destination: "/Qr_code_Generate",
                        buttonTitle: 'QR code Data',
                        buttonText: 'Ce QR code permet de préenregistrer les informations de désinfection.',
                        buttonDescription1: 'Créer un QR code contenant :',
                        buttonDescription2: '- l\'établissement\n'
                            '- l\'opérateur\n'
                            '- la pièce\n'
                            '- le préavis d\'allumage\n'
                            '- la durée de désinfection \n'),
                    qrCodeGenerator(
                        context: context,
                        destination: "/qr_code_scan",
                        buttonTitle: 'QR code OneClick',
                        buttonText: 'Ce QR code permet de lancer la désinfection plus rapidement dans SAFE UVC (moins d\'étapes).',
                        buttonDescription1: 'Créer un QR code contenant :',
                        buttonDescription2: '- les informations du QR code Data\n'
                            '- Un code PIN (optionnel)\n'),
                    qrCodeGeneratorSecond(
                        context: context,
                        destination: "/Qr_code_Generate_Data",
                        buttonTitle: 'QR code Rapport',
                        buttonText: 'Ce QR code permet d\'afficher et d\'envoyer le rapport des désinfections par mail à un adresse préenregistrée.'),
                    qrCodeGeneratorSecond(
                        context: context, destination: "/Qr_code_Display_Security", buttonTitle: 'QR code Sécurité', buttonText: 'Ce QR code permet de créer un QR code de sécurité.'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> displayQrCodeDATA(BuildContext context) async {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    myQrCodes.length = 0;
    listQrCodes.length = 0;
    for (int i = 0; i < qrCodeImageList.length; i++) {
      listQrCodes.add(TableRow(children: [
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.file(qrCodeImageList[i], width: screenWidth * 0.27, height: screenHeight * 0.14),
          Text(qrCodeList[i].fileName),
        ])
      ]));
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Vos QRcodes'),
          content: SingleChildScrollView(
            child: Table(border: TableBorder.all(color: Colors.black), defaultVerticalAlignment: TableCellVerticalAlignment.middle, children: listQrCodes),
          ),
          actions: [
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  GestureDetector qrCodeGenerator({BuildContext context, String destination, String buttonTitle, String buttonText, String buttonDescription1, String buttonDescription2}) {
    double screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, destination);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
          shape: RoundedRectangleBorder(side: new BorderSide(color: Colors.blue[400], width: 2.0), borderRadius: BorderRadius.circular(4.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, destination),
                  child: Text(
                    buttonTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.05,
                    ),
                  ),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[400]),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  buttonText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.05,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Divider(
                  thickness: 2.0,
                  color: Colors.grey,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  buttonDescription1,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.black,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.05,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  buttonDescription2,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.05,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector qrCodeGeneratorSecond({BuildContext context, String destination, String buttonTitle, String buttonText}) {
    double screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, destination);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
          shape: RoundedRectangleBorder(side: new BorderSide(color: Colors.blue[400], width: 2.0), borderRadius: BorderRadius.circular(4.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, destination),
                  child: Text(
                    buttonTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.05,
                    ),
                  ),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[400]),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  buttonText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.05,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
