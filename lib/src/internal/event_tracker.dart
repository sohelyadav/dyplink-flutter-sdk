import '../models/dyplink_error.dart';
import '../models/track_conversion_params.dart';
import 'api_client.dart';
import 'fingerprint_provider.dart';

/// Fire-and-forget event + conversion tracker.
class EventTracker {
  EventTracker({
    required this.apiClient,
    required this.fingerprintProvider,
    required this.projectId,
  });

  final ApiClient apiClient;
  final FingerprintProvider fingerprintProvider;
  final String projectId;

  /// Enqueues a custom event. Errors are swallowed.
  Future<void> track(String eventName, [Map<String, dynamic>? properties]) async {
    try {
      await apiClient.post('/api/events/track', <String, dynamic>{
        'projectId': projectId,
        'eventName': eventName,
        'distinctId': fingerprintProvider.distinctId,
        'deviceFingerprint': fingerprintProvider.fingerprint,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        if (properties != null) 'properties': properties,
      });
    } on DyplinkError {
      // fire-and-forget
    }
  }

  /// Records a conversion event.
  Future<void> trackConversion(TrackConversionParams params) async {
    final body = <String, dynamic>{
      'projectId': projectId,
      'deviceFingerprint': fingerprintProvider.fingerprint,
      'distinctId': fingerprintProvider.distinctId,
      ...params.toJson(),
    };
    await apiClient.post('/api/conversions', body);
  }
}
