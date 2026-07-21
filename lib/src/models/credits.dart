/// The SMS credit balance for one SendAfrica account.
final class BalanceResult {
  /// Creates a credit-balance result.
  const BalanceResult({required this.accountId, required this.balance});

  /// Decodes the API's balance response data.
  factory BalanceResult.fromJson(Map<String, Object?> json) {
    return BalanceResult(
      accountId: _requiredString(json, 'account_id'),
      balance: _requiredNum(json, 'balance'),
    );
  }

  /// The SendAfrica account identifier.
  final String accountId;

  /// The currently available SMS credits.
  final num balance;

  /// Converts this result to Dart's public property names.
  Map<String, Object?> toJson() => {'accountId': accountId, 'balance': balance};
}

/// Optional pagination controls for credit-history requests.
final class CreditHistoryQuery {
  /// Creates credit-history pagination controls.
  const CreditHistoryQuery({this.page, this.perPage});

  /// The one-indexed page number.
  final int? page;

  /// The maximum number of results per page.
  final int? perPage;

  /// Converts this query to the API's query-parameter names.
  Map<String, Object?> toJson() => {
    if (page != null) 'page': page,
    if (perPage != null) 'per_page': perPage,
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
