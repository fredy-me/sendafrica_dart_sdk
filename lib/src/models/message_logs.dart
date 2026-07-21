/// A delivery status used by the SendAfrica message-log endpoint.
enum MessageStatus {
  /// The message was accepted for sending.
  sent('sent'),

  /// The carrier confirmed delivery.
  delivered('delivered'),

  /// The message could not be delivered.
  failed('failed');

  /// Creates a status from its API wire value.
  const MessageStatus(this.wireValue);

  /// The API wire representation.
  final String wireValue;

  /// Decodes a known message-log status.
  static MessageStatus fromWire(String value) {
    return switch (value) {
      'sent' => MessageStatus.sent,
      'delivered' => MessageStatus.delivered,
      'failed' => MessageStatus.failed,
      _ => throw FormatException('Unsupported message status: $value'),
    };
  }
}

/// One message record returned by the message-log endpoint.
final class MessageLogEntry {
  /// Creates a message-log entry.
  const MessageLogEntry({
    required this.id,
    required this.toPhone,
    required this.fromId,
    required this.message,
    required this.status,
    required this.smsParts,
    required this.creditsUsed,
    required this.sentAt,
    required this.deliveredAt,
    required this.createdAt,
  });

  /// Decodes one message-log object from the API response.
  factory MessageLogEntry.fromJson(Map<String, Object?> json) {
    return MessageLogEntry(
      id: _requiredString(json, 'id'),
      toPhone: _requiredString(json, 'to_phone'),
      fromId: _nullableString(json, 'from_id'),
      message: _requiredString(json, 'message'),
      status: MessageStatus.fromWire(_requiredString(json, 'status')),
      smsParts: _requiredInt(json, 'sms_parts'),
      creditsUsed: _requiredNum(json, 'credits_used'),
      sentAt: _requiredString(json, 'sent_at'),
      deliveredAt: _nullableString(json, 'delivered_at'),
      createdAt: _requiredString(json, 'created_at'),
    );
  }

  /// The server-assigned message identifier.
  final String id;

  /// The normalized recipient phone number.
  final String toPhone;

  /// The sender ID, when one was used.
  final String? fromId;

  /// The message body.
  final String message;

  /// The current delivery status.
  final MessageStatus status;

  /// The number of SMS segments used.
  final int smsParts;

  /// The credits consumed by this message.
  final num creditsUsed;

  /// The send timestamp.
  final String sentAt;

  /// The delivery-confirmation timestamp, when available.
  final String? deliveredAt;

  /// The record creation timestamp.
  final String createdAt;

  /// Converts this entry to Dart's public property names.
  Map<String, Object?> toJson() => {
    'id': id,
    'toPhone': toPhone,
    'fromId': fromId,
    'message': message,
    'status': status.wireValue,
    'smsParts': smsParts,
    'creditsUsed': creditsUsed,
    'sentAt': sentAt,
    'deliveredAt': deliveredAt,
    'createdAt': createdAt,
  };
}

/// Optional filters and pagination controls for message-log requests.
final class MessageLogsQuery {
  /// Creates message-log filters.
  const MessageLogsQuery({this.page, this.perPage, this.status});

  /// The one-indexed page number.
  final int? page;

  /// The maximum number of log items per page.
  final int? perPage;

  /// An optional delivery-status filter.
  final MessageStatus? status;

  /// Converts this query to the API's query-parameter names.
  Map<String, Object?> toJson() => {
    if (page != null) 'page': page,
    if (perPage != null) 'per_page': perPage,
    if (status != null) 'status': status!.wireValue,
  };
}

/// A paginated response from the message-log endpoint.
final class MessageLogsResult {
  /// Creates a message-log page.
  MessageLogsResult({
    required List<MessageLogEntry> items,
    required this.total,
    required this.page,
    required this.perPage,
    required this.totalPages,
  }) : items = List<MessageLogEntry>.unmodifiable(items);

  /// Decodes the API's message-log response data.
  factory MessageLogsResult.fromJson(Map<String, Object?> json) {
    final Object? rawItems = json['items'];
    if (rawItems is! List<Object?>) {
      throw const FormatException('Expected a list for "items".');
    }

    return MessageLogsResult(
      items: rawItems.map(_entryFromJson).toList(growable: false),
      total: _requiredInt(json, 'total'),
      page: _requiredInt(json, 'page'),
      perPage: _requiredInt(json, 'per_page'),
      totalPages: _requiredInt(json, 'total_pages'),
    );
  }

  /// The current page's log records.
  final List<MessageLogEntry> items;

  /// The total number of matching log records.
  final int total;

  /// The current one-indexed page.
  final int page;

  /// The number of log records requested per page.
  final int perPage;

  /// The number of available pages.
  final int totalPages;

  /// Converts this page to Dart's public property names.
  Map<String, Object?> toJson() => {
    'items': items
        .map((MessageLogEntry item) => item.toJson())
        .toList(growable: false),
    'total': total,
    'page': page,
    'perPage': perPage,
    'totalPages': totalPages,
  };
}

MessageLogEntry _entryFromJson(Object? value) {
  if (value is Map<String, Object?>) return MessageLogEntry.fromJson(value);
  if (value is Map<String, dynamic>) return MessageLogEntry.fromJson(value);
  throw const FormatException(
    'Expected each message-log item to be an object.',
  );
}

String _requiredString(Map<String, Object?> json, String key) {
  final Object? value = json[key];
  if (value is String) return value;
  throw FormatException('Expected a string for "$key".');
}

String? _nullableString(Map<String, Object?> json, String key) {
  final Object? value = json[key];
  if (value == null || value is String) return value as String?;
  throw FormatException('Expected a string or null for "$key".');
}

int _requiredInt(Map<String, Object?> json, String key) {
  final Object? value = json[key];
  if (value is int) return value;
  throw FormatException('Expected an integer for "$key".');
}

num _requiredNum(Map<String, Object?> json, String key) {
  final Object? value = json[key];
  if (value is num) return value;
  throw FormatException('Expected a number for "$key".');
}
