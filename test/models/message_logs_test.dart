import 'package:sendafrica_dart_sdk/sendafrica_dart_sdk.dart';
import 'package:test/test.dart';

void main() {
  test('decodes paginated message logs from API field names', () {
    final MessageLogsResult result = MessageLogsResult.fromJson(
      <String, Object?>{
        'items': <Object?>[
          <String, Object?>{
            'id': 'msg-1',
            'to_phone': '+255712345678',
            'from_id': null,
            'message': 'Hello',
            'status': 'delivered',
            'sms_parts': 1,
            'credits_used': 1,
            'sent_at': '2026-06-11T16:24:05Z',
            'delivered_at': '2026-06-11T16:24:08Z',
            'created_at': '2026-06-11T16:24:05Z',
          },
        ],
        'total': 1,
        'page': 1,
        'per_page': 25,
        'total_pages': 1,
      },
    );

    expect(result.items.single.status, MessageStatus.delivered);
    expect(result.items.single.toPhone, '+255712345678');
    expect(result.perPage, 25);
    expect(() => result.items.clear(), throwsUnsupportedError);
  });

  test('serializes optional message-log filters using wire names', () {
    const MessageLogsQuery query = MessageLogsQuery(
      page: 2,
      perPage: 10,
      status: MessageStatus.failed,
    );

    expect(query.toJson(), {'page': 2, 'per_page': 10, 'status': 'failed'});
  });

  test('rejects unsupported message statuses', () {
    expect(
      () => MessageStatus.fromWire('queued'),
      throwsA(isA<FormatException>()),
    );
  });
}
