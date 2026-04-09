import 'dart:async';

import 'package:flutter/material.dart';

import '../dyplink.dart';
import '../models/dyplink_error.dart';
import 'internal/message_api_client.dart';
import 'models/in_app_message.dart';
import 'models/message_button.dart';
import 'widgets/in_app_message_dialog.dart';

/// Listener for in-app message interactions.
abstract class MessageListener {
  /// Fired when a message event happens (impression / click / dismiss etc.).
  void onMessageEvent(InAppMessage message, String eventType, String? buttonId) {}

  /// Fired when a CTA button is tapped.
  void onButtonAction(InAppMessage message, MessageButton button) {}

  /// Fired when a button with `action == "custom_event"` is tapped.
  void onCustomEvent(InAppMessage message, String eventName) {}
}

/// Entry point for Dyplink in-app messages.
///
/// Requires [Dyplink.instance.init] to have been called first.
class DyplinkMessages {
  DyplinkMessages._();

  static final DyplinkMessages instance = DyplinkMessages._();

  MessageApiClient? _client;
  MessageListener? _listener;

  MessageApiClient get _api {
    return _client ??= MessageApiClient(Dyplink.instance.internalApiClient);
  }

  /// Sets (or clears) the listener that receives message callbacks.
  void setMessageListener(MessageListener? listener) {
    _listener = listener;
  }

  // ── Trigger points ─────────────────────────────────────────────

  /// Call from your root widget's `initState` or `didChangeDependencies`.
  /// Checks for `on_app_open` and `scheduled` messages.
  Future<void> onAppOpen(BuildContext context) {
    return _checkAndShow(context, const MessageCheckContext());
  }

  /// Call when the user navigates to a new screen.
  Future<void> onScreenView(BuildContext context, String screen) {
    return _checkAndShow(context, MessageCheckContext(screen: screen));
  }

  /// Call when a custom event fires (e.g. `"purchase_complete"`).
  Future<void> onEvent(BuildContext context, String event) {
    return _checkAndShow(context, MessageCheckContext(event: event));
  }

  // ── Internal ───────────────────────────────────────────────────

  Future<void> _checkAndShow(
    BuildContext context,
    MessageCheckContext checkContext,
  ) async {
    if (!Dyplink.instance.isInitialized) {
      throw const NotInitializedError();
    }

    try {
      final messages = await _api.checkMessages(
        projectId: Dyplink.instance.config.projectId,
        deviceFingerprint: Dyplink.instance.deviceFingerprint,
        distinctId: Dyplink.instance.distinctId,
        context: checkContext,
      );

      for (final message in messages) {
        if (!context.mounted) return;
        if (message.triggerDelay > 0) {
          await Future<void>.delayed(Duration(seconds: message.triggerDelay));
        }
        if (!context.mounted) return;
        await _display(context, message);
      }
    } on DyplinkError {
      // never crash the host app on a message check failure
    }
  }

  Future<void> _display(BuildContext context, InAppMessage message) async {
    final dialog = InAppMessageDialog(
      context: context,
      message: message,
      onEvent: (eventType, buttonId) {
        _recordEvent(message.id, eventType, buttonId);
        _listener?.onMessageEvent(message, eventType, buttonId);
      },
      onButtonAction: (button) {
        _recordEvent(message.id, 'cta_click', button.id);
        _listener?.onButtonAction(message, button);
        _handleButtonAction(message, button);
      },
    );
    await dialog.show();
  }

  void _handleButtonAction(InAppMessage message, MessageButton button) {
    if (button.action == 'custom_event' && button.actionEvent != null) {
      _listener?.onCustomEvent(message, button.actionEvent!);
    }
    // URL / deep-link handling is left to the host app via
    // [onButtonAction] — the SDK does not bundle a URL launcher.
  }

  void _recordEvent(String messageId, String eventType, String? buttonId) {
    unawaited(
      _api.recordEvent(
        messageId: messageId,
        projectId: Dyplink.instance.config.projectId,
        deviceFingerprint: Dyplink.instance.deviceFingerprint,
        distinctId: Dyplink.instance.distinctId,
        eventType: eventType,
        buttonId: buttonId,
      ).catchError((_) {
        // fire-and-forget
      }),
    );
  }
}
