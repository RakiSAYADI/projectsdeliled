import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_bispectrum/services/DataVariables.dart';
import 'package:flutter_app_bispectrum/services/bleDeviceClass.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_gifimage/flutter_gifimage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocation/geolocation.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  BluetoothCharacteristic characteristicMaestro;
  BluetoothCharacteristic characteristicWifi;
  Device myDevice;

  int timeToSleep;

  int boolToInt(bool a) => a == true ? 1 : 0;

  bool firstDisplayMainWidget = true;
  String carbonStateOnSleepGif;
  String carbonStateOnHome = "assets/personnage-vert.png";

  List<double> opacityLevelWidgets = [1.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  List<bool> appVisibility = [true, false, false, false, false, false];

  GifController gifController;

  DateTime now;

  @override
  void initState() {
    // TODO: implement initState
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    gifController = GifController(vsync: this);
    //gifController.repeat(min: 0, max: 20, period: Duration(seconds: 2));
    super.initState();
  }

  StreamSubscription<LocationResult> subscription;

  Future<void> accessGeolocationData() async {
    subscription = Geolocation.locationUpdates(
      accuracy: LocationAccuracy.best,
      displacementFilter: 10.0, // in meters
      inBackground:
          true, // by default, location updates will pause when app is inactive (in background). Set to `true` to continue updates in background.
    ).listen((result) async {
      if (result.isSuccessful) {
        // todo with result
        double lat = result.location.latitude;
        double lng = result.location.longitude;
        print('$lat - $lng');
        WeatherFactory wf = new WeatherFactory("881093136b4241dc1031abe900672816");
        Weather w = await wf.currentWeatherByLocation(lat, lng);
        print(w.country);
        print(w.temperature.celsius);
        print(w.areaName);
        temperatureMeteoValue = w.temperature.celsius.round();
        weatherState = w.weatherIcon;
        print(w.weatherIcon);
      }
    });
  }

  void appGetGeolocation() async {
    final GeolocationResult result1 = await Geolocation.isLocationOperational();
    if (result1.isSuccessful) {
      print('geolocation access is granted');
      // location service is enabled, and location permission is granted
      await accessGeolocationData();
    } else {
      print('geolocation access is NOT granted');
      // location service is not enabled, restricted, or location permission is denied
      final GeolocationResult result = await Geolocation.requestLocationPermission(
        permission: const LocationPermission(
          android: LocationPermissionAndroid.fine,
          ios: LocationPermissionIOS.always,
        ),
        openSettingsIfDenied: true,
      );

      if (result.isSuccessful) {
        print('geolocation access is now granted');
        // location permission is granted (or was already granted before making the request)
        await accessGeolocationData();
      } else {
        print('geolocation access is denied');
        // location permission is not granted
        // user might have denied, but it's also possible that location service is not enabled, restricted, and user never saw the permission request dialog. Check the result.error.type for details.
      }
    }
  }

  void appRefreshData(BuildContext context) async {
    timeToSleep = timeSleep;
    mainWidgetScreen = appWidget(context);
    do {
      await Future.delayed(Duration(seconds: 1));
      now = DateTime.now();
      appTime = DateFormat('kk:mm').format(now);

      if (co2Value > 2000) {
        carbonStateOnSleepGif = "assets/fond-rouge-veille.gif";
        carbonStateOnHome = "assets/personnage-rouge.png";
      }
      if ((co2Value >= 1000) & (co2Value <= 2000)) {
        carbonStateOnSleepGif = "assets/fond-orange-veille.gif";
        carbonStateOnHome = "assets/personnage-orange.png";
      }
      if (co2Value < 1000) {
        carbonStateOnSleepGif = "assets/fond-vert-veille.gif";
        carbonStateOnHome = "assets/personnage-vert.png";
      }
      co2Value += 10;

      timeToSleep -= 1000;
      if (timeToSleep <= 0) {
        try {
          setState(() {
            mainWidgetScreen = sleepWidget(context);
          });
          await Future.delayed(Duration(milliseconds: 50));
        } catch (e) {
          print(e.message);
          break;
        }
        timeToSleep = (-1000);
      } else {
        try {
          setState(() {
            mainWidgetScreen = appWidget(context);
          });
          await Future.delayed(Duration(milliseconds: 50));
        } catch (e) {
          print(e.message);
          break;
        }
      }

      print(timeToSleep);
      if (deactivateSleepAndReadingProcess) {
        break;
      }
    } while (true);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    gifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (firstDisplayMainWidget) {
      try {
        appGetGeolocation();
        appRefreshData(context);
      } catch (e) {
        print('erreur');
      }
      firstDisplayMainWidget = false;
    }
    return WillPopScope(
      child: GestureDetector(
        child: mainWidgetScreen,
        onTap: () {
          setState(() {
            timeToSleep = timeSleep;
            mainWidgetScreen = appWidget(context);
          });
        },
      ),
      onWillPop: () => showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('Attention'),
          content: Text('Êtes-vous sûr de vouloir revenir à la page de sélection des cartes Maestro™ ?'),
          actions: [
            TextButton(
                child: Text('Oui'),
                onPressed: () async {
                  // cancelling subscription will also stop the ongoing location request
                  subscription.cancel();
                  if (myDevice != null) {
                    await myDevice.disconnect();
                  }
                  deactivateSleepAndReadingProcess = true;
                  Navigator.pop(c, true);
                }),
            TextButton(
              child: Text('Non'),
              onPressed: () => Navigator.pop(c, false),
            ),
          ],
        ),
      ),
    );
  }

  Widget appWidget(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background-bispectrum.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Stack(
            children: [
              AnimatedOpacity(
                duration: Duration(seconds: 1),
                curve: Curves.linear,
                opacity: opacityLevelWidgets[0],
                child: Visibility(visible: appVisibility[0], child: homeWidget(context)),
              ),
/*                  AnimatedOpacity(
                  duration: Duration(seconds: 1),
                  curve: Curves.linear,
                  opacity: opacityLevelWidgets[1],
                  child: Visibility(visible: appVisibility[1]),
                ),
                AnimatedOpacity(
                  duration: Duration(seconds: 1),
                  curve: Curves.linear,
                  opacity: opacityLevelWidgets[2],
                  child: Visibility(visible: appVisibility[2]),
                ),
                AnimatedOpacity(
                  duration: Duration(seconds: 1),
                  curve: Curves.linear,
                  opacity: opacityLevelWidgets[3],
                  child: Visibility(visible: appVisibility[3]),
                ),
                AnimatedOpacity(
                  duration: Duration(seconds: 1),
                  curve: Curves.linear,
                  opacity: opacityLevelWidgets[4],
                  child: Visibility(visible: appVisibility[4]),
                ),
                AnimatedOpacity(
                  duration: Duration(seconds: 1),
                  curve: Curves.linear,
                  opacity: opacityLevelWidgets[5],
                  child: Visibility(visible: appVisibility[5]),
                ),*/
            ],
          ),
        ),
      ),
    );
  }

  Widget homeWidget(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ToggleButtons(
            borderRadius: BorderRadius.circular(18.0),
            isSelected: [true, true, true, true, true],
            onPressed: (int index) async {},
            children: [
              Container(
                  width: (widthScreen - 80) / 5,
                  child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                    new SizedBox(width: 4.0),
                    new Text("Température\n$temperatureValue °C", style: TextStyle(fontSize: 15), textAlign: TextAlign.center)
                  ])),
              Container(
                  width: (widthScreen - 80) / 5,
                  child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                    new SizedBox(width: 4.0),
                    new Text("Humidité\n$humidityValue %", style: TextStyle(fontSize: 15), textAlign: TextAlign.center)
                  ])),
              Container(
                  width: (widthScreen - 80) / 5,
                  child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                    new SizedBox(width: 4.0),
                    new Text("CO2\n$co2Value ppm", style: TextStyle(fontSize: 15), textAlign: TextAlign.center)
                  ])),
              Container(
                  width: (widthScreen - 80) / 5,
                  child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                    new SizedBox(width: 4.0),
                    new Text("TVOC\n$tvocValue mg/m3", style: TextStyle(fontSize: 15), textAlign: TextAlign.center)
                  ])),
              Container(
                  width: (widthScreen - 80) / 5,
                  child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                    new SizedBox(width: 4.0),
                    new Text("ICONE\n$iconeValue", style: TextStyle(fontSize: 15), textAlign: TextAlign.center)
                  ])),
            ],
            borderWidth: 2,
            selectedColor: Colors.white,
            selectedBorderColor: Colors.black,
            fillColor: Color(0xFF264eb6),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.0),
                    color: Color(0xFFFFFFF0),
                    shape: BoxShape.rectangle,
                  ),
                  width: widthScreen * 0.8,
                  height: heightScreen * 0.25,
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 16.0, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'QUALITÉ DE L\'AIR :',
                                style: TextStyle(
                                  color: Color(0xFF264eb6),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                'BON',
                                style: TextStyle(
                                  color: Color(0xFF264eb6),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 40,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Image.asset(
                      carbonStateOnHome,
                      height: heightScreen * 0.4,
                      width: widthScreen * 0.5,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.0),
                    color: Color(0xFF264eb6),
                    shape: BoxShape.rectangle,
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    appTime,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.0),
                    color: Color(0xFF264eb6),
                    shape: BoxShape.rectangle,
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 8.0, 0),
                        child: Transform.scale(
                          scale: 1.2,
                          child: SvgPicture.asset("assets/meteo/$weatherState.svg"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                        child: Text(
                          '$temperatureMeteoValue °C',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.0),
                      color: Color(0xFF264eb6),
                      shape: BoxShape.rectangle,
                    ),
                    padding: const EdgeInsets.all(2.0),
                    child: IconButton(
                        onPressed: null,
                        icon: Icon(
                          Icons.settings,
                          color: Colors.white,
                        ))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget sleepWidget(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    double heightScreen = MediaQuery.of(context).size.height;
    // loop from 0 frame to 29 frame
    gifController.repeat(min: 0, max: 11, period: Duration(milliseconds: 1000));
    return Scaffold(
      backgroundColor: Colors.blue[400],
      body: Center(
        child: GifImage(
          controller: gifController,
          fit: BoxFit.cover,
          height: heightScreen,
          width: widthScreen,
          image: AssetImage(carbonStateOnSleepGif),
        ),
      ),
    );
  }
}
