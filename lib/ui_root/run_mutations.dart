// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, unused_field

import 'package:flutter/widgets.dart';
import 'package:lastanswer/data_projects/data_projects.dart';
import 'package:lastanswer/data_projects/migrations/migrate_from_hive_isar.dart';
import 'package:lastanswer/data_user/data_user.dart';
import 'package:lastanswer/ui_root/global_states_initializer.dart';

Future<bool> runMutations(final GlobalStatesInitializerDto dto) async {
  final userNotifier = dto.userNotifier;
  if (userNotifier.isLoading) {
    throw ArgumentError.value('user is not loaded yet');
  }

  final currentLocalDbVersion = userNotifier.value.value.localDbVersion;
  if (currentLocalDbVersion == LocalDbVersion.newestVersion) return false;
  try {
    await migrateFromHiveAndIsar(dto.context);
    // for (final v in LocalDbVersion.values) {
    // noop
    // }
    // ignore: avoid_catches_without_on_clauses
  } catch (e) {
    // ignore all errors as it should be called one time only
    debugPrint(e.toString());
  }

  userNotifier.updateLocalDbVersion(LocalDbVersion.newestVersion);
  return true;
}
