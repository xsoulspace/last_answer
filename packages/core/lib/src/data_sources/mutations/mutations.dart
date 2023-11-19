// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, unused_field

import '../../../core.dart';
import '../local_hive/hive_db.dart';

enum LocalDbVersion {
  v3_16,
  v3_17;

  static const newestVersion = v3_17;
}

Future<void> runMutations(final GlobalStatesInitializerDto dto) async {
  final userNotifier = dto.userNotifier;
  if (userNotifier.isLoading) {
    throw ArgumentError.value('user is not loaded yet');
  }

  final currentLocalDbVersion = userNotifier.value.value.localDbVersion;
  // if (currentLocalDbVersion == LocalDbVersion.newestVersion) return;
  // try {
  await ComplexLocalDbHiveImpl().open();
  for (final v in LocalDbVersion.values) {
    switch (v) {
      case LocalDbVersion.v3_16:
        await _mutate_3_16_up_3_17(dto);
      case LocalDbVersion.v3_17:
      // noop
    }
  }
  // ignore: avoid_catches_without_on_clauses
  // } catch (e) {
  //   // ignore all errors as it should be called one time only
  //   debugPrint(e.toString());
  // }

  userNotifier.updateLocalDbVersion(LocalDbVersion.newestVersion);
}

Future<void> _mutate_3_16_up_3_17(final GlobalStatesInitializerDto dto) async {
  final hiveDataSource = ProjectsLocalDataSourceHiveImpl();
  final projectsResponse = await hiveDataSource.getProjects(
    dto: PaginatedPageRequestModel(),
  );
  final actualDataSource = dto.projectsRepository;
  await actualDataSource.putAll(projects: projectsResponse.values);
}
