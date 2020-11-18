import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UVCAuto extends StatefulWidget {
  @override
  _UVCAutoState createState() => _UVCAutoState();
}

class _UVCAutoState extends State<UVCAuto> {
  List<bool> daysStates;
  String daysInHex;

  int boolToInt(bool a) => a == true ? 1 : 0;

  String myTimeHoursData = '00';
  String myTimeMinutesData = '00';
  String myExtinctionTimeMinuteData = ' 30 sec';
  String myActivationTimeMinuteData = ' 10 sec';

  int myTimeHoursPosition = 0;
  int myTimeMinutesPosition = 0;
  int myExtinctionTimeMinutePosition = 0;
  int myActivationTimeMinutePosition = 0;

  List<String> myTimeHours = [
    '00',
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23'
  ];
  List<String> myTimeMinutes = [
    '00',
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '29',
    '30',
    '31',
    '32',
    '33',
    '34',
    '35',
    '36',
    '37',
    '38',
    '39',
    '40',
    '41',
    '42',
    '43',
    '44',
    '45',
    '46',
    '47',
    '48',
    '49',
    '50',
    '51',
    '52',
    '53',
    '54',
    '55',
    '56',
    '57',
    '58',
    '59'
  ];

  List<String> myExtinctionTimeMinute = [
    ' 30 sec',
    '  1 min',
    '  2 min',
    '  5 min',
    ' 10 min',
    ' 15 min',
    ' 20 min',
    ' 25 min',
    ' 30 min',
    ' 35 min',
    ' 40 min',
    ' 45 min',
    ' 50 min',
    ' 55 min',
    ' 60 min',
    ' 65 min',
    ' 70 min',
    ' 75 min',
    ' 80 min',
    ' 85 min',
    ' 90 min',
    ' 95 min',
    '100 min',
    '105 min',
    '110 min',
    '115 min',
    '120 min',
  ];

