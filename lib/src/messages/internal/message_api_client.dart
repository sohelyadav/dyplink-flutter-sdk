import '../../internal/api_client.dart';
import '../models/in_app_message.dart';

/// Context passed to `POST /api/messages/check`.
class MessageCheckContext {
  const MessageCheckContext({
    this.screen,
    this.event,
    this.appVersion,
    this.sessionDuration,
    this.country,
    this.language,
  });

  final String? screen;
  final String? event;
  final String? appVersion;
  final int? sessionDuration;
  final String? country;
  final String? language;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'platform': 'flutter'};
    if (screen != null) map['screen'] = screen;
    if (event != null) map['event'] = event;
    if (appVersion != null) map['appVersion'] = appVersion;
    if (sessionDuration != null) map['sessionDuration'] = sessionDuration;
    if (country != null) map['country'] = country;
    if (language != null) map['language'] = language;
    return map;
  }
}

class MessageApiClient {
  MessageApiClient(this._apiClient);

  final ApiClient _apiClient;

  Future<List<InAppMessage>> checkMessages({
    required String projectId,
    required String deviceFingerprint,
    String? distinctId,
    required MessageCheckContext context,
  }) async {
    final body = <String, dynamic>{
      'projectId': projectId,
      'deviceFingerprint': deviceFingerprint,
      if (distinctId != null) 'distinctId': distinctId,
      'context': context.toJson(),
    };

    final json = await _apiClient.post('/api/messages/check', body);
    final rawList = json['messages'];
    if (rawList is! List) return const <InAppMessage>[];

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(InAppMessage.fromJson)
        .toList(growable: false);
  }

  Future<void> recordEvent({
    required String messageId,
    required String projectId,
    required String deviceFingerprint,
    String? distinctId,
    required String eventType,
    String? buttonId,
  }) async {
    final body = <String, dynamic>{
      'messageId': messageId,
      'projectId': projectId,
      'deviceFingerprint': deviceFingerprint,
      if (distinctId != null) 'distinctId': distinctId,
      'eventType': eventType,
      if (buttonId != null) 'buttonId': buttonId,
    };
    await _apiClient.post('/api/messages/event', body);
  }
}
