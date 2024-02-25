import '../../data_models/data_models.dart';

abstract interface class TagsLocalDataSource {
  Map<ProjectTagModelId, ProjectTagModel> getAll();
  void putAll(final Map<ProjectTagModelId, ProjectTagModel> map);
}
