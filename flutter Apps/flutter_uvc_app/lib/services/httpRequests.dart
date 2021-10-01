/*import 'package:mysql1/mysql1.dart';*/
import 'dart:io';

import 'package:http/http.dart' as http;

class DataBaseRequests {
  final String _insertDataLink = 'https://www.deeplight.fr/insertdata/';
  final String _idMail = 'idMail';
  final String _idNomRobot = 'NomRobot';

  final String _insertUVCDataLink = 'https://www.deeplight.fr/insertdonneesrobots/';
  final String _idRobotName = 'idNomRobot';
  final String _idUser = 'utilisateur';
  final String _idEnterprise = 'etablissement';
  final String _idRoom = 'chambre';
  final String _idStartHour = 'heureActivite';
  final String _idStartDate = 'dateActivation';
  final String _idStartDuration = 'tempsDesinfection';
  final String _idUvcState = 'etat';

  void createUserInDataBase(String email, String robotName) async {
/*    final response = await http.post(_insertDataLink, body: {
      _idMail: email,
      _idNomRobot: robotName,
    });
    print(response.body);*/
  }

  Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      print('not connected');
      return false;
    }
  }

  void sendUVCDataToDataBase(
      String robotName, String user, String enterprise, String room, String startHour, String startDate, String startDuration, String state) async {
/*    final response = await http.post(_insertUVCDataLink, body: {
      _idRobotName: robotName,
      _idUser: user,
      _idEnterprise: enterprise,
      _idRoom: room,
      _idStartHour: startHour,
      _idStartDate: startDate,
      _idStartDuration: startDuration,
      _idUvcState: state,
    });
    print(response.body);*/
  }

/*  void sqlConnection() async {
    // Open a connection (testdb should already exist)
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: 'deepliwadmin.mysql.db',
        port: 3307,
        useSSL: false,
        user: 'deepliwadmin',
        password: 'DeepLight20pz',
        db: 'deepliwadmin',
        characterSet: CharacterSet.UTF8));

    // Create a table
    await conn.query('CREATE TABLE users (id int NOT NULL AUTO_INCREMENT PRIMARY KEY, name varchar(255), email varchar(255), age int)');

    // Insert some data
    var result = await conn.query('insert into users (name, email, age) values (?, ?, ?)', ['Bob', 'bob@bob.com', 25]);
    print('Inserted row id=${result.insertId}');

    // Query the database using a parameterized query
    var results = await conn.query('select name, email from users where id = ?', [result.insertId]);
    for (var row in results) {
      print('Name: ${row[0]}, email: ${row[1]}');
    }

    // Finally, close the connection
    await conn.close();
  }*/
}
