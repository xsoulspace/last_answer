import '../../../core.dart';

final class TagsLocalDataSourceImpl implements TagsLocalDataSource {
  TagsLocalDataSourceImpl({
    required this.localDb,
  });
  final LocalDbDataSource localDb;

  @override
  void putAll(
    final Map<ProjectTagModelId, ProjectTagModel> tags,
  ) {
    localDb.setMap(
      key: SharedPreferencesKeys.tags.name,
      value: tags
          .map((final key, final value) => MapEntry(key.value, value.toJson())),
    );
  }

  @override
  Map<ProjectTagModelId, ProjectTagModel> getAll() {
    final map = localDb.getMap(SharedPreferencesKeys.tags.name);
    return map.map(
      (final key, final value) =>
          MapEntry(ProjectTagModelId(key), ProjectTagModel.fromJson(value)),
    );
  }
}
