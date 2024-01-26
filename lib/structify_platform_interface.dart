import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'structify_method_channel.dart';

abstract class StructifyPlatform extends PlatformInterface {
  /// Constructs a StructifyPlatform.
  StructifyPlatform() : super(token: _token);

  static final Object _token = Object();

  static StructifyPlatform _instance = MethodChannelStructify();

  /// The default instance of [StructifyPlatform] to use.
  ///
  /// Defaults to [MethodChannelStructify].
  static StructifyPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [StructifyPlatform] when
  /// they register themselves.
  static set instance(StructifyPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
