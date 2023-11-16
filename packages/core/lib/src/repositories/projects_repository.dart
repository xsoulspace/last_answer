import '../datasources/datasources.dart';
import '../foundation/foundation.dart';
import '../models/models.dart';

class ProjectsRepository {
  ProjectsRepository({
    required this.localDataSource,
  });
  final ProjectsLocalDataSource localDataSource;
  Future<void> putAll({required final List<ProjectModel> projects}) async =>
      localDataSource.putAll(projects: projects);
  Future<void> put({required final ProjectModel project}) async =>
      localDataSource.put(project: project);
  Future<void> remove({required final ProjectModelId id}) async =>
      localDataSource.remove(id: id);

  Future<PaginatedPageResponseModel<ProjectModel>> getPaginated({
    required final PaginatedPageRequestModel<GetProjectsDto> request,
  }) async =>
      localDataSource.getProjects(dto: request);
}
