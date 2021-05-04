// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_app_dmx_maestro/pages/check_permissions.dart';
import 'package:flutter_app_dmx_maestro/pages/home.dart';
import 'package:flutter_app_dmx_maestro/pages/scan_ble_list.dart';
import 'package:flutter_app_dmx_maestro/pages/settings.dart';
import 'package:flutter_app_dmx_maestro/pages/welcome.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  List<double> heightScreenDevice = [1440.0, 1440.0, 1024.0, 1200.0, 1500.0, 800.0, 1024.0, 1440.0];
  List<double> widthScreenDevice = [2560.0, 869.0, 480.0, 1200.0, 1000.0, 400.0, 768.0, 720.0];
  List<double> devicePixelRatio = [1.0, 2.0, 3.0, 4.0];

  for (int i = 0; i < heightScreenDevice.length; i++) {
    for (int j = 0; j < devicePixelRatio.length; j++) {
      // test Welcome Widget
      testWidgets('Welcome widget test', (WidgetTester welcomeWidgetTest) async {
        print('height screen $i selected is : ${heightScreenDevice[i]}');
        print('width screen $i selected is : ${widthScreenDevice[i]}');
        print('pixel ratio screen $i selected is : ${devicePixelRatio[j]}');
        welcomeWidgetTest.binding.window.physicalSizeTestValue = Size(widthScreenDevice[i], heightScreenDevice[i]);
        welcomeWidgetTest.binding.window.devicePixelRatioTestValue = devicePixelRatio[j];
        // Build our app and trigger a frame.
        await welcomeWidgetTest.pumpWidget(MaterialApp(home: Welcome()));

        // Declare widget keys
        final appLogoKey = Key('app_logo');
        final loaderKey = Key('loader');
        final delitechLogoKey = Key('delitech_logo');
        final appVersionKey = Key('app_version');

        // Verify app logo inside welcome widget
        expect(find.byKey(appLogoKey), findsOneWidget);
        // Verify loader animation inside welcome widget
        expect(find.byKey(loaderKey), findsOneWidget);
        // Verify DELITECH logo inside welcome widget
        expect(find.byKey(delitechLogoKey), findsOneWidget);
        // Verify app developers text inside welcome widget
        expect(find.text('Powered by DELITECH Group'), findsOneWidget);
        // Verify app version text inside welcome widget
        expect(find.byKey(appVersionKey), findsOneWidget);

        // resets the screen to its original size after the test ended
        //addTearDown(welcomeWidgetTest.binding.window.clearPhysicalSizeTestValue);
      });

      // test Permissions Widget
      testWidgets('Check Permissions widget test', (WidgetTester permissionsWidgetTest) async {
        // Build our app and trigger a frame.
        await permissionsWidgetTest.pumpWidget(MaterialApp(home: CheckPermissions()));

        // Declare widget keys
        final titleKey = Key('title');
        final descriptionKey = Key('description');
        final bluetoothGIFKey = Key('bluetooth_gif');
        final understoodButtonKey = Key('understood_key');

        // Verify title inside permissions widget
        expect(find.byKey(titleKey), findsOneWidget);
        // Verify description widget inside permissions widget
        expect(find.byKey(descriptionKey), findsOneWidget);
        // Verify description text inside permissions widget
        expect(
            find.text('Afin de garantir le bon fonctionnement de l\'application merci '
                'd\'activer votre Bluetooth ainsi que votre localisation.'),
            findsOneWidget);
        // Verify bluetooth GIF inside permissions widget
        expect(find.byKey(bluetoothGIFKey), findsOneWidget);
        // Verify the understood button is inside permissions widget
        expect(find.byKey(understoodButtonKey), findsOneWidget);
        // Tap the understood button.
        await permissionsWidgetTest.tap(find.byKey(understoodButtonKey));
        // Rebuild the widget after the state has changed.
        await permissionsWidgetTest.pump();
      });

      // test Scan List widget
      testWidgets('Scan List widget test', (WidgetTester scanListWidgetTest) async {
        // Build our app and trigger a frame.
        await scanListWidgetTest.pumpWidget(MaterialApp(home: ScanListBle()));

        // Declare widget keys
        final titleKey = Key('title');

        // Verify title inside scan list widget
        expect(find.byKey(titleKey), findsOneWidget);
        // Tap the scan icon button.
        //await scanListWidgetTest.tap(find.byType(FloatingActionButton));
      });

      // test Home widget
      testWidgets('Home widget test', (WidgetTester homeWidgetTest) async {
        // Build our app and trigger a frame.
        await homeWidgetTest.pumpWidget(MaterialApp(home: Home()));

        // Declare widget keys
        final bottomBarTitleKey = Key('bottom_bar_title');
        final settingsKey = Key('settings_button');
        final ambianceWidgetKey = Key('ambiance_widget');
        final remoteControlWidgetKey = Key('remote_control_widget');

        // Verify bottom bar title inside home widget
        expect(find.byKey(bottomBarTitleKey), findsOneWidget);
        // Verify ambiance widget inside home widget
        expect(find.byKey(ambianceWidgetKey), findsOneWidget);
        // Verify remote control widget inside home widget
        expect(find.byKey(remoteControlWidgetKey), findsOneWidget);

        // Verify settings button inside home widget
        expect(find.byKey(settingsKey), findsOneWidget);
        // Tap the ambiance button.
        print('display ambiance widget !');
        await homeWidgetTest.tap(find.byKey(bottomBarTitleKey));
      });

      // test Settings widget
      /*testWidgets('settings widget test', (WidgetTester homeWidgetTest) async {
        // Build our app and trigger a frame.
        await homeWidgetTest.pumpWidget(MaterialApp(home: Settings()));

      // Declare widget keys
      final bottomBarTitleKey = Key('bottom_bar_title');
      final settingsKey = Key('settings_button');
      final ambianceWidgetKey = Key('ambiance_widget');
      final remoteControlWidgetKey = Key('remote_control_widget');

      // Verify bottom bar title inside home widget
      expect(find.byKey(bottomBarTitleKey), findsOneWidget);
      // Verify ambiance widget inside home widget
      expect(find.byKey(ambianceWidgetKey), findsOneWidget);
      // Verify remote control widget inside home widget
      expect(find.byKey(remoteControlWidgetKey), findsOneWidget);

      // Verify settings button inside home widget
      expect(find.byKey(settingsKey), findsOneWidget);
        print('****************************************************************************************************************');
      });*/
    }
  }
}
