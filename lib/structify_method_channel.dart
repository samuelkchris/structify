import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'structify_platform_interface.dart';

/// An implementation of [StructifyPlatform] that uses method channels.
class MethodChannelStructify extends StructifyPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('structify');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
