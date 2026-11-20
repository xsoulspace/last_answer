import '../project_models.dart';

abstract interface class TagsLocalDataSource {
  Future<Map<ProjectTagModelId, ProjectTagModel>> getAll();
  Future<void> putAll(final Map<ProjectTagModelId, ProjectTagModel> map);
}
