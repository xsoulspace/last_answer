#!/usr/bin/env bash
set -euo pipefail
package_root="$(cd "$(dirname "$0")/.." && pwd)"
test_build="$(mktemp -d "${TMPDIR:-/tmp}/lastanswer-keychain-os.XXXXXX")"
trap 'rm -rf "$test_build"' EXIT
xcrun swiftc \
  "$package_root/darwin/flutter_secure_storage_darwin/Sources/flutter_secure_storage_darwin/AtomicKeychainWriter.swift" \
  "$package_root/test/native/AtomicKeychainOSControl.swift" \
  -framework Security -o "$test_build/atomic-keychain-os"
"$test_build/atomic-keychain-os"
