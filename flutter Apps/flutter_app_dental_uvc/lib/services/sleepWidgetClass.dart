import 'package:flutter/material.dart';
import 'package:flutter_gifimage/flutter_gifimage.dart';

class SleepWidget {
  GifController _gifController;

  final int _timeSleep = 10000;

  bool _widgetIsInactive = false;

  Widget _mainWidgetScreen;

  int _timeToSleep;

  BuildContext _context;

  SleepWidget();

  void initSleep({TickerProvider tickerProvider, BuildContext context,Widget appWidget}) {
    _gifController = GifController(vsync: tickerProvider);
    _context = context;
    _mainWidgetScreen = appWidget;
    _screenSleep();
  }

  Widget _sleepWidget() {
    double widthScreen = MediaQuery.of(_context).size.width;
    double heightScreen = MediaQuery.of(_context).size.height;
    // loop from 0 frame to 29 frame
    _gifController.repeat(min: 0, max: 11, period: Duration(milliseconds: 1000));
    return Scaffold(
      backgroundColor: Colors.blue[400],
      body: Center(
        child: GifImage(
          controller: _gifController,
          fit: BoxFit.cover,
          height: heightScreen,
          width: widthScreen,
          image: AssetImage('assets/logo-delitech-animation.gif'),
        ),
      ),
    );
  }

  void _screenSleep() async {
    _timeToSleep = _timeSleep;
    do {
      _timeToSleep -= 1000;
      if (_timeToSleep == 0) {
        _mainWidgetScreen = _sleepWidget();
      }

      if (_timeToSleep < 0) {
        _timeToSleep = (-1000);
      }

      if (_widgetIsInactive) {
        break;
      }
      await Future.delayed(Duration(seconds: 1));
    } while (true);
  }

  void resetSleepScreen(Widget mainAppWidget) {
    _timeToSleep = _timeSleep;
    _mainWidgetScreen = mainAppWidget;
  }

  void closeSleepScreenClass(bool closeOrOpen) {
    _widgetIsInactive = closeOrOpen;
  }

  Widget getMainWidget() {
    return _mainWidgetScreen;
  }
}
