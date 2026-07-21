#!/usr/bin/env bash

set -euo pipefail

dart format --output=none .
dart analyze --fatal-infos
dart test
dart pub publish --dry-run
