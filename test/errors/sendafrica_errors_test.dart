import 'package:sendafrica_dart_sdk/sendafrica_dart_sdk.dart';
import 'package:test/test.dart';

void main() {
  group('SendAfricaError', () {
    test('preserves API metadata and classifies known error codes', () {
      final SendAfricaError error = SendAfricaError.fromPayload(
        const SendAfricaErrorPayload(
          code: 'insufficient_credits',
          message: 'Not enough credits',
          requestId: 'req-1',
          httpStatus: 402,
        ),
      );

      expect(error.code, 'insufficient_credits');
      expect(error.message, 'Not enough credits');
      expect(error.requestId, 'req-1');
      expect(error.httpStatus, 402);
      expect(error.isInsufficientCredits, isTrue);
      expect(error.isRateLimited, isFalse);
      expect(error.isUnauthorized, isFalse);
      expect(error.toString(), '[insufficient_credits] Not enough credits');
    });

    test('classifies rate limiting and authorization independently', () {
      const SendAfricaError rateLimited = SendAfricaError(
        code: 'rate_limit_exceeded',
        message: 'Slow down',
      );
      const SendAfricaError unauthorized = SendAfricaError(
        code: 'unauthorized',
        message: 'Invalid key',
      );

      expect(rateLimited.isRateLimited, isTrue);
      expect(unauthorized.isUnauthorized, isTrue);
    });
  });

  test('network errors retain their cause', () {
    final StateError cause = StateError('socket closed');
    final SendAfricaNetworkError error = SendAfricaNetworkError(
      'Request failed',
      cause,
    );

    expect(error.message, 'Request failed');
    expect(error.cause, same(cause));
    expect(error.toString(), 'Request failed');
  });

  test('invalid phone errors preserve the rejected input', () {
    const InvalidPhoneNumberError error = InvalidPhoneNumberError(
      '+254712345678',
    );

    expect(error.input, '+254712345678');
    expect(error.toString(), contains('valid Tanzania mobile number'));
  });
}
