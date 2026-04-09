import 'package:flutter_test/flutter_test.dart';
import 'package:dyplink/dyplink.dart';
import 'package:dyplink/dyplink_platform_interface.dart';
import 'package:dyplink/dyplink_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDyplinkPlatform
    with MockPlatformInterfaceMixin
    implements DyplinkPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final DyplinkPlatform initialPlatform = DyplinkPlatform.instance;

  test('$MethodChannelDyplink is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDyplink>());
  });

  test('getPlatformVersion', () async {
    Dyplink dyplinkPlugin = Dyplink();
    MockDyplinkPlatform fakePlatform = MockDyplinkPlatform();
    DyplinkPlatform.instance = fakePlatform;

    expect(await dyplinkPlugin.getPlatformVersion(), '42');
  });
}
