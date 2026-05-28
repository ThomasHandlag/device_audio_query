// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:device_audio_query/device_audio_query.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('requestPermission test', (WidgetTester tester) async {
    final DeviceAudioQuery plugin = DeviceAudioQuery();
    // In a test environment, permission is typically denied or granted depending on OS setup,
    // so we just check that it returns a valid PermissionStatus.
    final PermissionStatus status = await plugin.requestPermission();
    expect(status, isNotNull);
  });
}
