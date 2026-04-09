import 'dart:async';

import 'dyplink_config.dart';
import 'internal/api_client.dart';
import 'internal/deferred_matcher.dart';
import 'internal/device_info_collector.dart';
import 'internal/event_tracker.dart';
import 'internal/fingerprint_provider.dart';
import 'internal/identity_manager.dart';
import 'internal/preferences.dart';
import 'models/deferred_match_result.dart';
import 'models/dyplink_error.dart';
import 'models/identify_params.dart';
import 'models/identify_result.dart';
import 'models/track_conversion_params.dart';

/// Main entry point for the Dyplink Flutter SDK.
///
/// Call [init] exactly once, typically in `main()` after
/// `WidgetsFlutterBinding.ensureInitialized()`. All other methods
/// require [init] to have completed first.
class Dyplink {
  Dyplink._();

  static final Dyplink instance = Dyplink._();

  late DyplinkConfig _config;
  late ApiClient _apiClient;
  late DyplinkPreferences _prefs;
  late FingerprintProvider _fingerprintProvider;
  late IdentityManager _identityManager;
  late EventTracker _eventTracker;
  late DeferredMatcher _deferredMatcher;
  late DeviceInfoCollector _deviceInfoCollector;

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  DyplinkConfig get config {
    _checkInitialized();
    return _config;
  }

  String get distinctId {
    _checkInitialized();
    return _fingerprintProvider.distinctId;
  }

  String get deviceFingerprint {
    _checkInitialized();
    return _fingerprintProvider.fingerprint;
  }

  String? get attributedShortCode {
    _checkInitialized();
    return _prefs.attributedShortCode;
  }

  String? get attributedLinkId {
    _checkInitialized();
    return _prefs.attributedLinkId;
  }

  // ── Lifecycle ───────────────────────────────────────────────────

  Future<void> init(DyplinkConfig config) async {
    if (_isInitialized) return;

    _config = config;
    _apiClient = ApiClient(config);
    _prefs = await DyplinkPreferences.create();
    _fingerprintProvider = FingerprintProvider(_prefs);
    _deviceInfoCollector = DeviceInfoCollector();

    _identityManager = IdentityManager(
      apiClient: _apiClient,
      fingerprintProvider: _fingerprintProvider,
      deviceInfoCollector: _deviceInfoCollector,
      projectId: config.projectId,
      enableAutoDeviceInfo: config.enableAutoDeviceInfo,
    );

    _eventTracker = EventTracker(
      apiClient: _apiClient,
      fingerprintProvider: _fingerprintProvider,
      projectId: config.projectId,
    );

    _deferredMatcher = DeferredMatcher(
      apiClient: _apiClient,
      deviceInfoCollector: _deviceInfoCollector,
      prefs: _prefs,
    );

    _isInitialized = true;

    // Fire initial anonymous identify in the background.
    unawaited(
      _identityManager.identify(const IdentifyParams()).catchError((_) {
        // best-effort — never fail init on network errors
        return IdentifyResult(
          id: '',
          projectId: config.projectId,
          deviceFingerprint: _fingerprintProvider.fingerprint,
          platform: 'unknown',
        );
      }),
    );
  }

  /// Disposes of internal resources. Usually only needed in tests.
  void dispose() {
    if (!_isInitialized) return;
    _apiClient.close();
    _isInitialized = false;
  }

  // ── Identity ────────────────────────────────────────────────────

  Future<IdentifyResult> identify(IdentifyParams params) async {
    _checkInitialized();
    return _identityManager.identify(params);
  }

  Future<void> trackRevenue(double amount, {String currency = 'USD'}) async {
    _checkInitialized();
    return _identityManager.trackRevenue(amount, currency);
  }

  /// Resets the current identity, generating a fresh anonymous ID.
  /// Call this on user logout.
  void reset() {
    _checkInitialized();
    _fingerprintProvider.reset();
  }

  // ── Events ──────────────────────────────────────────────────────

  Future<void> track(String eventName, [Map<String, dynamic>? properties]) async {
    _checkInitialized();
    return _eventTracker.track(eventName, properties);
  }

  Future<void> trackConversion(TrackConversionParams params) async {
    _checkInitialized();
    return _eventTracker.trackConversion(params);
  }

  // ── Deferred deep link ──────────────────────────────────────────

  /// Attempts to match this install against a prior link click.
  ///
  /// The result is cached after the first attempt — subsequent calls
  /// return the same value without hitting the network.
  Future<DeferredMatchResult> matchDeferredDeepLink({String? cookieRef}) async {
    _checkInitialized();
    return _deferredMatcher.match(cookieRef: cookieRef);
  }

  // ── Internal accessors (used by sub-modules) ────────────────────

  ApiClient get internalApiClient {
    _checkInitialized();
    return _apiClient;
  }

  FingerprintProvider get internalFingerprintProvider {
    _checkInitialized();
    return _fingerprintProvider;
  }

  // ── Helpers ─────────────────────────────────────────────────────

  void _checkInitialized() {
    if (!_isInitialized) throw const NotInitializedError();
  }
}
