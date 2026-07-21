/// Parameters for one outbound SMS message.
final class SendSmsParams {
  /// Creates outbound SMS parameters.
  const SendSmsParams({required this.to, required this.message, this.from});

  /// The recipient phone number in a supported local or international format.
  final String to;

  /// The SMS body text.
  final String message;

  /// An optional approved sender ID.
  final String? from;

  /// Converts this request to the API's SMS request body.
  Map<String, Object?> toJson() => {
    'to': to,
    'message': message,
    if (from != null) 'from': from,
  };
}

/// Options that control the handling of one outbound SMS request.
final class SendSmsOptions {
  /// Creates SMS request options.
  const SendSmsOptions({
    this.idempotencyKey,
    this.skipPhoneNormalization = false,
  });

  /// A stable key for safely retrying the same logical message.
  final String? idempotencyKey;

  /// Whether to send the recipient number without local normalization.
  final bool skipPhoneNormalization;
}

/// The only successful status returned by the send-SMS endpoint.
enum SendSmsStatus {
  /// The message was accepted for sending.
  sent('sent');

  /// Creates a status from its API wire value.
  const SendSmsStatus(this.wireValue);

  /// The API wire representation.
  final String wireValue;

  /// Decodes the API's status wire value.
  static SendSmsStatus fromWire(String value) {
    return switch (value) {
      'sent' => SendSmsStatus.sent,
      _ => throw FormatException('Unsupported send-SMS status: $value'),
    };
  }
}

/// The normalized result returned after a successful SMS request.
final class SendSmsResult {
  /// Creates a successful SMS result.
  const SendSmsResult({
    required this.messageId,
    required this.status,
    required this.cost,
    required this.creditsUsed,
    required this.requestId,
    required this.timestamp,
  });

  /// Decodes the API response data plus envelope tracing fields.
  factory SendSmsResult.fromJson(
    Map<String, Object?> json, {
    required String requestId,
    required String timestamp,
  }) {
    return SendSmsResult(
      messageId: _requiredString(json, 'message_id'),
      status: SendSmsStatus.fromWire(_requiredString(json, 'status')),
      cost: _requiredString(json, 'cost'),
      creditsUsed: _requiredNum(json, 'credits_used'),
      requestId: requestId,
      timestamp: timestamp,
    );
  }

  /// The server-assigned message identifier.
  final String messageId;

  /// The accepted send status.
  final SendSmsStatus status;

  /// The carrier cost string returned by the API.
  final String cost;

  /// The number of credits consumed.
  final num creditsUsed;

  /// The API request identifier used for tracing.
  final String requestId;

  /// The timestamp returned in the API envelope.
  final String timestamp;

  /// Converts this result to Dart's public property names.
  Map<String, Object?> toJson() => {
    'messageId': messageId,
    'status': status.wireValue,
    'cost': cost,
    'creditsUsed': creditsUsed,
    'requestId': requestId,
    'timestamp': timestamp,
  };
}

String _requiredString(Map<String, Object?> json, String key) {
  final Object? value = json[key];
  if (value is String) return value;
  throw FormatException('Expected a string for "$key".');
}

num _requiredNum(Map<String, Object?> json, String key) {
  final Object? value = json[key];
  if (value is num) return value;
  throw FormatException('Expected a number for "$key".');
}
