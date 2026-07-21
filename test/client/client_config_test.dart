import 'package:http/testing.dart';
import 'package:sendafrica_dart_sdk/sendafrica_dart_sdk.dart';
import 'package:test/test.dart';

void main() {
  group('SendAfricaClientConfig', () {
    test('uses the reference SDK defaults', () {
      final SendAfricaClientConfig config = SendAfricaClientConfig(
        apiKey: 'SA-test',
      );

      expect(config.apiKey, 'SA-test');
      expect(config.baseUrl, 'https://api.sendafrica.online');
      expect(config.timeout, const Duration(seconds: 15));
      expect(config.maxRetries, 2);
      expect(config.httpClient, isNull);
    });

    test(
      'removes trailing base-URL slashes and retains an injected client',
      () {
        final MockClient injectedClient = MockClient(
          (_) async => throw UnimplementedError(),
        );
        final SendAfricaClientConfig config = SendAfricaClientConfig(
          apiKey: 'SA-test',
          baseUrl: 'https://staging.sendafrica.test///',
          timeout: const Duration(seconds: 3),
          maxRetries: 0,
          httpClient: injectedClient,
        );

        expect(config.baseUrl, 'https://staging.sendafrica.test');
        expect(config.timeout, const Duration(seconds: 3));
        expect(config.maxRetries, 0);
        expect(config.httpClient, same(injectedClient));
      },
    );

    test('rejects an empty API key like the reference client', () {
      expect(
        () => SendAfricaClientConfig(apiKey: ''),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
