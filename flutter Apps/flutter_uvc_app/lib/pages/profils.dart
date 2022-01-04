import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutteruvcapp/services/DataVariables.dart';
import 'package:flutteruvcapp/services/languageDataBase.dart';
import 'package:flutteruvcapp/services/uvcClass.dart';
import 'package:flutteruvcapp/services/uvcToast.dart';

class Profiles extends StatefulWidget {
  @override
  _ProfilesState createState() => _ProfilesState();
}

class _ProfilesState extends State<Profiles> {
  ToastyMessage myUvcToast;

  final myCompany = TextEditingController();
  final myName = TextEditingController();
  final myRoomName = TextEditingController();

  String dataRobotUVC = '';

  bool firstDisplayMainWidget = true;

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
    myCompany.dispose();
    myName.dispose();
    myRoomName.dispose();
    super.dispose();
  }

  List<int> _stringListAsciiToListInt(List<int> listInt) {
    List<int> ourListInt = [0];
    int listIntLength = listInt.length;
    int intNumber = (listIntLength / 4).round();
    ourListInt.length = intNumber;
    int listCounter;
    int listIntCounter = 0;
    String numberString = '';
    if (listInt.first == 91 && listInt.last == 93) {
      for (listCounter = 0; listCounter < listIntLength - 1; listCounter++) {
        if (!((listInt[listCounter] == 91) || (listInt[listCounter] == 93) || (listInt[listCounter] == 32) || (listInt[listCounter] == 44))) {
          numberString = '';
          do {
            numberString += String.fromCharCode(listInt[listCounter]);
            listCounter++;
          } while (!((listInt[listCounter] == 44) || (listInt[listCounter] == 93)));
          ourListInt[listIntCounter] = int.parse(numberString);
          listIntCounter++;
        }
      }
      return ourListInt;
    } else {
      return [0];
    }
  }

  @override
  Widget build(BuildContext context) {
    dataRobotUVC = myDevice.getReadCharMessage();
    if (dataRobotUVC == null) {
      dataRobotUVC = '{\"Company\":\"Votre entreprise\",\"UserName\":\"Utilisateur\",\"Detection\":0,\"RoomName\":\"Chambre 1\",\"TimeData\":[0,0]}';
    }

    if (dataRobotUVC.isNotEmpty && firstDisplayMainWidget) {
      Map<String, dynamic> user = jsonDecode(dataRobotUVC);

      String timeDataList = user['TimeData'].toString();

      firstDisplayMainWidget = false;
      myCompany.text = user['Company'];
      myName.text = user['UserName'];
      myRoomName.text = user['RoomName'];

      myExtinctionTimeMinutePosition = _stringListAsciiToListInt(timeDataList.codeUnits)[0];
      myActivationTimeMinutePosition = _stringListAsciiToListInt(timeDataList.codeUnits)[1];
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(profilePageTitleTextLanguageArray[languageArrayIdentifier]),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(color: Colors.grey[200]),
          child: Container(
            width: screenWidth,
            height: screenHeight,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: screenHeight * 0.01),
                    Image.asset(
                      'assets/etablissement_logo.png',
                      height: screenHeight * 0.09,
                      width: screenWidth * 0.5,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.2)),
                      child: TextField(
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        maxLength: 15,
                        controller: myCompany,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Colors.grey[800],
                        ),
                        decoration: InputDecoration(
                            hintText: establishmentHintTextLanguageArray[languageArrayIdentifier],
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            )),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Image.asset(
                      'assets/operateur_logo.png',
                      height: screenHeight * 0.09,
                      width: screenWidth * 0.5,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.2)),
                      child: TextField(
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        maxLength: 15,
                        controller: myName,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Colors.grey[800],
                        ),
                        decoration: InputDecoration(
                            hintText: userHintTextLanguageArray[languageArrayIdentifier],
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            )),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Image.asset(
                      'assets/piece_logo.png',
                      height: screenHeight * 0.09,
                      width: screenWidth * 0.5,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.2)),
                      child: TextField(
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        maxLength: 15,
                        controller: myRoomName,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                        ),
                        decoration: InputDecoration(
                            hintText: roomHintTextLanguageArray[languageArrayIdentifier],
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            )),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.1)),
                      child: Text(
                        profileMessageTextLanguageArray[languageArrayIdentifier],
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    TextButton(
                      onPressed: () {
                        if (myDevice.getConnectionState()) {
                          myUvcLight =
                              UvcLight(machineName: myDevice.device.name, machineMac: myDevice.device.id.toString(), company: myCompany.text, operatorName: myName.text, roomName: myRoomName.text);
                          Navigator.pushNamed(context, '/settings');
                        } else {
                          myUvcToast = ToastyMessage(toastContext: context);
                          myUvcToast.setToastDuration(5);
                          myUvcToast.setToastMessage(deviceOutOfReachTextLanguageArray[languageArrayIdentifier]);
                          myUvcToast.showToast(Colors.red, Icons.close, Colors.white);
                          myDevice.disconnect();
                          Navigator.pushNamedAndRemoveUntil(context, "/check_permissions", (r) => false);
                        }
                        //alertSecurity(context);
                      },
                      child: Text(
                        nextButtonTextLanguageArray[languageArrayIdentifier],
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[400]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      onWillPop: () => disconnection(context),
    );
  }

  Future<void> disconnection(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(attentionTextLanguageArray[languageArrayIdentifier]),
        content: Text(disconnectAlertDialogMessageTextLanguageArray[languageArrayIdentifier]),
        actions: [
          TextButton(
            child: Text(yesTextLanguageArray[languageArrayIdentifier]),
            onPressed: () {
              Navigator.pop(c, true);
              myDevice.disconnect();
              Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
            },
          ),
          TextButton(
            child: Text(noTextLanguageArray[languageArrayIdentifier]),
            onPressed: () => Navigator.pop(c, false),
          ),
        ],
      ),
    );
  }
}
