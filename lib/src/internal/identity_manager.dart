import '../models/dyplink_error.dart';
import '../models/identify_params.dart';
import '../models/identify_result.dart';
import 'api_client.dart';
import 'device_info_collector.dart';
import 'fingerprint_provider.dart';

/// Handles identify / merge / revenue calls against the backend.
class IdentityManager {
  IdentityManager({
    required this.apiClient,
    required this.fingerprintProvider,
    required this.deviceInfoCollector,
    required this.projectId,
    this.enableAutoDeviceInfo = true,
  });

  final ApiClient apiClient;
  final FingerprintProvider fingerprintProvider;
  final DeviceInfoCollector deviceInfoCollector;
  final String projectId;
  final bool enableAutoDeviceInfo;

  Future<IdentifyResult> identify(IdentifyParams params) async {
    final previousDistinctId = fingerprintProvider.distinctId;

    if (params.externalUserId != null) {
      fingerprintProvider.identifiedId = params.externalUserId;
    } else if (params.distinctId != null) {
      fingerprintProvider.identifiedId = params.distinctId;
    }

    final body = <String, dynamic>{
      'projectId': projectId,
      'deviceFingerprint': fingerprintProvider.fingerprint,
      'anonymousId': fingerprintProvider.anonymousId,
      ...params.toJson(),
    };

    if (enableAutoDeviceInfo) {
      final device = await deviceInfoCollector.collect();
      body['deviceInfo'] = device;
      body['platform'] ??= device['platform'];
      body['appVersion'] ??= device['appVersion'];
      body['appBuild'] ??= device['appBuild'];
      body['locale'] ??= device['locale'];
      body['language'] ??= device['language'];
    }

    final json = await apiClient.post('/api/identity/identify', body);
    final result = IdentifyResult.fromJson(json);

    // Issue a merge when transitioning from anonymous → identified.
    final newDistinctId = fingerprintProvider.distinctId;
    if (newDistinctId != previousDistinctId) {
      await _merge(previousDistinctId, newDistinctId);
    }

    return result;
  }

  Future<void> trackRevenue(double amount, String currency) async {
    await apiClient.post('/api/identity/revenue', <String, dynamic>{
      'projectId': projectId,
      'deviceFingerprint': fingerprintProvider.fingerprint,
      'amount': amount,
      'currency': currency,
    });
  }

  Future<void> _merge(String anonymousId, String identifiedId) async {
    try {
      await apiClient.post('/api/identity/merge', <String, dynamic>{
        'projectId': projectId,
        'anonymousId': anonymousId,
        'identifiedId': identifiedId,
      });
    } on DyplinkError {
      // merge failure is non-fatal — identity still transitioned locally
    }
  }
}
