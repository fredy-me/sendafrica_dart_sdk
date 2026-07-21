import 'package:sendafrica_dart_sdk/sendafrica_dart_sdk.dart';
import 'package:test/test.dart';

void main() {
  group('SMS models', () {
    test('serializes optional sender IDs only when supplied', () {
      const SendSmsParams withoutSender = SendSmsParams(
        to: '0712345678',
        message: 'Hello',
      );
      const SendSmsParams withSender = SendSmsParams(
        to: '0712345678',
        message: 'Hello',
        from: 'MyBrand',
      );

      expect(withoutSender.toJson(), {'to': '0712345678', 'message': 'Hello'});
      expect(withSender.toJson(), {
        'to': '0712345678',
        'message': 'Hello',
        'from': 'MyBrand',
      });
    });

    test('decodes a successful send result and envelope fields', () {
      final SendSmsResult result = SendSmsResult.fromJson(
        <String, Object?>{
          'message_id': 'abc123',
          'status': 'sent',
          'cost': 'KES 1.00',
          'credits_used': 1,
        },
        requestId: 'req-1',
        timestamp: '2026-06-11T16:24:05Z',
      );

      expect(result.messageId, 'abc123');
      expect(result.status, SendSmsStatus.sent);
      expect(result.creditsUsed, 1);
      expect(result.toJson()['requestId'], 'req-1');
    });

    test('rejects an unknown successful send status', () {
      expect(
        () => SendSmsStatus.fromWire('queued'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('credit models', () {
    test('decodes account balance from API field names', () {
      final BalanceResult result = BalanceResult.fromJson(<String, Object?>{
        'account_id': 'acc-1',
        'balance': 5000,
      });

      expect(result.accountId, 'acc-1');
      expect(result.balance, 5000);
      expect(result.toJson(), {'accountId': 'acc-1', 'balance': 5000});
    });

    test('omits absent credit-history pagination fields', () {
      const CreditHistoryQuery empty = CreditHistoryQuery();
      const CreditHistoryQuery paged = CreditHistoryQuery(page: 2, perPage: 25);

      expect(empty.toJson(), isEmpty);
      expect(paged.toJson(), {'page': 2, 'per_page': 25});
    });
  });
}
