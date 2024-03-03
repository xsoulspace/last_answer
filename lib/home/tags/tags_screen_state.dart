import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:life_hooks/life_hooks.dart';

part 'tags_screen_state.freezed.dart';

enum TagsScreenType {
  allTags,
  editingTag,
  addProjects,
}

@freezed
class TagsScreenState with _$TagsScreenState {
  const factory TagsScreenState({
    @Default(FieldContainer(value: ProjectTagModel.empty))
    final FieldContainer<ProjectTagModel> selectedTag,
    final String? addProjectsSearch,
    @Default(LoadableContainer(value: []))
    final LoadableContainer<List<ProjectModel>> projects,
    @Default(TagsScreenType.allTags) final TagsScreenType screenType,
  }) = _TagsScreenState;
}

typedef _DtoDeclaration = ({
  TagsNotifier tagsNotifier,
  ProjectsNotifier projectsNotifier,
  ProjectsRepository projectsRepository
});

extension type TagsScreenNotifierDto._(_DtoDeclaration _) {
  TagsScreenNotifierDto.of(final BuildContext context)
      : this._(
          (
            tagsNotifier: context.read(),
            projectsNotifier: context.read(),
            projectsRepository: context.read(),
          ),
        );
}

class TagsScreenNotifier extends ValueNotifier<TagsScreenState> {
  TagsScreenNotifier(final BuildContext context)
      : dto = TagsScreenNotifierDto.of(context),
        super(const TagsScreenState());
  final TagsScreenNotifierDto dto;
  final folderFieldFormHelper = FormHelper();
  final _removedProjects = <ProjectModel>{};
  late final addProjectsPagedController = ProjectsPagedController(
    requestBuilder: ProjectsPagedDataRequestsBuilder.getAll(
      projectsRepository: dto._.projectsRepository,
      getDto: () => RequestProjectsDto(
        search: value.addProjectsSearch ?? '',
      ),
    ),
  )..onLoad();
  late final _addProjectsSearchUpdatesController = StreamController<String?>()
    ..stream.debounceTime(150.milliseconds).listen(_updateAddProjectsSearch);
  void onSearchAddProjects(final String? search) =>
      _addProjectsSearchUpdatesController.add(search);
  ProjectTagModel get selectedTag => value.selectedTag.value;
  ProjectTagModelId get _appWideSelectedTagId =>
      dto._.projectsNotifier.selectedTagId;
  bool get _isEditingAppWideTag => _appWideSelectedTagId == selectedTag.id;

  @override
  void dispose() {
    unawaited(_addProjectsSearchUpdatesController.close());
    folderFieldFormHelper.dispose();
    addProjectsPagedController.dispose();
    super.dispose();
  }

  void _removeProject(final ProjectModel project) {
    final projects = value.projects.value;
    final updatedProjects = [...projects]
      ..removeWhere((final e) => e.id == project.id);
    _removedProjects.add(project);
    _updateProjects(updatedProjects);
  }

  void _updateProjects(final List<ProjectModel> updatedProjects) =>
      value = value.copyWith(
        projects: LoadableContainer.loaded(updatedProjects.toSet().toList()),
      );

  void onSelectedProjectChanged(
    // ignore: avoid_positional_boolean_parameters
    final bool isSelected,
    final ProjectModel project,
  ) {
    if (isSelected) {
      _removedProjects.remove(project);
      _updateProjects([...value.projects.value, project]);
    } else {
      _removeProject(project);
    }
  }

  // ignore: avoid_positional_boolean_parameters
  void setTagLoading(final bool isLoading) => value = value.copyWith(
        selectedTag: value.selectedTag.copyWith(
          isLoading: isLoading,
        ),
      );
}

extension TagsNotifierXAddProjectsView on TagsScreenNotifier {
  void _updateAddProjectsSearch(final String? search) {
    value = value.copyWith(addProjectsSearch: search);
    addProjectsPagedController
      ..refresh()
      ..loadFirstPage();
  }
}

extension TagsNotifierXNavigation on TagsScreenNotifier {
  void onCreateTagManagement() => onEditTagManagement(tag: null);
  void onEditTagManagement({required final ProjectTagModel? tag}) {
    value = value.copyWith(
      screenType: TagsScreenType.editingTag,
      selectedTag: FieldContainer(value: tag ?? ProjectTagModel.empty),
      projects: const LoadableContainer(value: []),
    );
    if (tag != null) {
      unawaited(_loadTagProjects());
    } else {
      _updateProjects([]);
    }
  }

