/// Response from a successful identify call.
class IdentifyResult {
  const IdentifyResult({
    required this.id,
    required this.projectId,
    required this.deviceFingerprint,
    required this.platform,
    this.distinctId,
    this.externalUserId,
  });

  final String id;
  final String projectId;
  final String? distinctId;
  final String? externalUserId;
  final String deviceFingerprint;
  final String platform;

  factory IdentifyResult.fromJson(Map<String, dynamic> json) => IdentifyResult(
        id: json['id'] as String,
        projectId: json['projectId'] as String,
        distinctId: json['distinctId'] as String?,
        externalUserId: json['externalUserId'] as String?,
        deviceFingerprint: json['deviceFingerprint'] as String,
        platform: json['platform'] as String,
      );
}
