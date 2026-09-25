import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';

import '../../data_models/data_models.dart';
import '../interfaces/interfaces.dart';
import 'shared_preferences_keys.dart';

final class TagsLocalDataSourceImpl implements TagsLocalDataSource {
  TagsLocalDataSourceImpl({required this.localDb});
  final LocalDbI localDb;

  @override
  Future<void> putAll(
    final Map<ProjectTagModelId, ProjectTagModel> tags,
  ) async {
    await localDb.setMap(
      key: SharedPreferencesKeys.tags.name,
      value: tags.map(
        (final key, final value) => MapEntry(key.value, value.toJson()),
      ),
    );
  }

  @override
  Future<Map<ProjectTagModelId, ProjectTagModel>> getAll() async {
    final map = await localDb.getMap(SharedPreferencesKeys.tags.name);
    return map.map(
      (final key, final value) =>
          MapEntry(ProjectTagModelId(key), ProjectTagModel.fromJson(value)),
    );
  }
}
