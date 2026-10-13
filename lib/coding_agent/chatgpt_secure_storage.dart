import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lastanswer/coding_agent/provider_configuration.dart';

/// Explicit OS-protected policy for the local desktop subscription seat.
/// The macOS app is ad-hoc signed and cannot use Data Protection access groups.
/// Use the login Keychain with its normal item access control instead. There is
/// no runtime fallback or credential search across keychain/service domains.
const chatGptPlatformStorage = FlutterSecureStorage(
  mOptions: MacOsOptions(
    accountName: 'dev.xsoulspace.lastAnswer.chatgpt',
    usesDataProtectionKeychain: false,
    // Pin local-only storage even if the plugin's default ever changes.
    // ignore: avoid_redundant_argument_values
    synchronizable: false,
  ),
);

SecureValueStore chatGptSecureValueStore() =>
    FlutterSecureValueStore(chatGptPlatformStorage);
