# Parsers README

This folder contains TDD-first parsers for Hive and Isar database files.

## AES integration

- For AES-256 decryption of Hive values we recommend using `aes_crypt_null_safe`.
- The `byte_utils.decryptAes256Cbc` function is a clear integration point; replace
  the UnimplementedError with a call into `AesCrypt` helpers.

## Streaming and isolates

- For large files, use `File.openRead()` and parse pages/frames incrementally.
- Run heavy parsing in an `Isolate.spawn` to avoid blocking the UI in Flutter.

Example (isolate worker):

```dart
// Spawn an isolate with a SendPort that sends back parsed JSON.
```
