import 'dart:convert';

import 'package:isar/isar.dart';

import '../../foundation/foundation.dart';
import '../../models/models.dart';
import '../datasources.dart';

final class ProjectsLocalDataSourceImpl extends ProjectsLocalDataSource {
  ProjectsLocalDataSourceImpl({
    required this.isarDb,
  });
  final IsarDb isarDb;

  @override
  Future<PaginatedPageResponseModel<ProjectModel>> getProjects({
    required final PaginatedPageRequestModel<GetProjectsDto> dto,
  }) async {
    final getDto = dto.data;
    final int itemsCount;
    final QueryBuilder<ProjectIsarCollection, ProjectIsarCollection,
        QAfterOffset> offsetQuery;
    final type = (getDto?.type ?? ProjectTypes.note).name;
    if (getDto != null && getDto.search.isNotEmpty) {
      final basicQuery = isarDb.projects
          .filter()
          .jsonContentContains(
            '*${getDto.search}*',
            caseSensitive: false,
          )
          .and()
          .typeEqualTo(type)
          .sortByUpdatedAt();
      offsetQuery = basicQuery.offset(dto.page * dto.limit);
      itemsCount = basicQuery.countSync();
    } else {
      final basicQuery =
          isarDb.projects.filter().typeEqualTo(type).sortByUpdatedAt();
      offsetQuery = basicQuery.offset(dto.page * dto.limit);
      itemsCount = basicQuery.countSync();
    }
    final pagesCount = (itemsCount / dto.limit).ceil();
    final items = await offsetQuery.limit(dto.limit).findAll();

    final resultItems = items
        .map(
          (final e) => ProjectModel.fromJson(
            jsonDecode(e.jsonContent),
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
      ..modelIdStr = project.id.value
      ..modelIdHashcode = await project.id.value.getHashcode();
    await isarDb.projects.put(isarProject);
  }

  @override
  Future<void> remove({required final ProjectModelId id}) async {
    await isarDb.projects.delete(await id.value.getHashcode());
  }

  @override
  Future<void> putAll({required final List<ProjectModel> projects}) async {
    final List<ProjectIsarCollection> isarProjects = [];
    for (final project in projects) {
      final isarProject = ProjectIsarCollection()
        ..jsonContent = jsonEncode(project.toJson())
        ..type = project.type.name
        ..updatedAt = project.updatedAt
        ..modelIdHashcode = await project.id.value.getHashcode()
        ..modelIdStr = project.id.value;
      isarProjects.add(isarProject);
    }
    await isarDb.projects.putAll(isarProjects);
  }
}
