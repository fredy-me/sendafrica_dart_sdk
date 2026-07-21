import 'package:http/http.dart' as http;

/// Immutable configuration shared by all SendAfrica client requests.
final class SendAfricaClientConfig {
  /// Creates client configuration with the TypeScript SDK's default values.
  SendAfricaClientConfig({
    required this.apiKey,
    String baseUrl = defaultBaseUrl,
    this.timeout = defaultTimeout,
    this.maxRetries = defaultMaxRetries,
    this.httpClient,
  }) : baseUrl = baseUrl.replaceFirst(RegExp(r'/+$'), '') {
    if (apiKey.isEmpty) {
      throw ArgumentError.value(apiKey, 'apiKey', 'must not be empty');
    }
  }

  /// The default SendAfrica API origin.
  static const String defaultBaseUrl = 'https://api.sendafrica.online';

  /// The default per-attempt request timeout.
  static const Duration defaultTimeout = Duration(seconds: 15);

  /// The default number of retries after an initial failed request.
  static const int defaultMaxRetries = 2;

  /// The SendAfrica API key used by API-key-authenticated endpoints.
  final String apiKey;

  /// The API origin without trailing slashes.
  final String baseUrl;

  /// The maximum duration for one HTTP request attempt.
  final Duration timeout;

  /// The number of retry attempts after the first request.
  final int maxRetries;

  /// An optional caller-owned HTTP client for production configuration or tests.
  final http.Client? httpClient;
}
