
import 'dyplink_platform_interface.dart';

class Dyplink {
  Future<String?> getPlatformVersion() {
    return DyplinkPlatform.instance.getPlatformVersion();
  }
}
