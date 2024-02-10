import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:shared_models/shared_models.dart';

import '../../../core.dart';

final class ProjectsLocalDataSourceIsarImpl implements ProjectsLocalDataSource {
  ProjectsLocalDataSourceIsarImpl({
    required this.isarDb,
  });
  final ComplexLocalDbIsarImpl isarDb;

  @override
  Future<PaginatedPageResponseModel<ProjectModel>> getProjects({
    required final PaginatedPageRequestModel<RequestProjectsDto> dto,
  }) async {
    final getDto = dto.data;
    final int itemsCount;
    final types = getDto?.types ?? [];
    final QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
        QAfterFilterCondition> basicQuery;
    if (getDto != null && getDto.search.isNotEmpty) {
      basicQuery = isarDb.projects
          .where()
          .jsonContentContains(
            '*${getDto.search}*',
            caseSensitive: false,
          )
          .and()
          .anyOf(types, (final q, final type) => q.typeEqualTo(type.name));
    } else {
      basicQuery = isarDb.projects
          .where()
          .anyOf(types, (final q, final type) => q.typeEqualTo(type.name));
    }
    final QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
        QAfterSortBy> sortedBasicQuery;
    if (getDto?.isReversed == true) {
      sortedBasicQuery = basicQuery.sortByUpdatedAt();
    } else {
      sortedBasicQuery = basicQuery.sortByUpdatedAtDesc();
    }
    itemsCount = await sortedBasicQuery.countAsync();
    final pagesCount = (itemsCount / dto.limit).ceil();
    final items = await sortedBasicQuery.findAllAsync(
      offset: dto.page * dto.limit,
      limit: dto.limit,
    );

    final resultItems = items
        .map(
          (final e) => ProjectModel.fromJson(
            jsonDecode(e.jsonContent) as Map<String, dynamic>,
          ),
        )
        .toList();

    return PaginatedPageResponseModel(
      values: resultItems,
      currentPage: dto.page,
      pagesCount: pagesCount,
    );
  }

  @override
  Future<void> put({required final ProjectModel project}) async {
    final isarProject = ProjectIsarCollection()
      ..type = project.type.name
      ..updatedAt = project.updatedAt
      ..jsonContent = jsonEncode(project.toJson())
      ..modelIdStr = project.id.value;

    isarDb.db.write(
      (final isar) => isar.projectIsarCollections.put(isarProject),
    );
  }

  @override
  Future<void> remove({required final ProjectModelId id}) async {
    isarDb.db.write(
      (final isar) => isar.projectIsarCollections.delete(id.value),
    );
  }

  @override
  Future<void> putAll({required final List<ProjectModel> projects}) async {
    isarDb.db.write(
      (final isar) {
        final List<ProjectIsarCollection> isarProjects = [];
        for (final project in projects) {
          final isarProject = ProjectIsarCollection()
            ..jsonContent = jsonEncode(project.toJson())
            ..type = project.type.name
            ..updatedAt = project.updatedAt
            ..modelIdStr = project.id.value;

          isarProjects.add(isarProject);
        }

        isar.projectIsarCollections.putAll(isarProjects);
      },
    );
  }
}
