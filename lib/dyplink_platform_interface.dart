import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'dyplink_method_channel.dart';

abstract class DyplinkPlatform extends PlatformInterface {
  /// Constructs a DyplinkPlatform.
  DyplinkPlatform() : super(token: _token);

  static final Object _token = Object();

  static DyplinkPlatform _instance = MethodChannelDyplink();

  /// The default instance of [DyplinkPlatform] to use.
  ///
  /// Defaults to [MethodChannelDyplink].
  static DyplinkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DyplinkPlatform] when
  /// they register themselves.
  static set instance(DyplinkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
