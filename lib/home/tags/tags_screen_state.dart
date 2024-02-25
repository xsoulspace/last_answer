import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lastanswer/common_imports.dart';

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
  ProjectsNotifier projectsNotifier
});

extension type TagsScreenNotifierDto._(_DtoDeclaration _) {
  TagsScreenNotifierDto.of(final BuildContext context)
      : this._(
          (
            tagsNotifier: context.read(),
            projectsNotifier: context.read(),
          ),
        );
}

class TagsScreenNotifier extends ValueNotifier<TagsScreenState> {
  TagsScreenNotifier(final BuildContext context)
      : dto = TagsScreenNotifierDto.of(context),
        super(const TagsScreenState());
  final TagsScreenNotifierDto dto;

  void onEditTag({required final ProjectTagModel tag}) =>
      value = value.copyWith(selectedTag: FieldContainer(value: tag));

  /// open tag creation
  void onOpenTagManagement({required final ProjectTagModel? tag}) =>
      value = value.copyWith(
        screenType: TagsScreenType.editingTag,
        selectedTag: FieldContainer(value: tag ?? ProjectTagModel.empty),
      );
  void onCloseTagManagement() => value = value.copyWith(
        screenType: TagsScreenType.allTags,
        selectedTag: const FieldContainer(value: ProjectTagModel.empty),
      );
  void onCloseAddProjects() => value = value.copyWith(
        screenType: TagsScreenType.editingTag,
      );

  void onOpenAddProjects() =>
      value = value.copyWith(screenType: TagsScreenType.addProjects);
  Future<void> onSaveTag() async {
    setTagLoading(true);
    try {
      ProjectTagModel tag = value.selectedTag.value;
      if (tag.id.isEmpty) {
        tag = tag.copyWith(id: ProjectTagModelId.generate());
      }
      final tagId = tag.id;
      dto._.tagsNotifier.put(key: tagId, value: tag);
      await assignTagToProjects(tagId);
      onCloseTagManagement();
    } finally {
      setTagLoading(false);
    }
  }

  Future<void> assignTagToProjects(final ProjectTagModelId tagId) async {
    final projects = value.projects.value;
    for (final project in projects) {
      final updatedProject = project.copyWith(
        tagsIds: [...project.tagsIds, tagId],
      );

      dto._.projectsNotifier.updateProject(updatedProject);
    }
  }

  void removeProject(final ProjectModel project) {
    final projects = value.projects.value;
    final updatedProjects = [...projects]
      ..removeWhere((final e) => e.id != project.id);
    value = value.copyWith(
      projects: LoadableContainer.loaded(updatedProjects),
    );
  }

  // ignore: avoid_positional_boolean_parameters
  void setTagLoading(final bool isLoading) => value = value.copyWith(
        selectedTag: value.selectedTag.copyWith(
          isLoading: isLoading,
        ),
      );
}
