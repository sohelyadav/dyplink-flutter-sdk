/// Result of a deferred deep link match attempt.
///
/// When the SDK cannot find a direct deep link (the app was opened
/// from the launcher after a fresh install), it asks the server to
/// match the device fingerprint against a recent click.
class DeferredMatchResult {
  const DeferredMatchResult({
    required this.matched,
    this.linkId,
    this.shortCode,
    this.params,
  });

  final bool matched;
  final String? linkId;
  final String? shortCode;
  final Map<String, dynamic>? params;

  factory DeferredMatchResult.unmatched() =>
      const DeferredMatchResult(matched: false);

  factory DeferredMatchResult.fromJson(Map<String, dynamic> json) =>
      DeferredMatchResult(
        matched: json['matched'] as bool? ?? false,
        linkId: json['linkId'] as String?,
        shortCode: json['shortCode'] as String?,
        params: (json['params'] as Map?)?.cast<String, dynamic>(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'matched': matched,
        if (linkId != null) 'linkId': linkId,
        if (shortCode != null) 'shortCode': shortCode,
        if (params != null) 'params': params,
      };
}
