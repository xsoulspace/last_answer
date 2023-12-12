import 'package:shared_models/shared_models.dart';

import '../../../core.dart';

final class ProjectsLocalDataSourceLocalDbImpl
    implements ProjectsLocalDataSource {
  ProjectsLocalDataSourceLocalDbImpl({
    required this.localDb,
  });
  final LocalDbDataSource localDb;
  final List<ProjectModel> _cache = [];
  @override
  Future<PaginatedPageResponseModel<ProjectModel>> getProjects({
    required final PaginatedPageRequestModel<RequestProjectsDto> dto,
  }) async {
    final getDto = dto.data;
    final int itemsCount;

    itemsCount = _cache.length;
    final pagesCount = (itemsCount / dto.limit).ceil();
    final start = dto.page * dto.limit;
    final items = _cache.skip(start).take(dto.limit);

    return PaginatedPageResponseModel(
      values: items.toList(),
      currentPage: dto.page,
      pagesCount: pagesCount,
    );
  }

  @override
  Future<void> put({required final ProjectModel project}) async {
    _cache.insert(0, project);
  }

  @override
  Future<void> remove({required final ProjectModelId id}) async {
    _cache.removeWhere((final e) => e.id == id);
  }

  @override
  Future<void> putAll({required final List<ProjectModel> projects}) async {
    _cache
      ..clear()
      ..addAll(projects);
  }
}
