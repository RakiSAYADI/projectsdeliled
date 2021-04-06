// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_app_dmx_maestro/pages/check_permissions.dart';
import 'package:flutter_app_dmx_maestro/pages/scan_ble_list.dart';
import 'package:flutter_app_dmx_maestro/pages/welcome.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // test Welcome Widget
  testWidgets('Welcome widget test', (WidgetTester welcomeWidgetTest) async {
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
    await scanListWidgetTest.tap(find.byType(FloatingActionButton));
  });
}
