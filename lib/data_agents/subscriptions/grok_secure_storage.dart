import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lastanswer/data_agents/config/provider_configuration.dart';

/// Login Keychain for the Grok subscription seat. Separate from the ChatGPT
/// service. Ad-hoc macOS signing cannot use a Data Protection access group.
const grokPlatformStorage = FlutterSecureStorage(
  mOptions: MacOsOptions(
    accountName: 'dev.xsoulspace.lastAnswer.grok',
    usesDataProtectionKeychain: false,
    // ignore: avoid_redundant_argument_values
    synchronizable: false,
  ),
);

SecureValueStore grokSecureValueStore() =>
    FlutterSecureValueStore(grokPlatformStorage);
