# SendAfrica Dart SDK — Implementation Plan

## 1. Purpose and authority

This is the single implementation, delivery, and release-readiness record for
the Dart SDK. Its objective is a production-grade Dart translation of the
reference implementation:

- Reference repository: `https://github.com/SendAfrica/SendAfrica-typescript-sdk`
- Reference revision inspected: local clone made on 2026-07-21
- Dart package: `sendafrica_dart_sdk`

The TypeScript repository is the product and behavior authority. Dart may use
idiomatic language constructs, but it must not add, remove, or reinterpret
public features without an approved reference-parity decision.

### Authority order

1. Executable TypeScript source and tests — endpoint behavior, headers,
   transforms, retries, errors, and edge cases.
2. TypeScript public exports and `types.ts` — the public SDK contract.
3. TypeScript README — installation, examples, user guidance, and release
   documentation.
4. This plan — Dart structure, delivery sequence, acceptance criteria, and
   status.
5. Dart code, tests, README, and changelog — the current Dart implementation.

When the reference source and README differ, preserve source/test behavior,
record the discrepancy in the parity register, and align Dart documentation to
the behavior that is actually shipped.

## 2. Product contract to reproduce

The Dart SDK exposes one configured client plus local, side-effect-free
utilities. Network methods are asynchronous and all methods return typed Dart
objects except credit history, which remains untyped until the API schema is
stable.

### 2.1 Public client API

`SendAfricaClient` must provide:

| Method | HTTP contract | Result |
|---|---|---|
| `sendSms(params, options)` | `POST /v1/sms/`, API key; normalize recipient by default; optional idempotency header | `SendSmsResult` |
| `getBalance()` | `GET /v1/credits/balance`, API key | `BalanceResult` |
| `getVoucherRate()` | `GET /v1/vouchers/rate`, API key | `VoucherRateResult` |
| `createVoucher(params, options)` | `POST /v1/vouchers/`, API key; optional idempotency header | `VoucherResult` |
| `getCreditHistory(query)` | `GET /v1/credits/history`, API key; `page` and `per_page` query parameters | raw decoded response |
| `getMessageLogs(jwtToken, query)` | `GET /v1/sms/logs`, Bearer JWT only; optional `page`, `per_page`, `status` | `MessageLogsResult` |

Client configuration must mirror the reference intent:

- required API key;
- default base URL `https://api.sendafrica.online`, with trailing slashes
  removed;
- default timeout of 15 seconds;
- default maximum of two retries, with zero disabling retries;
- injectable HTTP transport for deterministic tests and non-default runtimes.

### 2.2 Local public utilities

- `normalizeTzPhone` and `isValidTzPhone` normalize valid Tanzania mobile
  numbers to `+255XXXXXXXXX`, accepting local, `+255`, and `255` forms;
  whitespace, hyphens, parentheses, and dots are ignored.
- Valid local prefixes are `071` through `078`; invalid input must fail before
  a network call.
- `detectEncoding`, `getSmsPartInfo`, and `countSmsParts` implement GSM-7 and
  UCS-2 estimation. GSM-7 uses 160/153 character limits and UCS-2 uses 70/67.
  Dart `String.length` must be used deliberately so surrogate pairs match the
  TypeScript implementation's UTF-16 length behavior.

### 2.3 Errors, transport, and reliability

- `SendAfricaError`: API envelope with `code`, API message, optional request
  ID, optional HTTP status, plus insufficient-credit, rate-limit, and
  unauthorized classification helpers.
- `SendAfricaNetworkError`: connection failures, timeouts, and non-JSON
  responses after retry exhaustion; retain the underlying cause where Dart
  permits it.
- `InvalidPhoneNumberError`: local validation failure.
- Parse the reference envelope: `success`, `data`, `error`, `request_id`, and
  `timestamp`.
- Retry API `429` and any `5xx` response, plus transport failures, using
  `min(1000 * 2^(attempt - 1), 8000) + random(0..250)` milliseconds.
- Per-attempt timeout and cancellation must not leak timers, streams, or HTTP
  clients.
- Never send `X-API-Key` for `getMessageLogs`; it uses only
  `Authorization: Bearer <JWT>`.

## 3. Target package structure

```
lib/
├── sendafrica_dart_sdk.dart          # Only supported public exports
└── src/
    ├── client/
    │   ├── sendafrica_client.dart    # Public client and endpoint methods
    │   ├── client_config.dart        # Immutable configuration and defaults
    │   ├── transport.dart            # Injectable transport abstraction
    │   └── retry_policy.dart         # Retry eligibility and backoff
    ├── errors/
    │   └── sendafrica_errors.dart    # Three public error types
    ├── models/
    │   ├── sms.dart                  # Send SMS params/options/result
    │   ├── credits.dart               # Balance/history query
    │   ├── vouchers.dart              # Rate and top-up models
    │   └── message_logs.dart          # Log/filter/pagination models
    ├── utilities/
    │   ├── phone.dart                # Tanzania phone rules
    │   └── sms_parts.dart             # Encoding and segments
    └── internal/
        ├── api_envelope.dart          # JSON-envelope parsing only
        └── query_parameters.dart      # Omit null query values
test/
├── client/
│   ├── sendafrica_client_test.dart
│   └── retry_and_timeout_test.dart
├── utilities/
│   ├── phone_test.dart
│   └── sms_parts_test.dart
├── models/                            # JSON mappings and enum/value objects
└── support/
    └── fake_transport.dart
example/
└── sendafrica_dart_sdk_example.dart
```

