import 'dart:async';

import 'package:flutter/material.dart';

import '../models/in_app_message.dart';
import '../models/message_button.dart';

typedef MessageEventCallback = void Function(String eventType, String? buttonId);
typedef MessageButtonCallback = void Function(MessageButton button);

/// Displays an [InAppMessage] using the appropriate Flutter surface
/// for its `messageType` (dialog, bottom sheet, or banner overlay).
class InAppMessageDialog {
  InAppMessageDialog({
    required this.context,
    required this.message,
    required this.onEvent,
    required this.onButtonAction,
  });

  final BuildContext context;
  final InAppMessage message;
  final MessageEventCallback onEvent;
  final MessageButtonCallback onButtonAction;

  Timer? _autoDismissTimer;
  bool _dismissed = false;

  Future<void> show() async {
    switch (message.messageType) {
      case 'bottom_sheet':
        await _showBottomSheet();
      case 'banner_top':
      case 'banner_bottom':
        await _showBanner();
      case 'fullscreen':
      case 'modal':
      default:
        await _showModal();
    }
  }

  // ── Modal ───────────────────────────────────────────────────────

  Future<void> _showModal() async {
    onEvent('impression', null);
    _scheduleAutoDismiss();

    await showDialog<void>(
      context: context,
      barrierDismissible: message.dismissOnTapOutside,
      builder: (dialogContext) => Dialog(
        backgroundColor: _parseColor(message.theme?.backgroundColor, Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            (message.theme?.borderRadius ?? 12).toDouble(),
          ),
        ),
        child: _buildContent(dialogContext, maxHeight: 480),
      ),
    );

    _onDialogClosed();
  }

  // ── Bottom Sheet ────────────────────────────────────────────────

  Future<void> _showBottomSheet() async {
    onEvent('impression', null);
    _scheduleAutoDismiss();

    await showModalBottomSheet<void>(
      context: context,
      isDismissible: message.dismissOnTapOutside,
      enableDrag: message.dismissOnTapOutside,
      backgroundColor: _parseColor(message.theme?.backgroundColor, Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            (message.theme?.borderRadius ?? 16).toDouble(),
          ),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: _buildContent(sheetContext, maxHeight: 400),
      ),
    );

    _onDialogClosed();
  }

  // ── Banner ──────────────────────────────────────────────────────

  Future<void> _showBanner() async {
    onEvent('impression', null);
    final bannerDuration =
        Duration(seconds: message.autoDismissSeconds ?? 4);
    final alignment = message.messageType == 'banner_top'
        ? Alignment.topCenter
        : Alignment.bottomCenter;

    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (overlayContext) => SafeArea(
        child: Align(
          alignment: alignment,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _parseColor(message.theme?.backgroundColor, Colors.white),
                borderRadius: BorderRadius.circular(
                  (message.theme?.borderRadius ?? 12).toDouble(),
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              child: _buildContent(overlayContext, maxHeight: 160, compact: true),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);

    _autoDismissTimer = Timer(bannerDuration, () {
      if (_dismissed) return;
      onEvent('auto_dismiss', null);
      _dismissed = true;
      entry.remove();
    });
  }

  // ── Content ─────────────────────────────────────────────────────

  Widget _buildContent(
    BuildContext ctx, {
    required double maxHeight,
    bool compact = false,
  }) {
    final theme = message.theme;
    final titleColor = _parseColor(theme?.titleColor, Colors.black87);
    final textColor = _parseColor(theme?.textColor, Colors.black54);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (message.imageUrl != null && message.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  message.imageUrl!,
                  height: compact ? 80 : 160,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            if (message.title.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                message.title,
                style: TextStyle(
                  fontSize: compact ? 14 : 18,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
            ],
            if (message.body != null && message.body!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    message.body!,
                    style: TextStyle(fontSize: 14, color: textColor),
                  ),
                ),
              ),
            ],
            if (message.buttons != null) ...[
              const SizedBox(height: 12),
              ...message.buttons!.map((btn) => Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: _buildButton(ctx, btn),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext ctx, MessageButton btn) {
    final primaryColor =
        _parseColor(message.theme?.buttonPrimaryColor, const Color(0xFF1976D2));
    final secondaryColor =
        _parseColor(message.theme?.buttonSecondaryColor, Colors.grey.shade300);

    void onPressed() {
      onButtonAction(btn);
      if (btn.action != 'custom_event') {
        _closeActive(ctx);
      }
    }

    switch (btn.style) {
      case 'text':
        return TextButton(onPressed: onPressed, child: Text(btn.text));
      case 'secondary':
        return OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: secondaryColor,
          ),
          onPressed: onPressed,
          child: Text(btn.text),
        );
      case 'primary':
      default:
        return FilledButton(
          style: FilledButton.styleFrom(backgroundColor: primaryColor),
          onPressed: onPressed,
          child: Text(btn.text),
        );
    }
  }

  // ── Dismissal plumbing ──────────────────────────────────────────

  void _scheduleAutoDismiss() {
    final secs = message.autoDismissSeconds;
    if (secs == null || secs <= 0) return;
    _autoDismissTimer = Timer(Duration(seconds: secs), () {
      if (_dismissed) return;
      onEvent('auto_dismiss', null);
      _closeActive(context);
    });
  }

  void _onDialogClosed() {
    _autoDismissTimer?.cancel();
    if (_dismissed) return;
    _dismissed = true;
    onEvent('dismiss', null);
  }

  void _closeActive(BuildContext ctx) {
    if (Navigator.canPop(ctx)) {
      Navigator.of(ctx, rootNavigator: true).pop();
    }
  }

  Color _parseColor(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    var sanitized = hex.replaceFirst('#', '');
    if (sanitized.length == 6) sanitized = 'FF$sanitized';
    final value = int.tryParse(sanitized, radix: 16);
    return value == null ? fallback : Color(value);
  }
}
