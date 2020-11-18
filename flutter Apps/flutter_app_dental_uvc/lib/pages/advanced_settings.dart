import 'package:flutter/material.dart';
import 'package:flutterappdentaluvc/services/bleDeviceClass.dart';

class AdvancedSettings extends StatefulWidget {
  @override
  _AdvancedSettingsState createState() => _AdvancedSettingsState();
}

class _AdvancedSettingsState extends State<AdvancedSettings> {
  Map advancedSettingsData = {};

  String pinCodeAccess = '';

  Device myDevice;

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;

    advancedSettingsData = advancedSettingsData.isNotEmpty ? advancedSettingsData : ModalRoute.of(context).settings.arguments;
    pinCodeAccess = advancedSettingsData['pinCodeAccess'];
    myDevice = advancedSettingsData['myDevice'];
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Paramètres'),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(color: Colors.grey[200]),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: heightScreen * 0.05),
                  FlatButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/pin_settings', arguments: {
                        'pinCodeAccess': pinCodeAccess,
                      });
                    },
                    child: Text(
                      'Changer MDP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: widthScreen * 0.05,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    color: Colors.blue[400],
                  ),
                  SizedBox(height: heightScreen * 0.05),
                  FlatButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/scan_ble_list', arguments: {
                        'pinCodeAccess': pinCodeAccess,
                        'myDevice': myDevice,
                      });
                    },
                    child: Text(
                      'Changer dispositif',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: widthScreen * 0.05,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    color: Colors.blue[400],
                  ),
                  SizedBox(height: heightScreen * 0.05),
                  FlatButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/auto_uvc', arguments: {
                        'pinCodeAccess': pinCodeAccess,
                      });
                    },
                    child: Text(
                      'Auto',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: widthScreen * 0.05,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    color: Colors.blue[400],
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).pop();
          },
          label: Text('Retour'),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
          backgroundColor: Colors.blue[400],
        ),
      ),
    );
  }


}