  List<String> myActivationTimeMinute = [
    ' 10 sec',
    ' 20 sec',
    ' 30 sec',
    ' 40 sec',
    ' 50 sec',
    ' 60 sec',
    ' 70 sec',
    ' 80 sec',
    ' 90 sec',
    '100 sec',
    '110 sec',
    '120 sec',
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    daysStates = [false, false, false, false, false, false, false];
    daysInHex = ((boolToInt(daysStates[0])) +
            (boolToInt(daysStates[1]) * 2) +
            (boolToInt(daysStates[2]) * 4) +
            (boolToInt(daysStates[3]) * 8) +
            (boolToInt(daysStates[4]) * 16) +
            (boolToInt(daysStates[5]) * 32) +
            (boolToInt(daysStates[6]) * 64))
        .toRadixString(16);
  }

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.blue[400],
      appBar: AppBar(
        title: const Text('UVC Automatique'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Builder(builder: (context) {
          return Container(
            child: Column(
              children: [
                SizedBox(height: heightScreen * 0.05),
                Align(
                  alignment: Alignment.topCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ToggleButtons(
                        isSelected: daysStates,
                        onPressed: (int index) async {
                          setState(() {
                            daysStates[index] = !daysStates[index];
                          });
                          // Writes to a characteristic
                          int zoneState = boolToInt(daysStates[index]);

                          daysInHex = ((boolToInt(daysStates[0])) +
                                  (boolToInt(daysStates[1]) * 2) +
                                  (boolToInt(daysStates[2]) * 4) +
                                  (boolToInt(daysStates[3]) * 8) +
                                  (boolToInt(daysStates[4]) * 16) +
                                  (boolToInt(daysStates[5]) * 32) +
                                  (boolToInt(daysStates[6]) * 64))
                              .toRadixString(16);

                          print(daysInHex);

                          switch (index) {
                            case 0:
                              print('{\"light\": 1,$zoneState,\"1\"}');
                              break;
                            case 1:
                              print('{\"light\": 1,$zoneState,\"2\"}');
                              break;
                            case 2:
                              print('{\"light\": 1,$zoneState,\"4\"}');
                              break;
                            case 3:
                              print('{\"light\": 1,$zoneState,\"8\"}');
                              break;
                            case 4:
                              print('{\"light\": 1,$zoneState,\"16\"}');
                              break;
                            case 5:
                              print('{\"light\": 1,$zoneState,\"32\"}');
                              break;
                            case 6:
                              print('{\"light\": 1,$zoneState,\"64\"}');
                              break;
                          }
                        },
                        children: [
                          Container(
                              width: (widthScreen - 84) / 7,
                              child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[new SizedBox(width: 4.0), new Text("Lundi", style: TextStyle(fontSize: 15))])),
                          Container(
                              width: (widthScreen - 84) / 7,
                              child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[new SizedBox(width: 4.0), new Text("Mardi", style: TextStyle(fontSize: 15))])),
                          Container(
                              width: (widthScreen - 84) / 7,
                              child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[new SizedBox(width: 4.0), new Text("Mercredi", style: TextStyle(fontSize: 15))])),
                          Container(
                              width: (widthScreen - 84) / 7,
                              child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[new SizedBox(width: 4.0), new Text("Jeudi", style: TextStyle(fontSize: 15))])),
                          Container(
                              width: (widthScreen - 84) / 7,
                              child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[new SizedBox(width: 4.0), new Text("Vendredi", style: TextStyle(fontSize: 15))])),
                          Container(
                              width: (widthScreen - 84) / 7,
                              child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[new SizedBox(width: 4.0), new Text("Samedi", style: TextStyle(fontSize: 15))])),
                          Container(
                              width: (widthScreen - 84) / 7,
                              child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[new SizedBox(width: 4.0), new Text("Dimanche", style: TextStyle(fontSize: 15))])),
                        ],
                        borderWidth: 2,
                        color: Colors.grey,
                        selectedBorderColor: Colors.black,
                        selectedColor: Colors.blue,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: heightScreen * 0.04),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Heure d\'activation :',
                      style: TextStyle(
                        fontSize: widthScreen * 0.03,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: heightScreen * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButton<String>(
                          value: myTimeHoursData,
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(color: Colors.grey[800], fontSize: 18),
                          onChanged: (String data) {
                            setState(() {
                              myTimeHoursData = data;
                              myTimeHoursPosition = myTimeHours.indexOf(data);
                              print(myTimeHoursPosition);
                            });
                          },
                          items: myTimeHours.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontSize: widthScreen * 0.03,
                                  color: Colors.grey[600],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        Text(
                          ' : ',
                          style: TextStyle(
                            fontSize: widthScreen * 0.03,
                            color: Colors.black,
                          ),
                        ),
                        DropdownButton<String>(
                          value: myTimeMinutesData,
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(color: Colors.grey[800], fontSize: 18),
                          onChanged: (String data) {
                            setState(() {
                              myTimeMinutesData = data;
                              myTimeMinutesPosition = myTimeMinutes.indexOf(data);
                              print(myTimeMinutesPosition);
                            });
                          },
                          items: myTimeMinutes.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontSize: widthScreen * 0.03,
                                  color: Colors.grey[600],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: heightScreen * 0.04),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: heightScreen * 0.04),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/delais_logo.png',
                              height: heightScreen * 0.09,
                              width: widthScreen * 0.5,
                            ),
                            SizedBox(height: heightScreen * 0.03),
                            Text(
                              'Délais avant allumage :',
                              style: TextStyle(
                                fontSize: widthScreen * 0.03,
                                color: Colors.black,
                              ),
                            ),
                            DropdownButton<String>(
                              value: myActivationTimeMinuteData,
                              icon: Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                              elevation: 16,
                              style: TextStyle(color: Colors.grey[800], fontSize: 18),
                              onChanged: (String data) {
                                setState(() {
                                  myActivationTimeMinuteData = data;
                                  myActivationTimeMinutePosition = myActivationTimeMinute.indexOf(data);
                                  print(myActivationTimeMinutePosition);
                                });
                              },
                              items: myActivationTimeMinute.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      fontSize: widthScreen * 0.03,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Image.asset(
                              'assets/duree_logo.png',
                              height: heightScreen * 0.09,
                              width: widthScreen * 0.5,
                            ),
                            SizedBox(height: heightScreen * 0.03),
                            Text(
                              'Durée de la désinfection :',
                              style: TextStyle(
                                fontSize: widthScreen * 0.03,
                                color: Colors.black,
                              ),
                            ),
                            DropdownButton<String>(
                              value: myExtinctionTimeMinuteData,
                              icon: Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                              elevation: 16,
                              style: TextStyle(color: Colors.grey[800], fontSize: widthScreen * 0.04),
                              onChanged: (String data) {
                                setState(() {
                                  myExtinctionTimeMinuteData = data;
                                  myExtinctionTimeMinutePosition = myExtinctionTimeMinute.indexOf(data);
                                  print(myExtinctionTimeMinutePosition);
                                });
                              },
                              items: myExtinctionTimeMinute.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      fontSize: widthScreen * 0.03,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: heightScreen * 0.04),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Divider(
                    thickness: 1.0,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: heightScreen * 0.04),
                FlatButton(
                  onPressed: () {
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Enregistrer',
                      style: TextStyle(color: Colors.white, fontSize: widthScreen * 0.02),
                    ),
                  ),
                  color: Colors.blue[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