Public imports must remain restricted to `package:sendafrica_dart_sdk/sendafrica_dart_sdk.dart`.
Files under `lib/src` are implementation detail even where their classes are
re-exported from the package barrel.

## 4. Delivery roadmap

| Phase | Scope | Completion gate | Status |
|---|---|---|---|
| 0. Contract lock | Create the parity matrix from TypeScript source, types, README, and tests; record known source/docs differences. | Every TypeScript public export, endpoint, model field, error, and tested edge case has a Dart destination. | Complete |
| 1. Package foundation | Replace the generated template metadata and exports; select and pin minimal Dart dependencies; add static analysis, formatting, test, and publish checks. | `dart analyze`, `dart format --output=none`, and tests run on a clean checkout. | Complete |
| 2. Value types and errors | Implement immutable request/result models, JSON mappings, enums/value objects, configuration, and error hierarchy. | Model/error unit tests cover all reference fields and classifications. | In progress |
| 3. Local utilities | Implement phone normalization/validation and GSM-7/UCS-2 segmentation. | Reference phone and SMS-part test vectors pass, including a 71-emoji UTF-16 case. | Pending |
| 4. Transport core | Add injected transport, JSON envelope parsing, timeout, query serialization, API-key/JWT header isolation, retry policy, and safe body handling. | Deterministic fake-transport tests prove success, API errors, 429/5xx/network retries, timeout, non-JSON response, and retry exhaustion. | Pending |
| 5. Resource methods | Implement all six client methods and response transformations. | Endpoint-by-endpoint contract tests prove URL, verb, body, headers, query string, and return mapping. | Pending |
| 6. Public developer experience | Complete DartDoc, README, examples, API/error/retry guidance, changelog, license/package metadata, and migration/parity notes. | `dart doc` succeeds and every README code sample is exercised or compilation-checked. | Pending |
| 7. Release hardening | Run the complete quality suite, package dry run, compatibility checks, semantic-version review, and publish checklist. | All release evidence is recorded in this document and no public API is unintentionally exposed. | Pending |

Phases are sequential. A phase may not be marked complete merely because code
exists; its completion gate and all earlier gates must be satisfied.

## 5. Implementation rules

### 5.1 Parity rules

- Map every TypeScript public export to exactly one Dart public export, an
  intentionally documented omission, or an approved Dart equivalent.
- Preserve API JSON wire names in private decoding code; expose idiomatic Dart
  lower-camel-case properties to users.
- Do not create bulk-campaign support: the reference intentionally leaves it
  to the SendAfrica dashboard.
- Do not add automatic environment-variable API-key lookup: the reference
  requires explicit configuration.
- Keep credit history as a decoded dynamic/JSON value until an authoritative
  API response schema is available.
- Preserve `snippe` as the currently supported voucher provider.

### 5.2 Dart-specific choices

- Use immutable classes with explicit `fromJson`/`toJson` boundaries. Avoid
  runtime reflection.
- Use an injected `http.Client`-backed transport (or equivalent narrow
  abstraction), allowing fake transports in unit tests. Client ownership and
  disposal must be documented to avoid closing caller-owned resources.
- Use `Duration` in Dart's public configuration rather than milliseconds,
  while preserving the 15-second default.
- Use `Random` behind an injectable retry-delay/random abstraction in tests so
  retry assertions never sleep for real time.
- Keep the package Flutter-independent; it must run in Dart VM, Flutter,
  server, CLI, and web-supported environments permitted by its HTTP layer.

### 5.3 API boundary rules

- Validate the API key is non-empty at construction time.
- Serialize POST bodies as JSON and set `Content-Type: application/json`.
- Trim trailing base-URL slashes once at construction time.
- Omit null query values; use `per_page` at the HTTP boundary and `perPage` in
  Dart models.
- Normalize a recipient before the request unless `skipPhoneNormalization` is
  true.
- Attach `Idempotency-Key` only when the caller provides one.
- Treat an invalid JSON response as a network/protocol error, not an API error.

## 6. Required test matrix

The Dart tests must reproduce the reference suite before adding broader tests.

