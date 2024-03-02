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
  Future<PaginatedPageResponseModel<ProjectModel>> getPaginated({
    required final PaginatedPageRequestModel<RequestProjectsDto> dto,
  }) async {
    final data = dto.data;
    final int itemsCount;
    final types = data?.types ?? [];
    var basicQuery = isarDb.projects
        .where()
        .anyOf(types, (final q, final type) => q.typeEqualTo(type.name));
    if (data != null) {
      if (data.search.isNotEmpty) {
        basicQuery = basicQuery
            .and()
            .jsonContentMatches('*${data.search}*', caseSensitive: false);
      }
      if (!data.tagId.isEmpty) {
        basicQuery = basicQuery.and().tagsElementContains(data.tagId.value);
      }
    }
    final sortedBasicQuery = switch (data?.isReversed) {
      true => basicQuery.sortByUpdatedAt(),
      null || false => basicQuery.sortByUpdatedAtDesc(),
    };
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
      ..tags = project.tagsIds.map((final e) => e.value).toList()
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
            ..tags = project.tagsIds.map((final e) => e.value).toList()
            ..modelIdStr = project.id.value;

          isarProjects.add(isarProject);
        }

        isar.projectIsarCollections.putAll(isarProjects);
      },
    );
  }

  @override
  Future<List<ProjectModel>> getAll({final RequestProjectsDto? dto}) async {
    final types = dto?.types ?? [];

    var basicQuery = isarDb.projects
        .where()
        .anyOf(types, (final q, final type) => q.typeEqualTo(type.name));
    if (dto != null) {
      if (dto.search.isNotEmpty) {
        basicQuery = basicQuery
            .and()
            .jsonContentContains('*${dto.search}*', caseSensitive: false);
      }
      if (!dto.tagId.isEmpty) {
        basicQuery = basicQuery.and().tagsElementContains(dto.tagId.value);
      }
    }

    final items = basicQuery.findAll();
    return items
        .map(
          (final e) => ProjectModel.fromJson(e.jsonMap),
        )
        .toList();
  }

  @override
  Future<ProjectModel?> getById({required final ProjectModelId id}) async {
    final project =
        isarDb.projects.where().modelIdStrEqualTo(id.value).findFirst();
    if (project == null) return null;
    return ProjectModel.fromJson(project.jsonMap);
  }

  @override
  Future<List<ProjectModel>> getByIds({
    required final Iterable<ProjectModelId> ids,
  }) async {
    final projects = isarDb.projects
        .where()
        .anyOf(ids, (final q, final e) => q.modelIdStrEqualTo(e.value))
        .findAll();
    return projects
        .map(
          (final e) => ProjectModel.fromJson(e.jsonMap),
        )
        .toList();
  }
}
