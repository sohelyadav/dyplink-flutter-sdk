/// Parameters for tracking a conversion event.
class TrackConversionParams {
  const TrackConversionParams({
    required this.eventType,
    this.shortCode,
    this.linkId,
    this.externalUserId,
    this.metadata,
  });

  final String eventType;
  final String? shortCode;
  final String? linkId;
  final String? externalUserId;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'eventType': eventType};
    if (shortCode != null) map['shortCode'] = shortCode;
    if (linkId != null) map['linkId'] = linkId;
    if (externalUserId != null) map['externalUserId'] = externalUserId;
    if (metadata != null) map['metadata'] = metadata;
    return map;
  }
}
