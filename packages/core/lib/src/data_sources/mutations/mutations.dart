// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, unused_field

import 'package:flutter/widgets.dart';

import '../../../core.dart';

Future<bool> runMutations(final GlobalStatesInitializerDto dto) async {
  final userNotifier = dto.userNotifier;
  if (userNotifier.isLoading) {
    throw ArgumentError.value('user is not loaded yet');
  }

  final currentLocalDbVersion = userNotifier.value.value.localDbVersion;
  if (currentLocalDbVersion == LocalDbVersion.newestVersion) return false;
  try {
    for (final v in LocalDbVersion.values) {
      switch (v) {
        case LocalDbVersion.v4:
        // noop
      }
    }
    // ignore: avoid_catches_without_on_clauses
  } catch (e) {
    // ignore all errors as it should be called one time only
    debugPrint(e.toString());
  }

  userNotifier.updateLocalDbVersion(LocalDbVersion.newestVersion);
  return true;
}
