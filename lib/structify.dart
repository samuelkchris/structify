
import 'structify_platform_interface.dart';

class Structify {
  Future<String?> getPlatformVersion() {
    return StructifyPlatform.instance.getPlatformVersion();
  }
}
