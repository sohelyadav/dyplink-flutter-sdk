import 'package:shared_preferences/shared_preferences.dart';

/// Typed wrapper around [SharedPreferences] holding SDK-scoped state.
class DyplinkPreferences {
  DyplinkPreferences._(this._prefs);

  static const _kFingerprint = 'dyplink_fingerprint';
  static const _kIdentifiedId = 'dyplink_identified_id';
  static const _kAnonymousId = 'dyplink_anonymous_id';
  static const _kDeferredMatchAttempted = 'dyplink_deferred_match_attempted';
  static const _kDeferredMatchResult = 'dyplink_deferred_match_result';
  static const _kAttributedShortCode = 'dyplink_attributed_short_code';
  static const _kAttributedLinkId = 'dyplink_attributed_link_id';
  static const _kLastSessionStart = 'dyplink_last_session_start';

  final SharedPreferences _prefs;

  static Future<DyplinkPreferences> create() async {
    final prefs = await SharedPreferences.getInstance();
    return DyplinkPreferences._(prefs);
  }

  String? get fingerprint => _prefs.getString(_kFingerprint);
  set fingerprint(String? value) => _setOrRemove(_kFingerprint, value);

  String? get identifiedId => _prefs.getString(_kIdentifiedId);
  set identifiedId(String? value) => _setOrRemove(_kIdentifiedId, value);

  String? get anonymousId => _prefs.getString(_kAnonymousId);
  set anonymousId(String? value) => _setOrRemove(_kAnonymousId, value);

  bool get deferredMatchAttempted =>
      _prefs.getBool(_kDeferredMatchAttempted) ?? false;
  set deferredMatchAttempted(bool value) =>
      _prefs.setBool(_kDeferredMatchAttempted, value);

  String? get deferredMatchResult => _prefs.getString(_kDeferredMatchResult);
  set deferredMatchResult(String? value) =>
      _setOrRemove(_kDeferredMatchResult, value);

  String? get attributedShortCode => _prefs.getString(_kAttributedShortCode);
  set attributedShortCode(String? value) =>
      _setOrRemove(_kAttributedShortCode, value);

  String? get attributedLinkId => _prefs.getString(_kAttributedLinkId);
  set attributedLinkId(String? value) =>
      _setOrRemove(_kAttributedLinkId, value);

  int? get lastSessionStart => _prefs.getInt(_kLastSessionStart);
  set lastSessionStart(int? value) {
    if (value == null) {
      _prefs.remove(_kLastSessionStart);
    } else {
      _prefs.setInt(_kLastSessionStart, value);
    }
  }

  void _setOrRemove(String key, String? value) {
    if (value == null) {
      _prefs.remove(key);
    } else {
      _prefs.setString(key, value);
    }
  }
}
