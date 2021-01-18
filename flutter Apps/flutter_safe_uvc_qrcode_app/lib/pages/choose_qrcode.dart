import 'package:flutter/material.dart';

class ChooseQrCode extends StatefulWidget {
  @override
  _ChooseQrCodeState createState() => _ChooseQrCodeState();
}

class _ChooseQrCodeState extends State<ChooseQrCode> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.blue[400],
        appBar: AppBar(
          title: const Text('Choisir votre Type de QR code'),
          centerTitle: true,
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
                          buttonText: 'Ce QR code de sécurité pour les robots UV-C',
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
                              '+\n'
                              '- Un code PIN (optionnel)\n'),
                      qrCodeGenerator(
                          context: context,
                          destination: "/Qr_code_Generate_Data",
                          buttonTitle: 'QR code Rapport',
                          buttonText: 'Ce QR code permet de accéder et envoyer le rapport de toutes les traitement UVC sur votre téléphone',
                          buttonDescription1: 'Créer un QR code contenant :',
                          buttonDescription2: '- une adresse Email'),
                      qrCodeGenerator(
                          context: context,
                          destination: "/Qr_code_Display_Security",
                          buttonTitle: 'QR code Sécurité',
                          buttonText: 'Ce QR code de sécurité pour les robots UV-C',
                          buttonDescription1: 'Créer un QR code contenant :',
                          buttonDescription2: '- un lien de securité sur le site de deeplight.com'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      onWillPop: () => stopActivity(context),
    );
  }

  GestureDetector qrCodeGenerator(
      {BuildContext context, String destination, String buttonTitle, String buttonText, String buttonDescription1, String buttonDescription2}) {
    double screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, destination);
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
                child: FlatButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, destination),
                  child: Text(
                    buttonTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.05,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  color: Colors.blue[400],
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

  Future<void> stopActivity(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Attention'),
        content: Text('Voulez-vous vraiment quitter l\'application ?'),
        actions: [
          FlatButton(
            child: Text('Oui'),
            onPressed: () {
              Navigator.pop(c, true);
            },
          ),
          FlatButton(
            child: Text('Non'),
            onPressed: () => Navigator.pop(c, false),
          ),
        ],
      ),
    );
  }
}
