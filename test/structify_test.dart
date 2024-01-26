import 'package:flutter_test/flutter_test.dart';
import 'package:structify/structify.dart';
import 'package:structify/structify_platform_interface.dart';
import 'package:structify/structify_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockStructifyPlatform
    with MockPlatformInterfaceMixin
    implements StructifyPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final StructifyPlatform initialPlatform = StructifyPlatform.instance;

  test('$MethodChannelStructify is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelStructify>());
  });

  test('getPlatformVersion', () async {
    Structify structifyPlugin = Structify();
    MockStructifyPlatform fakePlatform = MockStructifyPlatform();
    StructifyPlatform.instance = fakePlatform;

    expect(await structifyPlugin.getPlatformVersion(), '42');
  });
}
