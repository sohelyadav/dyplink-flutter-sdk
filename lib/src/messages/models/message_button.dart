class MessageButton {
  const MessageButton({
    required this.id,
    required this.text,
    required this.action,
    required this.style,
    this.actionUrl,
    this.actionEvent,
  });

  final String id;
  final String text;

  /// "dismiss" | "deep_link" | "url" | "custom_event"
  final String action;

  /// "primary" | "secondary" | "text"
  final String style;

  final String? actionUrl;
  final String? actionEvent;

  factory MessageButton.fromJson(Map<String, dynamic> json) => MessageButton(
        id: json['id'] as String? ?? '',
        text: json['text'] as String? ?? '',
        action: json['action'] as String? ?? 'dismiss',
        style: json['style'] as String? ?? 'primary',
        actionUrl: json['actionUrl'] as String?,
        actionEvent: json['actionEvent'] as String?,
      );
}
