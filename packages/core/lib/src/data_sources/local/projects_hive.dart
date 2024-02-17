import 'package:hive/hive.dart';
import 'package:shared_models/shared_models.dart';

import '../../../core.dart';

/// use for data migrations only
// ignore: unused_element
Future<Box<T>> _openAnyway<T>(final String boxName) async {
  try {
    await Hive.openBox<T>(boxName);
    // ignore: avoid_catches_without_on_clauses
  } catch (e) {
    await Hive.deleteBoxFromDisk(boxName);
  }

  return Hive.openBox<T>(boxName);
}

@Deprecated('use only for migrations. It was used in <=v3.16')
final class ProjectsLocalDataSourceHiveImpl implements ProjectsLocalDataSource {
  @Deprecated('use only for migrations. It was used in <=v3.16')
  ProjectsLocalDataSourceHiveImpl();

  @override
  Future<PaginatedPageResponseModel<ProjectModel>> getProjects({
    required final PaginatedPageRequestModel<RequestProjectsDto> dto,
  }) async {
    await _openAnyway<IdeaProjectAnswer>(HiveBoxesIds.ideaProjectAnswerKey);
    await _openAnyway<IdeaProjectQuestion>(HiveBoxesIds.ideaProjectQuestionKey);
    final ideas = await _openAnyway<IdeaProject>(HiveBoxesIds.ideaProjectKey);
    final notes = await _openAnyway<NoteProject>(HiveBoxesIds.noteProjectKey);
    final notesModels = notes.values.map((final e) => e.toModel()).toList();
    final ideasModels = ideas.values.map((final e) => e.toModel()).toList();
    final response = PaginatedPageResponseModel(
      currentPage: 1,
      pagesCount: 1,
      values: [...notesModels, ...ideasModels],
    );
    // TODO(arenukvern): description,
    // await Hive.deleteFromDisk();
    return response;
  }

  @override
  Future<void> put({required final ProjectModel project}) async =>
      throw UnsupportedError('');

  @override
  Future<void> remove({required final ProjectModelId id}) async =>
      throw UnsupportedError('');

  @override
  Future<void> putAll({required final List<ProjectModel> projects}) async =>
      throw UnsupportedError('');

  @override
  Future<List<ProjectModel>> getAll() {
    throw UnsupportedError('');
  }
}
