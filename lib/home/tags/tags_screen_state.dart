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

  late final allProjectsPagedController = ProjectsPagedController(
    requestBuilder: ProjectsPagedDataRequestsBuilder.getAll(
      projectsRepository: dto._.projectsRepository,
      getDto: RequestProjectsDto.new,
    ),
  )..onLoad();

  ProjectTagModel get selectedTag => value.selectedTag.value;
  @override
  void dispose() {
    folderFieldFormHelper.dispose();
    allProjectsPagedController.dispose();
    super.dispose();
  }

  void onFolderTitleChanged(final String newTitle) => value = value.copyWith(
        selectedTag: value.selectedTag.copyWith(
          value: value.selectedTag.value.copyWith(
            title: newTitle,
          ),
        ),
      );
  Future<void> onDeleteTag({
    required final BuildContext context,
    required final ProjectTagModel tag,
  }) async {
    final l10n = context.l10n;
    final shouldBeDeleted = await Modals.of(context).showWarningDialog(
      description: l10n.beCarefulItsInreversableAction,
      title: 'Delete folder?',
      noActionText: l10n.cancel,
      yesActionText: l10n.delete,
    );

    if (shouldBeDeleted) {
      final tagId = tag.id;
      _removedProjects.addAll(value.projects.value);
      _updateProjects([]);
      await _assignTagToProjects(tagId);
      dto._.tagsNotifier.remove(key: tagId);
    }
  }

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

  void onCloseTagManagement() => value = value.copyWith(
        screenType: TagsScreenType.allTags,
        selectedTag: const FieldContainer(value: ProjectTagModel.empty),
        projects: const LoadableContainer(value: []),
      );

  void onCloseAddProjects() {
    value = value.copyWith(screenType: TagsScreenType.editingTag);
    allProjectsPagedController.refresh();
  }

  void onOpenAddProjects() {
    value = value.copyWith(screenType: TagsScreenType.addProjects);
    allProjectsPagedController.loadFirstPage();
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

  Future<void> _loadTagProjects() async {
    final tagProjects = await dto._.projectsRepository.getAll(
      dto: RequestProjectsDto(tagId: selectedTag.id),
    );
    print('loaded projects: ${tagProjects.length}');
    _updateProjects(tagProjects);
  }

  Future<void> _assignTagToProjects(final ProjectTagModelId tagId) async {
    final projects = value.projects.value.toSet();
    final projectsToRemove = _removedProjects.difference(projects);
    print('will be added: ${projects.map((final e) => e.title).toList()}');
    print(
      'will be removed: ${projectsToRemove.map((final e) => e.title).toList()}',
    );
    final updatedProjects = {
      ...projects.map(
        (final e) => e.copyWith(
          tagsIds: {...e.tagsIds, tagId}.toList(),
        ),
      ),
      ...projectsToRemove.map(
        (final e) => e.copyWith(
          tagsIds: [...e.tagsIds]..remove(tagId),
        ),
      ),
    };
    unawaited(dto._.projectsNotifier.updateProjects(updatedProjects));

    _removedProjects.clear();
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
