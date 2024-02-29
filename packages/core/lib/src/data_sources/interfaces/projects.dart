import 'package:shared_models/shared_models.dart';

import '../../../core.dart';

abstract interface class ProjectsLocalDataSource {
  Future<void> putAll({required final List<ProjectModel> projects});
  Future<void> put({required final ProjectModel project});
  Future<void> remove({required final ProjectModelId id});
  Future<List<ProjectModel>> getAll({final RequestProjectsDto? dto});
  Future<PaginatedPageResponseModel<ProjectModel>> getPaginated({
    required final PaginatedPageRequestModel<RequestProjectsDto> dto,
  });
  Future<ProjectModel?> getById({required final ProjectModelId id});
  Future<List<ProjectModel>> getByIds({
    required final Iterable<ProjectModelId> ids,
  });
}
