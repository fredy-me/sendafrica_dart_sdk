# SendAfrica Dart SDK

The Dart implementation of the SendAfrica Tanzania SMS API SDK.

This package follows the architecture and behavior of the
[SendAfrica TypeScript SDK](https://github.com/SendAfrica/SendAfrica-typescript-sdk),
while using idiomatic Dart package conventions.

## Development status

Phase 1—the package foundation—is complete. The public client API, request
models, validation, and transport behavior are implemented in subsequent
phases. This pre-release package must not yet be used to send production SMS.

## Development checks

Run the complete local verification suite from the repository root:

```bash
./tool/verify.sh
```

The verification suite checks formatting, static analysis, tests, and pub
package readiness without publishing anything.

## Reference and scope

The TypeScript SDK is the product behavior authority. The Dart implementation
will include SMS sending, credit management, vouchers, message logs, Tanzania
phone normalization, SMS segment estimation, typed errors, and retry behavior.
See [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) for the controlled
implementation roadmap.

## License

MIT. See [LICENSE](LICENSE).
