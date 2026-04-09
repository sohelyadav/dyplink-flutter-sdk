import 'message_button.dart';
import 'message_theme.dart';

/// A resolved in-app message ready to be displayed.
///
/// Mirrors the `DeliveredMessage` shape returned by the platform's
/// `POST /api/messages/check` endpoint.
class InAppMessage {
  const InAppMessage({
    required this.id,
    required this.messageType,
    required this.title,
    required this.imagePosition,
    required this.dismissOnTapOutside,
    required this.triggerDelay,
    this.body,
    this.imageUrl,
    this.buttons,
    this.theme,
    this.autoDismissSeconds,
  });

  final String id;

  /// "modal" | "bottom_sheet" | "banner_top" | "banner_bottom" | "fullscreen"
  final String messageType;

  final String title;
  final String? body;
  final String? imageUrl;

  /// "top" | "center" | "background"
  final String imagePosition;

  final List<MessageButton>? buttons;
  final MessageTheme? theme;
  final bool dismissOnTapOutside;

  /// Seconds before auto-dismiss. `null` means no auto-dismiss.
  final int? autoDismissSeconds;

  /// Delay in seconds before showing the message after the trigger.
  final int triggerDelay;

  factory InAppMessage.fromJson(Map<String, dynamic> json) {
    List<MessageButton>? buttons;
    final rawButtons = json['buttons'];
    if (rawButtons is List && rawButtons.isNotEmpty) {
      buttons = rawButtons
          .whereType<Map<String, dynamic>>()
          .map(MessageButton.fromJson)
          .toList(growable: false);
    }

    return InAppMessage(
      id: json['id'] as String,
      messageType: json['messageType'] as String? ?? 'modal',
      title: json['title'] as String? ?? '',
      body: json['body'] as String?,
      imageUrl: json['imageUrl'] as String?,
      imagePosition: json['imagePosition'] as String? ?? 'top',
      buttons: buttons,
      theme: json['theme'] is Map<String, dynamic>
          ? MessageTheme.fromJson(json['theme'] as Map<String, dynamic>)
          : null,
      dismissOnTapOutside: json['dismissOnTapOutside'] as bool? ?? true,
      autoDismissSeconds: (json['autoDismissSeconds'] as num?)?.toInt(),
      triggerDelay: (json['triggerDelay'] as num?)?.toInt() ?? 0,
    );
  }
}
