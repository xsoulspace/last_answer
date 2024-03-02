import 'package:collection/collection.dart';
import 'package:shared_models/shared_models.dart';

import '../../../core.dart';

class SearchableContainer<T> {
  const SearchableContainer({required this.jsonContent, required this.value});
  final T value;
  final String jsonContent;
  bool contains(final String search) => jsonContent.contains(search);
}

extension on ProjectModel {
  SearchableContainer<ProjectModel> toSearchableContainer() =>
      SearchableContainer(
        value: this,
        jsonContent: toString(),
      );
}

final class ProjectsLocalDataSourceLocalDbImpl
    implements ProjectsLocalDataSource {
  ProjectsLocalDataSourceLocalDbImpl({
    required this.localDb,
  });
  final LocalDbDataSource localDb;
  final List<SearchableContainer<ProjectModel>> _cache = [];
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
          _cache.sort(
            (final a, final b) =>
                b.value.updatedAt.compareTo(a.value.updatedAt),
          );
        } else {
          _cache.sort(
            (final a, final b) =>
                a.value.updatedAt.compareTo(b.value.updatedAt),
          );
        }
        _isReversed = data.isReversed;
      }
    }

    if (_cache.isEmpty) {
      final localItems = localDb.getItemsIterable(
        key: SharedPreferencesKeys.webProjects.name,
        convertFromJson: ProjectModel.fromJson,
      );
      _putAll(projects: localItems);

      /// first reverse
      reverse(force: true);
    }

    reverse();
    final items = [..._cache];
    if (data != null) {
      if (data.search.isNotEmpty) {
        final search = data.search;
        items.retainWhere((final e) => e.jsonContent.contains(search));
      }
    }

    final int itemsCount = items.length;
    final pagesCount = (itemsCount / dto.limit).ceil();
    final start = dto.page * dto.limit;
    final effectiveItems =
        items.skip(start).take(dto.limit).map((final e) => e.value);

    return PaginatedPageResponseModel(
      values: effectiveItems.toList(),
      currentPage: dto.page,
      pagesCount: pagesCount,
    );
  }

  @override
  Future<void> put({required final ProjectModel project}) async {
    final container = project.toSearchableContainer();
    final index = _cache.indexWhere((final e) => e.value.id == project.id);
    if (index >= 0) {
      _cache[index] = container;
    } else {
      _cache.insert(0, container);
    }
    _saveCache();
  }

  @override
  Future<void> remove({required final ProjectModelId id}) async {
    _cache.removeWhere((final e) => e.value.id == id);
    _saveCache();
  }

  void _putAll({required final Iterable<ProjectModel> projects}) {
    final itemsContainers = projects.map(
      (final e) => e.toSearchableContainer(),
    );
    _cache
      ..clear()
      ..addAll(itemsContainers);
  }

  @override
  Future<void> putAll({required final List<ProjectModel> projects}) async {
    _putAll(projects: projects);
    _saveCache();
  }

  void _saveCache() => localDb.setItemsList(
        key: SharedPreferencesKeys.webProjects.name,
        convertToJson: (final v) => v.value.toJson(),
        value: _cache,
      );

  @override
  Future<List<ProjectModel>> getAll({final RequestProjectsDto? dto}) async {
    final items = [..._cache];
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
        items.removeWhere((final e) => e.value.tagsIds.contains(dto.tagId));
      }
    }

    return items.map((final e) => e.value).toList();
  }

  @override
  Future<ProjectModel?> getById({required final ProjectModelId id}) async =>
      _cache.firstWhereOrNull((final e) => e.value.id == id)?.value;

  @override
  Future<List<ProjectModel>> getByIds({
    required final Iterable<ProjectModelId> ids,
  }) async {
    final map =
        _cache.toMap(toKey: (final e) => e.value.id, toValue: (final e) => e);

    return ids.map((final e) => map[e]?.value).nonNulls.toList();
  }
}
