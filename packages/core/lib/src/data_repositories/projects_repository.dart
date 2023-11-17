import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core.dart';
import '../state/projects_paged_requests_builder.dart';

class ProjectsRepository {
  ProjectsRepository.provide(final BuildContext context)
      : _datasource = context.read();
  final ProjectsLocalDataSource _datasource;
  Future<void> putAll({required final List<ProjectModel> projects}) async =>
      _datasource.putAll(projects: projects);
  Future<void> put({required final ProjectModel project}) async =>
      _datasource.put(project: project);
  Future<void> remove({required final ProjectModelId id}) async =>
      _datasource.remove(id: id);

  Future<PaginatedPageResponseModel<ProjectModel>> getPaginated({
    required final PaginatedPageRequestModel<RequestProjectsDto> request,
  }) async =>
      _datasource.getProjects(dto: request);
}
