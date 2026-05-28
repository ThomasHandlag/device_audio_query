import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:device_audio_query/device_audio_query.dart';
import 'package:device_audio_query/device_audio_query_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelDeviceAudioQuery platform = MethodChannelDeviceAudioQuery();
  const MethodChannel channel = MethodChannel('device_audio_query');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'requestPermission') return 0;
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('requestPermission', () async {
    expect(await platform.requestPermission(), PermissionStatus.granted);
  });
}
