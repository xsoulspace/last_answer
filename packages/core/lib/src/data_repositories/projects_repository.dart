import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_models/shared_models.dart';

import '../../core.dart';

class ProjectsRepository {
  ProjectsRepository(final BuildContext context)
      : _datasource = kIsWeb
            ? ProjectsLocalDataSourceLocalDbImpl(localDb: context.read())
            : ProjectsLocalDataSourceIsarImpl(isarDb: context.read());
  final ProjectsLocalDataSource _datasource;
  Future<void> putAll({required final List<ProjectModel> projects}) async =>
      _datasource.putAll(projects: projects);
  Future<void> put({required final ProjectModel project}) async =>
      _datasource.put(project: project);
  Future<void> remove({required final ProjectModelId id}) async =>
      _datasource.remove(id: id);
  Future<List<ProjectModel>> getAll({final RequestProjectsDto? dto}) async =>
      _datasource.getAll(dto: dto);
  Future<ProjectModel?> getById({required final ProjectModelId id}) async =>
      _datasource.getById(id: id);
  Future<List<ProjectModel>> getByIds({
    required final Iterable<ProjectModelId> ids,
  }) async =>
      _datasource.getByIds(ids: ids);

  Future<PaginatedPageResponseModel<ProjectModel>> getPaginated({
    required final PaginatedPageRequestModel<RequestProjectsDto> request,
  }) async =>
      _datasource.getPaginated(dto: request);
}

final class TagsRepository
    extends MapBasedRepository<ProjectTagModelId, ProjectTagModel>
    implements TagsLocalDataSource {
  TagsRepository(final BuildContext context)
      : _datasource = TagsLocalDataSourceImpl(
          localDb: context.read(),
        );
  final TagsLocalDataSource _datasource;

  @override
  void putAll(
    final Map<ProjectTagModelId, ProjectTagModel> map,
  ) =>
      _datasource.putAll(map);
  @override
  Map<ProjectTagModelId, ProjectTagModel> getAll() => _datasource.getAll();
}
