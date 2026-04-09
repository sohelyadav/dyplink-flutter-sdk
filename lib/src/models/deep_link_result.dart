/// Result of parsing a direct deep link from an incoming URI, or from
/// deferred (post-install) matching.
class DeepLinkResult {
  const DeepLinkResult({
    required this.url,
    required this.shortCode,
    required this.isDeferred,
    this.params,
    this.linkId,
  });

  final String url;
  final String? shortCode;
  final Map<String, dynamic>? params;

  /// `true` when this result came from a deferred match (post-install)
  /// rather than a direct intent/URL.
  final bool isDeferred;

  /// Server-assigned link identifier (populated for deferred matches).
  final String? linkId;
}
