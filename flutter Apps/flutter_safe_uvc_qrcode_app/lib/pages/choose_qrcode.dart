import 'package:flutter/material.dart';

class ChooseQrCode extends StatefulWidget {
  @override
  _ChooseQrCodeState createState() => _ChooseQrCodeState();
}

class _ChooseQrCodeState extends State<ChooseQrCode> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
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
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, "/Qr_code_Generate");
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                            shape: RoundedRectangleBorder(
                                side: new BorderSide(color: Colors.blue[400], width: 2.0), borderRadius: BorderRadius.circular(4.0)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                                  child: FlatButton(
                                    onPressed: () =>  Navigator.pushReplacementNamed(context, "/Qr_code_Generate"),
                                    child: Text(
                                      'QR code Data',
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
                                    'Créer un QR code contenant :',
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
                                    '- l\'établissement\n'
                                    '- l\'opérateur\n'
                                    '- la pièce\n'
                                    '- le préavis d\'allumage\n'
                                    '- la durée de désinfection \n',
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
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, "/qr_code_scan");
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                            shape: RoundedRectangleBorder(
                                side: new BorderSide(color: Colors.blue[400], width: 2.0), borderRadius: BorderRadius.circular(4.0)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                                  child: FlatButton(
                                    onPressed: () => Navigator.pushReplacementNamed(context, "/qr_code_scan"),
                                    child: Text(
                                      'QR code OneClick',
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
                                    'Ce QR code permet de lancer la désinfection plus rapidement dans SAFE UVC (moins d\'étapes).',
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
                                    'Créer un QR code contenant :',
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
                                    '- les informations du QR code Data\n'
                                    '+\n'
                                    '- Un code PIN (optionnel)\n',
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
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, "/Qr_code_Generate_Data");
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                            shape: RoundedRectangleBorder(
                                side: new BorderSide(color: Colors.blue[400], width: 2.0), borderRadius: BorderRadius.circular(4.0)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                                  child: FlatButton(
                                    onPressed: () => Navigator.pushReplacementNamed(context, "/Qr_code_Generate_Data"),
                                    child: Text(
                                      'QR code Rapport',
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
                                    'Ce QR code permet de accéder et envoyer le rapport de toutes les traitement UVC sur votre téléphone',
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
                                    'Créer un QR code contenant :',
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
                                    '- une adresse Email',
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
                      ),
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