  Future<void> _loadTagProjects() async {
    final tagProjects = await dto._.projectsRepository.getAll(
      dto: RequestProjectsDto(tagId: selectedTag.id),
    );
    _updateProjects(tagProjects);
  }

  void onCloseTagManagement() => value = value.copyWith(
        screenType: TagsScreenType.allTags,
        selectedTag: const FieldContainer(value: ProjectTagModel.empty),
        projects: const LoadableContainer(value: []),
      );
  void onOpenAddProjects() {
    value = value.copyWith(screenType: TagsScreenType.addProjects);
    addProjectsPagedController.loadFirstPage();
  }

  void onCloseAddProjects() {
    value = value.copyWith(
      screenType: TagsScreenType.editingTag,
      addProjectsSearch: null,
    );
    addProjectsPagedController.refresh();
  }
}

extension TagsNotifierXFolderEditing on TagsScreenNotifier {
  Future<void> onDeleteTag({
    required final BuildContext context,
    required final ProjectTagModel tag,
  }) async {
    final l10n = context.l10n;
    final shouldBeDeleted = await Modals.of(context).showWarningDialog(
      description:
          "${l10n.beCarefulItsInreversableAction}. \nDeletion of this Folder doesn't delete any Note or Idea.",
      title: 'Delete folder?',
      noActionText: l10n.cancel,
      yesActionText: l10n.delete,
    );

    if (!shouldBeDeleted) return;

    final isDeletingAppWideTag = tag.id == dto._.projectsNotifier.selectedTagId;

    final tagId = tag.id;
    _removedProjects.addAll(value.projects.value);
    _updateProjects([]);
    await _assignTagToProjects(tagId);
    dto._.tagsNotifier.remove(key: tagId);
    if (isDeletingAppWideTag) {
      final tags = dto._.tagsNotifier.values;
      if (tags.isNotEmpty) {
        dto._.projectsNotifier.updateDto(
          (final dto) => dto.copyWith(
            tagId: tags.first.id,
          ),
        );
      } else {
        dto._.projectsNotifier.updateDto(
          (final dto) => dto.copyWith(
            tagId: ProjectTagModelId.empty,
          ),
        );
      }
    }
  }

  Future<void> onSaveTag() async {
    setTagLoading(true);
    try {
      final isValid = folderFieldFormHelper.validate();
      if (!isValid) return;

      ProjectTagModel tag = value.selectedTag.value;
      if (tag.id.isEmpty) {
        tag = tag.copyWith(id: ProjectTagModelId.generate());
      }
      final tagId = tag.id;
      dto._.tagsNotifier.put(key: tagId, value: tag);
      await _assignTagToProjects(tagId);
      onCloseTagManagement();
    } finally {
      setTagLoading(false);
    }
  }

  void onFolderTitleChanged(final String newTitle) => value = value.copyWith(
        selectedTag: value.selectedTag.copyWith(
          value: value.selectedTag.value.copyWith(
            title: newTitle,
          ),
        ),
      );
  Future<void> _assignTagToProjects(final ProjectTagModelId tagId) async {
    final projects = value.projects.value.toSet();

    /// added, updated
    final updatedProjects = {
      ...projects.map(
        (final e) => e.copyWith(
          tagsIds: {...e.tagsIds, tagId}.toList(),
        ),
      ),
    };
    await dto._.projectsNotifier.updateProjects(
      updatedProjects,
      shouldUpdatePager: _isEditingAppWideTag,
    );

    /// removed
    final projectsToRemove = _removedProjects.difference(projects);
    final updatedRemovedProjects = projectsToRemove.map(
      (final e) => e.copyWith(
        tagsIds: [...e.tagsIds]..remove(tagId),
      ),
    );
    await dto._.projectsNotifier
        .updateProjects(updatedRemovedProjects, shouldUpdatePager: false);
    if (_isEditingAppWideTag) {
      final map = updatedRemovedProjects.toMap(
        toKey: (final i) => i.id,
        toValue: (final i) => i,
      );
      dto._.projectsNotifier.projectsPagedController
          .deleteItemsWhere((final e) => map.containsKey(e.id));
    }

    _removedProjects.clear();
  }
}
