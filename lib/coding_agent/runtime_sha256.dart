import 'dart:ffi';
import 'dart:io';

import 'package:crypto/crypto.dart' as dart_crypto;

/// Computes complete SHA-256 bytes using macOS's system CommonCrypto.
/// Only hashing CPU work changes. Callers still read and check every file.
String runtimeSha256(List<int> bytes) {
  if (!Platform.isMacOS) {
    return dart_crypto.sha256.convert(bytes).toString();
  }
  if (bytes.length > 0xffffffff) {
    throw StateError('meaning_runtime_digest_input_too_large');
  }
  return _CommonCrypto.instance.digest(bytes);
}

final class _CommonCrypto {
  _CommonCrypto() {
    final system = DynamicLibrary.open('/usr/lib/libSystem.B.dylib');
    final crypto = DynamicLibrary.open('/usr/lib/system/libcommonCrypto.dylib');
    allocate = system
        .lookupFunction<
          Pointer<Void> Function(UintPtr),
          Pointer<Void> Function(int)
        >('malloc');
    release = system
        .lookupFunction<
          Void Function(Pointer<Void>),
          void Function(Pointer<Void>)
        >('free');
    // CommonDigest.h: CC_LONG is uint32_t; CC_SHA256 emits exactly 32 bytes.
    hash = crypto
        .lookupFunction<
          Pointer<Uint8> Function(Pointer<Void>, Uint32, Pointer<Uint8>),
          Pointer<Uint8> Function(Pointer<Void>, int, Pointer<Uint8>)
        >('CC_SHA256');
  }

  static final instance = _CommonCrypto();
  late final Pointer<Void> Function(int) allocate;
  late final void Function(Pointer<Void>) release;
  late final Pointer<Uint8> Function(Pointer<Void>, int, Pointer<Uint8>) hash;

  String digest(List<int> bytes) {
    final input = allocate(bytes.isEmpty ? 1 : bytes.length);
    final output = allocate(32);
    try {
      if (input == nullptr || output == nullptr) {
        throw StateError('meaning_runtime_digest_allocation_failed');
      }
      input.cast<Uint8>().asTypedList(bytes.length).setAll(0, bytes);
      final digest = output.cast<Uint8>();
      if (hash(input, bytes.length, digest) == nullptr) {
        throw StateError('meaning_runtime_digest_failed');
      }
      return digest
          .asTypedList(32)
          .map((value) => value.toRadixString(16).padLeft(2, '0'))
          .join();
    } finally {
      if (input != nullptr) release(input);
      if (output != nullptr) release(output);
    }
  }
}
