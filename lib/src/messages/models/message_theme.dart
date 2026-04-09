class MessageTheme {
  const MessageTheme({
    this.backgroundColor,
    this.textColor,
    this.titleColor,
    this.buttonPrimaryColor,
    this.buttonSecondaryColor,
    this.overlayColor,
    this.borderRadius,
    this.animation,
  });

  final String? backgroundColor;
  final String? textColor;
  final String? titleColor;
  final String? buttonPrimaryColor;
  final String? buttonSecondaryColor;
  final String? overlayColor;
  final int? borderRadius;

  /// "fade" | "slide_up" | "slide_down" | "scale" | "none"
  final String? animation;

  factory MessageTheme.fromJson(Map<String, dynamic> json) => MessageTheme(
        backgroundColor: json['backgroundColor'] as String?,
        textColor: json['textColor'] as String?,
        titleColor: json['titleColor'] as String?,
        buttonPrimaryColor: json['buttonPrimaryColor'] as String?,
        buttonSecondaryColor: json['buttonSecondaryColor'] as String?,
        overlayColor: json['overlayColor'] as String?,
        borderRadius: (json['borderRadius'] as num?)?.toInt(),
        animation: json['animation'] as String?,
      );
}
