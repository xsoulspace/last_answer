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
  final LocalDbI localDb;
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
      await _preloadCache();

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
    await _preloadCache();
    final container = project.toSearchableContainer();
    final index = _fullCache.indexWhere((final e) => e.value.id == project.id);
    if (index >= 0) {
      _fullCache[index] = container;
    } else {
      _fullCache.insert(0, container);
    }
    await _saveFullCache();
  }

  @override
  Future<void> remove({required final ProjectModelId id}) async {
    await _preloadCache();
    _fullCache.removeWhere((final e) => e.value.id == id);
    await _saveFullCache();
  }

  @override
  Future<void> putAll({required final List<ProjectModel> projects}) async {
    await _preloadCache();
    for (final project in projects) {
      await put(project: project);
    }
  }

  Future<Iterable<ProjectModel>> _getLocalItems() => localDb.getItemsIterable(
    key: SharedPreferencesKeys.webProjects.name,
    fromJson: ProjectModel.fromJson,
  );

  Future<void> _saveFullCache() => localDb.setItemsList(
    key: SharedPreferencesKeys.webProjects.name,
    toJson: (final v) => v.value.toJson(),
    value: _fullCache,
  );

  /// will be not sorted however
  Future<void> _preloadCache() async {
    if (_fullCache.isNotEmpty) return;
    final localItems = await _getLocalItems();
    final itemsContainers = localItems.map(
      (final e) => e.toSearchableContainer(),
    );
    _fullCache
      ..clear()
      ..addAll(itemsContainers);
  }

  @override
  Future<List<ProjectModel>> getAll({final RequestProjectsDto? dto}) async {
    await _preloadCache();
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
  Future<ProjectModel?> getById({required final ProjectModelId id}) async {
    await _preloadCache();
    return _fullCache.firstWhereOrNull((final e) => e.value.id == id)?.value;
  }

  @override
  Future<List<ProjectModel>> getByIds({
    required final Iterable<ProjectModelId> ids,
  }) async {
    await _preloadCache();

    final map = _fullCache.toMap(
      toKey: (final e) => e.value.id,
      toValue: (final e) => e,
    );

    return ids.map((final e) => map[e]?.value).nonNulls.toList();
  }
}
