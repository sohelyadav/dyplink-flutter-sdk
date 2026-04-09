/// Immutable configuration for the Dyplink Flutter SDK.
///
/// Construct with the required [baseUrl], [apiKey], and [projectId],
/// then pass to [Dyplink.init].
class DyplinkConfig {
  const DyplinkConfig({
    required this.baseUrl,
    required this.apiKey,
    required this.projectId,
    this.enableAutoSessionTracking = true,
    this.enableAutoDeviceInfo = true,
    this.sessionTimeoutSeconds = 300,
    this.deepLinkHosts = const <String>[],
    this.customScheme,
    this.maxRetries = 3,
    this.debugLogging = false,
  });

  final String baseUrl;
  final String apiKey;
  final String projectId;
  final bool enableAutoSessionTracking;
  final bool enableAutoDeviceInfo;
  final int sessionTimeoutSeconds;
  final List<String> deepLinkHosts;
  final String? customScheme;
  final int maxRetries;
  final bool debugLogging;
}
