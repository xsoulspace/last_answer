import '../../core.dart';
import '../state/projects_paged_requests_builder.dart';

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
    required final PaginatedPageRequestModel<RequestProjectsDto> request,
  }) async =>
      localDataSource.getProjects(dto: request);
}
