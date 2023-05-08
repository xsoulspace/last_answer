// ignore_for_file: do_not_use_environment

import 'package:flutter/foundation.dart';

@immutable
class _Envs {
  const _Envs._prod() : dbUrl = const String.fromEnvironment('db-url');
  const _Envs._dev() : dbUrl = 'https://';
  final String dbUrl;
}

@immutable
class Envs {
  const Envs._();
  static const instance = kDebugMode ? _Envs._dev() : _Envs._prod();
}
