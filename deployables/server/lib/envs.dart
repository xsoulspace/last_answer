// ignore_for_file: do_not_use_environment

import 'package:serverpod/serverpod.dart';

class Envs {
  Envs._();
  static const androidPackageId = 'dev.xsoulspace.lastanswer';
  static const appStoreIssuerId = 'App Store Key issuer ID';
  static const appStoreKeyId = 'App Store Key ID';
  static const appStoreSharedSecret = 'App Store shared secret';
  static const bundleId = 'your iOS bundle ID';
  static const googlePlayProjectName = 'Google Cloud project name';
  static const googlePlayPubsubBillingTopic = 'play_billing';
  static const telegramWebAppUrl = 'https://xsoulspace.dev/last_answer';
  static final telegramBotToken =
      Serverpod.instance.getPassword('telegramBotToken') ?? '';
}
