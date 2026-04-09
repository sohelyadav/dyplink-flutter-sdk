import 'package:uuid/uuid.dart';

import 'preferences.dart';

/// Owns the device fingerprint, anonymous ID, and identified ID.
///
/// Lazy-initialises them on first access and persists to
/// [DyplinkPreferences].
class FingerprintProvider {
  FingerprintProvider(this._prefs) {
    final existingFingerprint = _prefs.fingerprint;
    if (existingFingerprint == null) {
      _fingerprint = _uuid.v4();
      _prefs.fingerprint = _fingerprint;
    } else {
      _fingerprint = existingFingerprint;
    }

    final existingAnon = _prefs.anonymousId;
    if (existingAnon == null) {
      _anonymousId = _uuid.v4();
      _prefs.anonymousId = _anonymousId;
    } else {
      _anonymousId = existingAnon;
    }
  }

  static const _uuid = Uuid();

  final DyplinkPreferences _prefs;
  late final String _fingerprint;
  late String _anonymousId;

  String get fingerprint => _fingerprint;

  String get anonymousId => _anonymousId;

  String? get identifiedId => _prefs.identifiedId;

  set identifiedId(String? value) => _prefs.identifiedId = value;

  /// Current distinct ID — identified if set, otherwise anonymous.
  String get distinctId => identifiedId ?? _anonymousId;

  /// Resets the anonymous ID and clears any identified ID.
  /// Call this on user logout.
  void reset() {
    final newId = _uuid.v4();
    _prefs.anonymousId = newId;
    _prefs.identifiedId = null;
    _anonymousId = newId;
  }
}
