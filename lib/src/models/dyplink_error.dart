/// Errors raised by the Dyplink SDK.
sealed class DyplinkError implements Exception {
  const DyplinkError(this.message);
  final String message;

  @override
  String toString() => 'DyplinkError: $message';
}

/// Thrown when an SDK call is made before [Dyplink.init].
class NotInitializedError extends DyplinkError {
  const NotInitializedError()
      : super('Dyplink.instance.init() must be called before using the SDK');
}

/// Thrown when the backend returns a non-success HTTP status.
class ApiError extends DyplinkError {
  const ApiError({
    required String message,
    required this.statusCode,
    this.responseBody,
  }) : super(message);

  final int statusCode;
  final String? responseBody;

  @override
  String toString() =>
      'ApiError($statusCode): $message${responseBody != null ? ' — $responseBody' : ''}';
}

/// Thrown when the network is unreachable or a request times out.
class NetworkError extends DyplinkError {
  const NetworkError(super.message);
}