| Area | Minimum cases |
|---|---|
| Phone | local, `+255`, `255`, spaces, hyphens, other-country rejection, invalid prefix, garbage input, boolean validity helper |
| SMS parts | ASCII/GSM-7, emoji/UCS-2, Arabic/UCS-2, one-part limits, multi-part GSM-7, multi-part UCS-2, surrogate-pair emoji length |
| Send SMS | normalized payload, exact URL and API-key header, result mapping, optional sender, skipped normalization, idempotency header |
| API errors | API envelope to `SendAfricaError`, code and HTTP metadata, classification helpers |
| Reliability | 429 then success, representative 5xx then success, transport failure then success, retries disabled, exhaustion, timeout, malformed JSON |
| Auth isolation | message logs use Bearer token and omit API key; all other endpoints use the API key |
| Resources | balance, voucher rate mapping, voucher creation, credit-history query, message-log filters/pagination and snake_case-to-camelCase mapping |
| Public API | package-barrel imports compile; no private implementation path is required by examples |

No test may call the live production API. Real integration tests, if later
authorized, must use a dedicated non-production credential and be separately
labelled.

## 7. Documentation and release requirements

- Replace the generated README completely with install, requirements,
  quickstart, configuration, all methods, utilities, errors, retries,
  idempotency, authentication distinction, limitations, and examples.
- Keep the example app/package a runnable, minimal client example and never
  include a real key.
- Populate `pubspec.yaml` description, repository, homepage/issue tracker,
  topics, license, and version deliberately; do not inherit placeholder
  metadata.
- Maintain `CHANGELOG.md` in Keep a Changelog style and use semantic versioning.
- Publish only after `dart format --output=none .`, `dart analyze`, `dart test`,
  documentation checks, and `dart pub publish --dry-run` pass.
- Verify supported Dart SDK constraints against the chosen HTTP dependency and
  document them in the README.

## 8. Parity register and controlled decisions

### 8.1 TypeScript-to-Dart implementation matrix

| TypeScript source | Reference public responsibility | Dart destination | Phase |
|---|---|---|---|
| `src/index.ts` | Single supported package import and exports | `lib/sendafrica_dart_sdk.dart` | 1, then 2–5 |
| `src/client.ts` | Configuration, HTTP lifecycle, all resource methods, retry, query serialization | `lib/src/client/` and `lib/src/internal/` | 2, 4, 5 |
| `src/types.ts` | Request, result, query, status, and voucher value types | `lib/src/models/` | 2 |
| `src/errors.ts` | API, network, and phone-validation errors | `lib/src/errors/sendafrica_errors.dart` | 2 |
| `src/phone.ts` | Tanzania phone normalization, prefix list, validity helper | `lib/src/utilities/phone.dart` | 3 |
| `src/sms-parts.ts` | Encoding detection and SMS segment/credit estimate | `lib/src/utilities/sms_parts.dart` | 3 |
| `test/client.test.ts` | HTTP, retry, authentication-isolation, and preflight-validation proof | `test/client/` plus `test/support/fake_transport.dart` | 4, 5 |
| `test/phone.test.ts` | Phone normalization vectors | `test/utilities/phone_test.dart` | 3 |
| `test/sms-parts.test.ts` | GSM-7/UCS-2 and UTF-16 segmentation vectors | `test/utilities/sms_parts_test.dart` | 3 |
| `package.json` | Package metadata and build/test/release commands | `pubspec.yaml`, `tool/verify.sh`, `.github/workflows/ci.yml` | 1 |
| `README.md` | User documentation and product guidance | `README.md` and `example/` | 1 foundation, 6 complete docs |

| Item | Reference evidence | Dart decision | State |
|---|---|---|---|
| Retry status set | README lists selected 5xx values; `client.ts` retries `429` and any status `>= 500`. | Follow executable behavior: 429 plus all 5xx. | Locked |
| Trace headers | README describes `User-Agent` and a generated `X-Request-Id`; `client.ts` currently does not add either. | Do not add them in the initial parity release; document only verified behavior. | Locked |
| Package identity | README calls the SDK official; `package.json` calls it unofficial and has placeholder repository metadata. | Use approved Dart package metadata; do not copy stale identity/repository values. | Pending owner metadata |
| Credit history schema | Public method returns raw API data. | Preserve raw decoded response until an authoritative schema is supplied. | Locked |
| Voucher provider | Public type supports only `snippe`. | Expose only `snippe`; future providers need a reference change first. | Locked |

## 9. Change-control protocol

Before any implementation change, update the phase status and identify its
reference source files. Before any public API change, update the parity
register, model/API matrix, tests, README, example, changelog, and version in
one reviewable change.

A feature not present in the reference is out of scope unless the owner
explicitly approves it. A reference update triggers a comparison of its public
exports, types, endpoint paths, headers, tests, and README before Dart work
begins.

## 10. Current baseline and next action

Phase 1 is complete. The Dart package now has an intentional public entry
point, package/repository metadata, a minimal multi-platform HTTP dependency,
MIT license, strict analysis settings, CI, a local verification script, and a
non-template README/changelog. It deliberately exposes no SDK operations yet;
those belong to the later behavior phases.

**Next implementation action:** Phase 2 — implement immutable value types,
configuration, and the typed error hierarchy from the locked parity matrix.
