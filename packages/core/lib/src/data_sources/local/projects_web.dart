import 'package:collection/collection.dart';
import 'package:shared_models/shared_models.dart';
import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';
import 'package:xsoulspace_ui_foundation/xsoulspace_ui_foundation.dart';

import '../../../core.dart';

class SearchableContainer<T> {
  const SearchableContainer({required this.jsonContent, required this.value});
  final T value;
  final String jsonContent;
  bool contains(final String search) => jsonContent.contains(search);
}

extension on ProjectModel {
  SearchableContainer<ProjectModel> toSearchableContainer() =>
      SearchableContainer(value: this, jsonContent: toString());
}

final class ProjectsLocalDataSourceLocalDbImpl
    implements ProjectsLocalDataSource {
  ProjectsLocalDataSourceLocalDbImpl({required this.localDb});
  final LocalDbDataSource localDb;
  final List<SearchableContainer<ProjectModel>> _fullCache = [];

  bool _isReversed = false;

  @override
  Future<PagingControllerPageModel<ProjectModel>> getPaginated({
    required final PaginatedPageRequestModel<RequestProjectsDto> dto,
  }) async {
    final data = dto.data;
    void reverse({final bool force = false}) {
      if (data == null) return;
      if (_isReversed != data.isReversed || force) {
        if (data.isReversed) {
          _fullCache.sort(
            (final a, final b) =>
                b.value.updatedAt.compareTo(a.value.updatedAt),
          );
        } else {
          _fullCache.sort(
            (final a, final b) =>
                a.value.updatedAt.compareTo(b.value.updatedAt),
          );
        }
        _isReversed = data.isReversed;
      }
    }

    if (_fullCache.isEmpty) {
      _preloadCache();

      /// first reverse
      reverse(force: true);
    }

    reverse();
    final items = [..._fullCache];
    if (data != null) {
      final conditions = <bool Function(SearchableContainer<ProjectModel> e)>[];
      if (data.search.isNotEmpty) {
        final search = data.search;
        conditions.add((final e) => e.jsonContent.contains(search));
      }
      if (!data.tagId.isEmpty) {
        conditions.add((final e) => e.value.tagsIds.contains(data.tagId));
      }
      items.retainWhere((final e) {
        for (final condition in conditions) {
          if (!condition(e)) {
            return false;
          }
        }
        return true;
      });
    }

    final int itemsCount = items.length;
    final pagesCount = (itemsCount / dto.limit).ceil();
    final start = (dto.page - 1) * dto.limit;
    final effectiveItems = items
        .skip(start)
        .take(dto.limit)
        .map((final e) => e.value);

    return PagingControllerPageModel(
      values: effectiveItems.toList(),
      currentPage: dto.page,
      pagesCount: pagesCount,
    );
  }

  @override
  Future<void> put({required final ProjectModel project}) async {
    final container = project.toSearchableContainer();
    final index = _fullCache.indexWhere((final e) => e.value.id == project.id);
    if (index >= 0) {
      _fullCache[index] = container;
    } else {
      _fullCache.insert(0, container);
    }
    _saveFullCache();
  }

  @override
  Future<void> remove({required final ProjectModelId id}) async {
    _fullCache.removeWhere((final e) => e.value.id == id);
    _saveFullCache();
  }

  void _putAllToCache({required final Iterable<ProjectModel> projects}) {
    final itemsContainers = projects.map(
      (final e) => e.toSearchableContainer(),
    );
    _fullCache
      ..clear()
      ..addAll(itemsContainers);
  }

  @override
  Future<void> putAll({required final List<ProjectModel> projects}) async {
    for (final project in projects) {
      await put(project: project);
    }
  }

  Iterable<ProjectModel> _getLocalItems() => localDb.getItemsIterable(
    key: SharedPreferencesKeys.webProjects.name,
    convertFromJson: ProjectModel.fromJson,
  );

  void _saveFullCache() => localDb.setItemsList(
    key: SharedPreferencesKeys.webProjects.name,
    convertToJson: (final v) => v.value.toJson(),
    value: _fullCache,
  );

  /// will be not sorted however
  void _preloadCache() {
    if (_fullCache.isNotEmpty) return;
    final localItems = _getLocalItems();
    _putAllToCache(projects: localItems);
  }

  @override
  Future<List<ProjectModel>> getAll({final RequestProjectsDto? dto}) async {
    _preloadCache();
    final items = [..._fullCache];
    if (dto != null) {
      if (dto.isReversed) {
        items.sort(
          (final a, final b) => b.value.updatedAt.compareTo(a.value.updatedAt),
        );
      } else {
        items.sort(
          (final a, final b) => a.value.updatedAt.compareTo(b.value.updatedAt),
        );
      }
      if (!dto.tagId.isEmpty) {
        items.removeWhere((final e) => !e.value.tagsIds.contains(dto.tagId));
      }
    }

    return items.map((final e) => e.value).toList();
  }

  @override
  Future<ProjectModel?> getById({required final ProjectModelId id}) async =>
      _fullCache.firstWhereOrNull((final e) => e.value.id == id)?.value;

  @override
  Future<List<ProjectModel>> getByIds({
    required final Iterable<ProjectModelId> ids,
  }) async {
    final map = _fullCache.toMap(
      toKey: (final e) => e.value.id,
      toValue: (final e) => e,
    );

    return ids.map((final e) => map[e]?.value).nonNulls.toList();
  }
}
