import 'package:sendafrica_dart_sdk/sendafrica_dart_sdk.dart';
import 'package:test/test.dart';

void main() {
  test('decodes voucher pricing tiers from API field names', () {
    final VoucherRateResult rate = VoucherRateResult.fromJson(<String, Object?>{
      'min_amount_tzs': 1000,
      'tiers': <Object?>[
        <String, Object?>{'max_amount_tzs': 50000, 'rate_tzs_per_credit': 25},
        <String, Object?>{'max_amount_tzs': 0, 'rate_tzs_per_credit': 20},
      ],
    });

    expect(rate.minAmountTzs, 1000);
    expect(rate.tiers, hasLength(2));
    expect(rate.tiers.first.maxAmountTzs, 50000);
    expect(rate.tiers.last.rateTzsPerCredit, 20);
    expect(
      () => rate.tiers.add(
        const VoucherRateTier(maxAmountTzs: 1, rateTzsPerCredit: 1),
      ),
      throwsUnsupportedError,
    );
  });

  test('serializes only the supported voucher provider', () {
    const CreateVoucherParams params = CreateVoucherParams(
      provider: VoucherProvider.snippe,
      amount: 50000,
    );

    expect(params.toJson(), {'provider': 'snippe', 'amount': 50000});
    expect(VoucherProvider.fromWire('snippe'), VoucherProvider.snippe);
  });

  test('preserves future voucher status values', () {
    final VoucherResult result = VoucherResult.fromJson(<String, Object?>{
      'id': 'voucher-1',
      'provider': 'snippe',
      'phone': '+255712345678',
      'amount': 50000,
      'credit_amount': 2000,
      'currency': 'TZS',
      'status': 'processing',
      'package_id': null,
      'created_at': '2026-06-11T16:24:05Z',
    });

    expect(result.status, const VoucherStatus('processing'));
    expect(result.packageId, isNull);
    expect(result.toJson()['creditAmount'], 2000);
  });
}
