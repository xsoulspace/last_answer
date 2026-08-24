import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_models/shared_models.dart';
import 'package:universal_storage_interface/universal_storage_interface.dart';
import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';
import 'package:xsoulspace_ui_foundation/xsoulspace_ui_foundation.dart';

import '../../core.dart';
import 'package:lastanswer/settings/features/storage_backends_state.dart'
    as storage_backends;

class ProjectsRepository {
  ProjectsRepository(final BuildContext context)
    : _datasource = ProjectsLocalDataSourceLocalDbImpl(
        localDb: context.read<LocalDbI>(),
        storageService: context.read<StorageService>(),
        supportsFileStorage: () =>
            storage_backends.StorageBackendIdX.fromName(
              storage_backends.StorageBackendsNotifier.instance
                      .snapshot()['active']
                  as String?,
            ) ==
            storage_backends.StorageBackendId.filesystem,
      );
  final ProjectsLocalDataSource _datasource;
  Future<void> putAll({required final List<ProjectModel> projects}) =>
      _datasource.putAll(projects: projects);
  Future<void> put({required final ProjectModel project}) =>
      _datasource.put(project: project);
  Future<void> remove({required final ProjectModelId id}) =>
      _datasource.remove(id: id);
  Future<List<ProjectModel>> getAll({final RequestProjectsDto? dto}) =>
      _datasource.getAll(dto: dto);
  Future<ProjectModel?> getById({required final ProjectModelId id}) =>
      _datasource.getById(id: id);
  Future<List<ProjectModel>> getByIds({
    required final Iterable<ProjectModelId> ids,
  }) => _datasource.getByIds(ids: ids);

  Future<List<ProjectModel>> getChildren({
    required final ProjectModelId parentDocId,
  }) => _datasource.getChildren(parentDocId: parentDocId);

  Future<PagingControllerPageModel<ProjectModel>> getPaginated({
    required final PaginatedPageRequestModel<RequestProjectsDto> request,
  }) async {
    final response = await _datasource.getPaginated(dto: request);

    /// hack to inject changelog
    if (request.data?.shouldAddChangelog == true) {}
    return response;
  }
}

final class TagsRepository implements TagsLocalDataSource {
  TagsRepository(final BuildContext context)
    : _datasource = TagsLocalDataSourceImpl(localDb: context.read());
  final TagsLocalDataSource _datasource;

  @override
  Future<void> putAll(final Map<ProjectTagModelId, ProjectTagModel> map) =>
      _datasource.putAll(map);
  @override
  Future<Map<ProjectTagModelId, ProjectTagModel>> getAll() =>
      _datasource.getAll();
}
