/// A mobile-money voucher provider supported by SendAfrica.
enum VoucherProvider {
  /// The Tanzania mobile-money provider exposed by the reference SDK.
  snippe('snippe');

  /// Creates a provider from its API wire value.
  const VoucherProvider(this.wireValue);

  /// The API wire representation.
  final String wireValue;

  /// Decodes a provider returned by the API.
  static VoucherProvider fromWire(String value) {
    return switch (value) {
      'snippe' => VoucherProvider.snippe,
      _ => throw FormatException('Unsupported voucher provider: $value'),
    };
  }
}

/// One top-up tier in the SendAfrica voucher pricing schedule.
final class VoucherRateTier {
  /// Creates a voucher pricing tier.
  const VoucherRateTier({
    required this.maxAmountTzs,
    required this.rateTzsPerCredit,
  });

  /// Decodes one pricing tier from the API response.
  factory VoucherRateTier.fromJson(Map<String, Object?> json) {
    return VoucherRateTier(
      maxAmountTzs: _requiredNum(json, 'max_amount_tzs'),
      rateTzsPerCredit: _requiredNum(json, 'rate_tzs_per_credit'),
    );
  }

  /// The inclusive upper TZS amount, or zero for the unbounded top tier.
  final num maxAmountTzs;

  /// The TZS price of one SMS credit in this tier.
  final num rateTzsPerCredit;

  /// Converts this tier to Dart's public property names.
  Map<String, Object?> toJson() => {
    'maxAmountTzs': maxAmountTzs,
    'rateTzsPerCredit': rateTzsPerCredit,
  };
}

/// The current voucher top-up minimum and pricing tiers.
final class VoucherRateResult {
  /// Creates a voucher-rate result.
  VoucherRateResult({
    required this.minAmountTzs,
    required List<VoucherRateTier> tiers,
  }) : tiers = List<VoucherRateTier>.unmodifiable(tiers);

  /// Decodes the API's voucher-rate response data.
  factory VoucherRateResult.fromJson(Map<String, Object?> json) {
    final Object? rawTiers = json['tiers'];
    if (rawTiers is! List<Object?>) {
      throw const FormatException('Expected a list for "tiers".');
    }

    return VoucherRateResult(
      minAmountTzs: _requiredNum(json, 'min_amount_tzs'),
      tiers: rawTiers.map(_tierFromJson).toList(growable: false),
    );
  }

  /// The minimum accepted top-up amount in TZS.
  final num minAmountTzs;

  /// The ordered pricing tiers.
  final List<VoucherRateTier> tiers;

  /// Converts this result to Dart's public property names.
  Map<String, Object?> toJson() => {
    'minAmountTzs': minAmountTzs,
    'tiers': tiers
        .map((VoucherRateTier tier) => tier.toJson())
        .toList(growable: false),
  };
}

/// Parameters for creating a mobile-money voucher top-up.
final class CreateVoucherParams {
  /// Creates voucher top-up parameters.
  const CreateVoucherParams({required this.provider, required this.amount});

  /// The mobile-money provider that processes the top-up.
  final VoucherProvider provider;

  /// The requested top-up amount in TZS.
  final num amount;

  /// Converts this request to the API's voucher request body.
  Map<String, Object?> toJson() => {
    'provider': provider.wireValue,
    'amount': amount,
  };
}

/// A voucher status that preserves both known and future API values.
final class VoucherStatus {
  /// Creates a voucher status from an API wire value.
  const VoucherStatus(this.wireValue);

  /// A mobile-money charge awaiting confirmation.
  static const VoucherStatus pending = VoucherStatus('pending');

  /// A confirmed voucher top-up.
  static const VoucherStatus confirmed = VoucherStatus('confirmed');

  /// A failed voucher top-up.
  static const VoucherStatus failed = VoucherStatus('failed');

  /// The API wire representation.
  final String wireValue;

  /// Preserves a status value received from the API.
  factory VoucherStatus.fromWire(String value) {
    return switch (value) {
      'pending' => pending,
      'confirmed' => confirmed,
      'failed' => failed,
      _ => VoucherStatus(value),
    };
  }

  @override
  bool operator ==(Object other) {
    return other is VoucherStatus && other.wireValue == wireValue;
  }

  @override
  int get hashCode => wireValue.hashCode;

  @override
  String toString() => wireValue;
}

/// A mobile-money voucher created for the account's verified phone number.
final class VoucherResult {
  /// Creates a voucher result.
  const VoucherResult({
    required this.id,
    required this.provider,
    required this.phone,
    required this.amount,
    required this.creditAmount,
    required this.currency,
    required this.status,
    required this.packageId,
    required this.createdAt,
  });

  /// Decodes the API's voucher response data.
  factory VoucherResult.fromJson(Map<String, Object?> json) {
    return VoucherResult(
      id: _requiredString(json, 'id'),
      provider: VoucherProvider.fromWire(_requiredString(json, 'provider')),
      phone: _requiredString(json, 'phone'),
      amount: _requiredNum(json, 'amount'),
      creditAmount: _requiredNum(json, 'credit_amount'),
      currency: _requiredString(json, 'currency'),
      status: VoucherStatus.fromWire(_requiredString(json, 'status')),
      packageId: _nullableString(json, 'package_id'),
      createdAt: _requiredString(json, 'created_at'),
    );
  }

  /// The voucher or top-up identifier.
  final String id;

  /// The provider that handles the mobile-money request.
  final VoucherProvider provider;

  /// The account's verified phone number that is charged.
  final String phone;

  /// The requested amount in TZS.
  final num amount;

  /// The number of credits to be added after confirmation.
  final num creditAmount;

  /// The currency returned by the API.
  final String currency;

  /// The current top-up status.
  final VoucherStatus status;

  /// The package identifier, when the API returns one.
  final String? packageId;

  /// The API creation timestamp.
  final String createdAt;

  /// Converts this result to Dart's public property names.
  Map<String, Object?> toJson() => {
    'id': id,
    'provider': provider.wireValue,
    'phone': phone,
    'amount': amount,
    'creditAmount': creditAmount,
    'currency': currency,
    'status': status.wireValue,
    'packageId': packageId,
    'createdAt': createdAt,
  };
}

VoucherRateTier _tierFromJson(Object? value) {
  if (value is Map<String, Object?>) return VoucherRateTier.fromJson(value);
  if (value is Map<String, dynamic>) return VoucherRateTier.fromJson(value);
  throw const FormatException('Expected each tier to be an object.');
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

num _requiredNum(Map<String, Object?> json, String key) {
  final Object? value = json[key];
  if (value is num) return value;
  throw FormatException('Expected a number for "$key".');
}
