#!/bin/sh
set -eu
SDK="$FLUTTER_ROOT/bin/cache/dart-sdk"
PRODUCT_ROOT="$SRCROOT/.."
DEST="$TARGET_BUILD_DIR/$PRODUCT_NAME.app/Contents/Resources/meaning_runtime"
LOCK="$PRODUCT_ROOT/assets/meaning_greeting/pubspec.lock"
cd "$PRODUCT_ROOT"
"$SDK/bin/dart" --packages="$PRODUCT_ROOT/.dart_tool/package_config.json" \
  "$PRODUCT_ROOT/tool/bundle_meaning_runtime.dart" "$SDK" "$DEST" "$LOCK"
