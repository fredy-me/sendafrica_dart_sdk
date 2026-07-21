/// The error payload returned by a failed SendAfrica API response.
final class SendAfricaErrorPayload {
  /// Creates an API error payload.
  const SendAfricaErrorPayload({
    required this.code,
    required this.message,
    this.requestId,
    this.httpStatus,
  });

  /// The API's machine-readable error code.
  final String code;

  /// The API's human-readable explanation.
  final String message;

  /// The API request identifier, when returned.
  final String? requestId;

  /// The HTTP response status, when available.
  final int? httpStatus;
}

/// Thrown when the SendAfrica API returns an unsuccessful response envelope.
final class SendAfricaError implements Exception {
  /// Creates an API error from the API response fields.
  const SendAfricaError({
    required this.code,
    required this.message,
    this.requestId,
    this.httpStatus,
  });

  /// Creates an API error from a decoded response payload.
  SendAfricaError.fromPayload(SendAfricaErrorPayload payload)
    : code = payload.code,
      message = payload.message,
      requestId = payload.requestId,
      httpStatus = payload.httpStatus;

  /// The API's machine-readable error code.
  final String code;

  /// The API's human-readable error message.
  final String message;

  /// The request identifier returned by the API, when available.
  final String? requestId;

  /// The HTTP status code returned by the API, when available.
  final int? httpStatus;

  /// Whether the API reports that the account has insufficient credits.
  bool get isInsufficientCredits => code == 'insufficient_credits';

  /// Whether the API reports that the client exceeded a rate limit.
  bool get isRateLimited => code == 'rate_limit_exceeded';

  /// Whether the API reports missing, invalid, or revoked credentials.
  bool get isUnauthorized => code == 'unauthorized';

  @override
  String toString() => '[$code] $message';
}

/// Thrown for transport failures, timeouts, or non-JSON API responses.
final class SendAfricaNetworkError implements Exception {
  /// Creates a network or protocol error.
  const SendAfricaNetworkError(this.message, [this.cause]);

  /// A description of the failed operation.
  final String message;

  /// The underlying transport or parsing error, when available.
  final Object? cause;

  @override
  String toString() => message;
}

/// Thrown when a recipient is not a valid Tanzania mobile phone number.
final class InvalidPhoneNumberError implements Exception {
  /// Creates an error for [input], which could not be normalized locally.
  const InvalidPhoneNumberError(this.input);

  /// The original phone-number input.
  final String input;

  @override
  String toString() {
    return '"$input" is not a valid Tanzania mobile number. '
        'Expected local (07XXXXXXXX), +255XXXXXXXXX, or 255XXXXXXXXX '
        'format with a valid prefix (071–078).';
  }
}
