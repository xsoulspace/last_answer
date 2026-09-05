#!/bin/sh
# Phase 1.5 — bundle the AFM bridge dylib next to the executable.
#
# The loader (xsoulspace_inference_apple_foundation library_loader.dart)
# already resolves executable-relative paths, so a dylib copied into
# `<app>.app/Contents/MacOS/` needs no env var. XS_FM_BRIDGE_PATH stays as
# an override for power users (the loader prefers it).
#
# Resolution order:
#   1. $XS_FM_BRIDGE_PATH (explicit override)
#   2. the inference package's hook output (.dart_tool/lib/ — always fresh)
#   3. the inference package's build output (tool/build_bridge.sh)
#   4. build the dylib from bridge sources via tool/build_bridge.sh
# Failing the build (instead of shipping an app that cannot load AFM) is
# the honest behavior — the error names the fix.
set -e

NAME="libxs_fm_bridge.dylib"
DEST="$TARGET_BUILD_DIR/$PRODUCT_NAME.app/Contents/MacOS"
# SRCROOT is <repo>/macos. The inference monorepo is a SIBLING of the
# product repo: ../.. from SRCROOT. One level up is also probed in case
# the layout ever changes.
for ROOT in "$SRCROOT/../.." "$SRCROOT/.."; do
  if [ -d "$ROOT/dart_flutter_packages/pkgs/xsoulspace_inference_apple_foundation" ]; then
    PKG="$ROOT/dart_flutter_packages/pkgs/xsoulspace_inference_apple_foundation"
    break
  fi
done

echo "AFM bundle phase: SRCROOT=$SRCROOT"
echo "AFM bundle phase: PKG=${PKG:-<not found>}"

SRC=""
if [ -n "$XS_FM_BRIDGE_PATH" ] && [ -f "$XS_FM_BRIDGE_PATH" ]; then
  SRC="$XS_FM_BRIDGE_PATH"
elif [ -f "$PKG/.dart_tool/lib/$NAME" ]; then
  SRC="$PKG/.dart_tool/lib/$NAME"
elif [ -f "$PKG/build/$NAME" ]; then
  SRC="$PKG/build/$NAME"
elif [ -f "$PKG/tool/build_bridge.sh" ]; then
  (cd "$PKG" && sh tool/build_bridge.sh)
  SRC="$PKG/build/$NAME"
fi

if [ -z "$SRC" ] || [ ! -f "$SRC" ]; then
  echo "error: $NAME not found. Run sh tool/build_bridge.sh in" >&2
  echo "error: pkgs/xsoulspace_inference_apple_foundation (or set" >&2
  echo "error: XS_FM_BRIDGE_PATH)." >&2
  exit 1
fi

mkdir -p "$DEST"
cp -f "$SRC" "$DEST/$NAME"
codesign --force --sign - "$DEST/$NAME" 2>/dev/null || true
echo "Bundled $NAME from $SRC"
