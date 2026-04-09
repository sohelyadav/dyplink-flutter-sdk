import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Collects device and app metadata for identify / deferred-match
/// requests. All values are best-effort — missing data is returned
/// as `null` or an empty string.
class DeviceInfoCollector {
  DeviceInfoCollector({DeviceInfoPlugin? plugin})
      : _plugin = plugin ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _plugin;

  Future<Map<String, dynamic>> collect() async {
    final result = <String, dynamic>{
      'platform': _platformName(),
    };

    try {
      if (Platform.isAndroid) {
        final info = await _plugin.androidInfo;
        result.addAll(<String, dynamic>{
          'os': 'Android',
          'osVersion': info.version.release,
          'model': info.model,
          'manufacturer': info.manufacturer,
          'brand': info.brand,
          'device': info.device,
        });
      } else if (Platform.isIOS) {
        final info = await _plugin.iosInfo;
        result.addAll(<String, dynamic>{
          'os': 'iOS',
          'osVersion': info.systemVersion,
          'model': info.utsname.machine,
          'manufacturer': 'Apple',
          'device': info.name,
        });
      }
    } catch (_) {
      // best-effort
    }

    try {
      final pkg = await PackageInfo.fromPlatform();
      result['appVersion'] = pkg.version;
      result['appBuild'] = pkg.buildNumber;
      result['appPackage'] = pkg.packageName;
    } catch (_) {
      // best-effort
    }

    final view = PlatformDispatcher.instance.views.isNotEmpty
        ? PlatformDispatcher.instance.views.first
        : null;
    if (view != null) {
      final size = view.physicalSize / view.devicePixelRatio;
      result['screenWidth'] = size.width.round();
      result['screenHeight'] = size.height.round();
    }

    result['locale'] = PlatformDispatcher.instance.locale.toLanguageTag();
    result['language'] = PlatformDispatcher.instance.locale.languageCode;

    return result;
  }

  String _platformName() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }
}
