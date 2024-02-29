import 'package:collection/collection.dart';
import 'package:shared_models/shared_models.dart';

import '../../../core.dart';

final class ProjectsLocalDataSourceLocalDbImpl
    implements ProjectsLocalDataSource {
  ProjectsLocalDataSourceLocalDbImpl({
    required this.localDb,
  });
  final LocalDbDataSource localDb;
  final List<ProjectModel> _cache = [];
  bool _isReversed = false;
  @override
  Future<PaginatedPageResponseModel<ProjectModel>> getPaginated({
    required final PaginatedPageRequestModel<RequestProjectsDto> dto,
  }) async {
    final data = dto.data;

    // ignore: avoid_positional_boolean_parameters
    void reverse({final bool force = false}) {
      if (data == null) return;
      if (_isReversed != data.isReversed || force) {
        if (data.isReversed) {
          _cache.sort((final a, final b) => b.updatedAt.compareTo(a.updatedAt));
        } else {
          _cache.sort((final a, final b) => a.updatedAt.compareTo(b.updatedAt));
        }
        _isReversed = data.isReversed;
      }
    }

    if (_cache.isEmpty) {
      final localItems = localDb.getItemsIterable(
        key: SharedPreferencesKeys.webProjects.name,
        convertFromJson: ProjectModel.fromJson,
      );
      _cache.addAll(localItems);

      /// first reverse
      reverse(force: true);
    }

    reverse();

    final int itemsCount = _cache.length;
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
    final index = _cache.indexWhere((final e) => e.id == project.id);
    if (index >= 0) {
      _cache[index] = project;
    } else {
      _cache.insert(0, project);
    }
    _saveCache();
  }

  @override
  Future<void> remove({required final ProjectModelId id}) async {
    _cache.removeWhere((final e) => e.id == id);
    _saveCache();
  }

  @override
  Future<void> putAll({required final List<ProjectModel> projects}) async {
    _cache
      ..clear()
      ..addAll(projects);
    _saveCache();
  }

  void _saveCache() => localDb.setItemsList(
        key: SharedPreferencesKeys.webProjects.name,
        convertToJson: (final v) => v.toJson(),
        value: _cache,
      );

  @override
  Future<List<ProjectModel>> getAll({final RequestProjectsDto? dto}) async {
    final data = [..._cache];
    if (dto != null) {
      if (dto.isReversed) {
        data.sort((final a, final b) => b.updatedAt.compareTo(a.updatedAt));
      } else {
        data.sort((final a, final b) => a.updatedAt.compareTo(b.updatedAt));
      }
      if (!dto.tagId.isEmpty) {
        data.removeWhere((final e) => e.tagsIds.contains(dto.tagId));
      }
    }

    return data;
  }

  @override
  Future<ProjectModel?> getById({required final ProjectModelId id}) async =>
      _cache.firstWhereOrNull((final e) => e.id == id);

  @override
  Future<List<ProjectModel>> getByIds({
    required final Iterable<ProjectModelId> ids,
  }) async {
    final map = _cache.toMap(toKey: (final v) => v.id, toValue: (final v) => v);

    return ids.map((final e) => map[e]).nonNulls.toList();
  }
}
