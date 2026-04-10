import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';

import 'dyplink_error.dart';
import 'pigeon.g.dart' as pg;

/// Optional push notification module for the Dyplink SDK.
///
/// Call [init] after [Dyplink.init] to enable automatic FCM push token
/// management. This module wraps the native Dyplink Push module, which in
/// turn wraps Firebase Messaging.
///
/// Usage:
/// ```dart
/// await Dyplink.instance.init(config);
/// await DyplinkPush.instance.init();
///
/// // Listen for FCM token updates (if any emit).
/// DyplinkPush.instance.tokens.listen((token) => print('new token: $token'));
/// ```
class DyplinkPush {
  DyplinkPush._();
  static final DyplinkPush instance = DyplinkPush._();

  // ignore: public_member_api_docs
  pg.DyplinkPushHostApi hostApi = pg.DyplinkPushHostApi();

  StreamController<String>? _tokenController;
  StreamSubscription<Object?>? _tokenSub;

  static const EventChannel _tokenChannel =
      EventChannel('com.dyplink.dyplink/push_tokens');

  /// Initialize the push module. Requires Dyplink.init() to have been called.
  Future<void> init() {
    _ensureSupported();
    return runCatchingDyplink(hostApi.initialize);
  }

  /// Whether the push module has been initialized.
  Future<bool> get isInitialized =>
      _supported ? runCatchingDyplink(hostApi.isInitialized) : Future.value(false);

  /// Whether an FCM token is currently registered with the Dyplink backend.
  Future<bool> get isRegistered =>
      _supported ? runCatchingDyplink(hostApi.isRegistered) : Future.value(false);

  /// Manually register an FCM token.
  Future<void> registerToken(String token) {
    _ensureSupported();
    return runCatchingDyplink(() => hostApi.registerToken(token));
  }

  /// Unregister the current FCM token. Call on user logout.
  Future<void> unregisterToken() {
    _ensureSupported();
    return runCatchingDyplink(hostApi.unregisterToken);
  }

  /// Broadcast stream of FCM token updates.
  ///
  /// Note: the current native SDK does not yet emit token-refresh events
  /// on this channel — subscribing is safe but may not yield values until
  /// the underlying SDK exposes a refresh hook.
  Stream<String> get tokens {
    _ensureSupported();
    _tokenController ??= StreamController<String>.broadcast(
      onListen: _onTokenListen,
      onCancel: _onTokenCancel,
    );
    return _tokenController!.stream;
  }

  Future<void> _onTokenListen() async {
    try {
      await hostApi.startTokenStream();
    } on PlatformException {
      // No-op.
    }
    _tokenSub = _tokenChannel.receiveBroadcastStream().listen(
      (event) {
        if (event is String) _tokenController?.add(event);
      },
      onError: (Object err) {
        _tokenController?.addError(err);
      },
    );
  }

  Future<void> _onTokenCancel() async {
    await _tokenSub?.cancel();
    _tokenSub = null;
    try {
      await hostApi.stopTokenStream();
    } on PlatformException {
      // No-op.
    }
  }

  static bool get _supported => Platform.isAndroid;

  void _ensureSupported() {
    if (!_supported) {
      throw UnsupportedError(
        'DyplinkPush currently only supports Android. iOS support is coming soon.',
      );
    }
  }
}
