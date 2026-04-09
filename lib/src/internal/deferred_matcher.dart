import 'dart:convert';

import '../models/deferred_match_result.dart';
import '../models/dyplink_error.dart';
import 'api_client.dart';
import 'device_info_collector.dart';
import 'preferences.dart';

/// Performs a server-side deferred deep link match.
///
/// Attempted **at most once** per install — the result is cached in
/// [DyplinkPreferences] for subsequent calls.
class DeferredMatcher {
  DeferredMatcher({
    required this.apiClient,
    required this.deviceInfoCollector,
    required this.prefs,
  });

  final ApiClient apiClient;
  final DeviceInfoCollector deviceInfoCollector;
  final DyplinkPreferences prefs;

  Future<DeferredMatchResult> match({String? cookieRef}) async {
    if (prefs.deferredMatchAttempted) {
      return _parseCached();
    }

    try {
      final result = await _performMatch(cookieRef);
      prefs.deferredMatchAttempted = true;
      if (result.matched) {
        prefs.deferredMatchResult = jsonEncode(result.toJson());
        prefs.attributedShortCode = result.shortCode;
        prefs.attributedLinkId = result.linkId;
      }
      return result;
    } on DyplinkError {
      prefs.deferredMatchAttempted = true;
      return DeferredMatchResult.unmatched();
    }
  }

  Future<DeferredMatchResult> _performMatch(String? cookieRef) async {
    final body = <String, dynamic>{};
    if (cookieRef != null) body['cookieRef'] = cookieRef;

    final device = await deviceInfoCollector.collect();
    final os = (device['os'] as String?) ?? '';
    final model = (device['model'] as String?) ?? '';

    // Only include `fingerprint` when we have real device info —
    // platform validates `ip` with @IsIP() so an empty string would fail.
    if (os.isNotEmpty || model.isNotEmpty) {
      body['fingerprint'] = <String, dynamic>{
        'os': os,
        'osVersion': device['osVersion'] ?? '',
        'model': model,
        'screenWidth': device['screenWidth'] ?? 0,
        'screenHeight': device['screenHeight'] ?? 0,
      };
    }

    final json = await apiClient.post('/api/deferred/match', body);
    return DeferredMatchResult.fromJson(json);
  }

  DeferredMatchResult _parseCached() {
    final raw = prefs.deferredMatchResult;
    if (raw == null) return DeferredMatchResult.unmatched();
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return DeferredMatchResult.fromJson(json);
    } catch (_) {
      return DeferredMatchResult.unmatched();
    }
  }
}
