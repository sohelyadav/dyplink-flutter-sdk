import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../dyplink_config.dart';
import '../models/dyplink_error.dart';

/// Thin wrapper around [http.Client] that attaches the `X-API-Key`
/// header, JSON-encodes request bodies, and performs retries with
/// exponential back-off on 5xx responses and transient I/O errors.
class ApiClient {
  ApiClient(this._config, {http.Client? client})
      : _client = client ?? http.Client();

  final DyplinkConfig _config;
  final http.Client _client;

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('${_config.baseUrl}$endpoint');
    final jsonBody = jsonEncode(body);

    var attempt = 0;
    while (true) {
      attempt++;
      try {
        final response = await _client
            .post(
              url,
              headers: _headers(),
              body: jsonBody,
            )
            .timeout(const Duration(seconds: 15));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          if (response.body.isEmpty) return <String, dynamic>{};
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) return decoded;
          return <String, dynamic>{'data': decoded};
        }

        if (response.statusCode >= 500 && attempt <= _config.maxRetries) {
          await _backoff(attempt);
          continue;
        }

        throw ApiError(
          message: 'POST $endpoint failed with ${response.statusCode}',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      } on TimeoutException {
        if (attempt > _config.maxRetries) {
          throw const NetworkError('Request timed out');
        }
        await _backoff(attempt);
      } on SocketException {
        if (attempt > _config.maxRetries) {
          throw const NetworkError('Network unreachable');
        }
        await _backoff(attempt);
      }
    }
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse('${_config.baseUrl}$endpoint')
        .replace(queryParameters: queryParams);
    final response =
        await _client.get(uri, headers: _headers()).timeout(const Duration(seconds: 15));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return <String, dynamic>{};
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return <String, dynamic>{'data': decoded};
    }
    throw ApiError(
      message: 'GET $endpoint failed with ${response.statusCode}',
      statusCode: response.statusCode,
      responseBody: response.body,
    );
  }

  Map<String, String> _headers() => <String, String>{
        'Content-Type': 'application/json',
        'X-API-Key': _config.apiKey,
      };

  Future<void> _backoff(int attempt) {
    final ms = 250 * (1 << (attempt - 1));
    return Future<void>.delayed(Duration(milliseconds: ms));
  }

  void close() => _client.close();
}
