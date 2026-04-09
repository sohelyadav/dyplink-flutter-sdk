import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'dyplink_platform_interface.dart';

/// An implementation of [DyplinkPlatform] that uses method channels.
class MethodChannelDyplink extends DyplinkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('dyplink');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
