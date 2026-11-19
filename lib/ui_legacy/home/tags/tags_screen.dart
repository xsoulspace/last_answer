import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/ui_legacy/home/tags/tags.dart';
import 'package:lastanswer/ui_legacy/home/tags/tags_screen_state.dart';

class TagsScreen extends StatelessWidget {
  const TagsScreen({super.key});

  @override
  Widget build(final BuildContext context) => ChangeNotifierProvider(
    create: TagsScreenNotifier.new,
    builder: (final context, final child) => const TagsScreenBody(),
  );
}

class TagsScreenBody extends StatelessWidget {
  const TagsScreenBody({super.key});

  @override
  Widget build(final BuildContext context) {
    final screenType = context.select<TagsScreenNotifier, TagsScreenType>(
      (final c) => c.value.screenType,
    );
    return _FadeIn(
      child: switch (screenType) {
        TagsScreenType.allTags => const _TagsListView(),
        TagsScreenType.editingTag => const _ManageTagView(),
        TagsScreenType.addProjects => const _AddProjectsView(),
      },
    );
  }
}

/// Kit-motion replacement for the legacy `.animate().fadeIn()` chains
/// (optional [delay] mirrors `.animate(delay: …)`).
class _FadeIn extends HookWidget {
  const _FadeIn({required this.child, this.delay = Duration.zero});
  final Widget child;
  final Duration delay;

  @override
  Widget build(final BuildContext context) {
    final laUi = context.laUi;
    final visible = useState(false);
    useEffect(() {
      var cancelled = false;
      Future<void> reveal() async {
        if (delay != Duration.zero) await Future<void>.delayed(delay);
        if (!cancelled) visible.value = true;
      }

      unawaited(reveal());
      return () => cancelled = true;
    }, const []);

    return AnimatedOpacity(
      opacity: visible.value ? 1 : 0,
      duration: laUi.motionSettle,
      curve: laUi.motionCurve,
      child: child,
    );
  }
}

class _TagsListView extends StatelessWidget {
  const _TagsListView();

  @override
  Widget build(final BuildContext context) {
    final tags = context.watch<TagsNotifier>().orderedValues;
    final isPurchased = context.select<PurchasesNotifier, bool>(
      (final c) => c.isActive,
    );
    final foldersLimit = isPurchased ? 20 : 10;
    final isLimitReached = tags.length >= foldersLimit;
    final tagsScreenNotifier = context.watch<TagsScreenNotifier>();
    final laUi = context.laUi;
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: CustomScrollView(
            shrinkWrap: true,
            slivers: [
              DialogTopBar(title: l10n.folders).sliver(),
              LaBox(
                color: laUi.surface,
                border: BorderSide(color: laUi.rule),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: RichText(
                    text: TextSpan(
                      style: laUi.body,
                      children: [
                        TextSpan(text: l10n.useFoldersForNotes),
                        TextSpan(
                          style: laUi.compact,
                          text: l10n.youCanCreateUpTo(foldersLimit),
                        ),
                      ],
                    ),
                  ),
                ),
              ).sliver(),
              const SliverGap(16),
              SliverList.builder(
                itemCount: tags.length,
                itemBuilder: (final context, final index) {
                  final tag = tags[index];
                  return EditableTagListTile(
                    key: ValueKey(tag.id),
                    tag: tag,
                    onTap: () =>
                        tagsScreenNotifier.onEditTagManagement(tag: tag),
                    onDelete: () => tagsScreenNotifier.onDeleteTag(
                      context: context,
                      tag: tag,
                    ),
                  );
                },
              ),
              const SliverGap(8),
            ],
          ),
        ),
        const LaHairline(),
        Row(
          children: [
            Expanded(
              child: LaButton(
                label: l10n.cancel,
                variant: LaButtonVariant.ghost,
                expand: true,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: LaButton(
                label: isLimitReached ? l10n.limitReached : l10n.createFolder,
                variant: LaButtonVariant.primary,
                expand: true,
                onPressed: isLimitReached
                    ? null
                    : tagsScreenNotifier.onCreateTagManagement,
              ),
            ),
          ],
        ),
        const Gap(6),
      ],
    );
  }
}

class EditableTagListTile extends StatelessWidget {
  const EditableTagListTile({
    required this.tag,
    required this.onTap,
    required this.onDelete,
    super.key,
  });
  final ProjectTagModel tag;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(final BuildContext context) => LaRow(
    onTap: onTap,
    titleText: tag.title,
    trailing: LaButton.icon(
      onPressed: onDelete,
      icon: const Icon(CupertinoIcons.trash, size: 14),
    ),
  );
}

class _ManageTagView extends HookWidget {
  const _ManageTagView();
  @override
  Widget build(final BuildContext context) {
    final stateNotifier = context.watch<TagsScreenNotifier>();
    final state = stateNotifier.value;
    final selectedTag = state.selectedTag;
    final projectsContainer = state.projects;
    final projects = projectsContainer.value;
    final tagId = selectedTag.value.id;
    final laUi = context.laUi;
    final isSaving = selectedTag.isLoading;
    final l10n = context.l10n;

    // The legacy UiTextField was value-driven; mirror the tag title into a
    // controller for the kit field (validation state rides the notifier).
    final titleController = useTextEditingController(
      text: selectedTag.value.title,
    );
    useValueChanged<String, void>(selectedTag.value.title, (final _, final _) {
      if (titleController.text != selectedTag.value.title) {
        titleController.text = selectedTag.value.title;
      }
    });

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              DialogTopBar(
                title:
                    // ignore: lines_longer_than_80_chars
                    '${tagId.isEmpty ? l10n.create : l10n.edit} ${l10n.folder}',
                onClose: stateNotifier.onCloseTagManagement,
                isBottomBorderVisible: false,
              ).sliver(),
              const SliverGap(4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ValueListenableBuilder<String?>(
                  valueListenable: stateNotifier.folderTitleError,
                  builder: (final context, final error, final _) => LaField(
                    controller: titleController,
                    placeholder: l10n.folderName,
                    maxLength: 12,
                    onChanged: stateNotifier.onFolderTitleChanged,
                    errorText: error,
                  ),
                ),
              ).sliver(),
              const SliverGap(18),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 8,
                  child: ColoredBox(color: laUi.rule),
                ),
              ),
              const SliverGap(16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(l10n.projects, style: laUi.emphasis),
              ).sliver(),
              const SliverGap(16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: LaButton(
                  icon: const Icon(Icons.add),
                  label: l10n.addProjects,
                  variant: LaButtonVariant.primary,
                  expand: true,
                  onPressed: stateNotifier.onOpenAddProjects,
                ),
              ).sliver(),
              const SliverGap(16),
              if (projectsContainer.isLoading)
                const Center(child: LaSpinner(size: 24)).sliver()
              else
                SliverList.builder(
                  itemCount: projects.length,
                  itemBuilder: (final context, final index) {
                    final project = projects[index];
                    return ClosableProjectListTile(
                      project: project,
                      key: ValueKey(project.id),
                      onDelete: (final project) => stateNotifier
                          .onSelectedProjectChanged(false, project),
                    );
                  },
                ),
              const SliverGap(16),
            ],
          ),
        ),
        const LaHairline(),
        Row(
          children: [
            Expanded(
              child: LaButton(
                label: l10n.cancel,
                variant: LaButtonVariant.ghost,
                expand: true,
                onPressed: stateNotifier.onCloseTagManagement,
              ),
            ),
            Expanded(
              child: LaButton(
                variant: LaButtonVariant.primary,
                expand: true,
                onPressed: isSaving ? () {} : stateNotifier.onSaveTag,
                child: isSaving
                    ? const LaSpinner()
                    : Text(tagId.isEmpty ? l10n.create : l10n.save),
              ),
            ),
          ],
        ),
        const Gap(8),
      ],
    );
  }
}

class SelectableProjectListTile extends StatelessWidget {
  const SelectableProjectListTile({
    required this.project,
    required this.onTap,
    required this.selected,
    super.key,
  });
  final ProjectModel project;
  final bool selected;
  // ignore: avoid_positional_boolean_parameters
  final void Function(bool isSelected, ProjectModel project) onTap;
  @override
  Widget build(final BuildContext context) => LaRow(
    titleText: project.getTitle(context),
    selected: selected,
    trailing: Icon(
      Icons.check,
      color: selected ? context.laUi.accent : context.laUi.inkQuiet,
    ),
    onTap: () => onTap(!selected, project),
  );
}

class ClosableProjectListTile extends StatelessWidget {
  const ClosableProjectListTile({
    required this.project,
    required this.onDelete,
    super.key,
  });
  final ProjectModel project;
  final ValueChanged<ProjectModel> onDelete;
  @override
  Widget build(final BuildContext context) => LaRow(
    title: Text(project.getTitle(context), maxLines: 2),
    trailing: LaButton.icon(
      onPressed: () => onDelete(project),
      icon: const Icon(CupertinoIcons.trash, size: 16),
    ),
  );
}

class _AddProjectsView extends StatelessWidget {
  const _AddProjectsView();

  @override
  Widget build(final BuildContext context) {
    final tagsScreenNotifier = context.watch<TagsScreenNotifier>();
    final l10n = context.l10n;
    final projects = tagsScreenNotifier.value.projects;
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              LaTopBar(
                titleText: l10n.addProjects,
                trailing: LaButton.icon(
                  icon: const LaClose(),
                  onPressed: tagsScreenNotifier.onCloseAddProjects,
                ),
              ).sliver(),
              PagingListener(
                controller: tagsScreenNotifier.addProjectsPagedController.pager,
                builder: (final context, final state, final nextPageCallback) =>
                    PagedSliverList<int, ProjectModel>(
                      fetchNextPage: nextPageCallback,
                      state: state,
                      builderDelegate: PagedChildBuilderDelegate(
                        animateTransitions: true,
                        transitionDuration: const Duration(milliseconds: 100),
                        firstPageProgressIndicatorBuilder: (final context) =>
                            const _FadeIn(
                              delay: Duration(milliseconds: 1500),
                              child: Center(child: LaSpinner(size: 24)),
                            ),
                        noItemsFoundIndicatorBuilder: (final context) =>
                            _FadeIn(child: Text(context.l10n.noProjectsYet)),
                        newPageProgressIndicatorBuilder: (final context) =>
                            const _FadeIn(
                              delay: Duration(milliseconds: 1500),
                              child: Center(child: LaSpinner(size: 24)),
                            ),
                        itemBuilder: (final context, final item, final index) =>
                            SelectableProjectListTile(
                              key: ValueKey(item.id),
                              selected:
                                  projects.value.firstWhereOrNull(
                                    (final e) => e.id == item.id,
                                  ) !=
                                  null,
                              project: item,
                              onTap:
                                  tagsScreenNotifier.onSelectedProjectChanged,
                            ),
                      ),
                    ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: LaField(
            prefix: const Icon(Icons.search, size: 16),
            placeholder: l10n.searchProjects,
            onChanged: tagsScreenNotifier.onSearchAddProjects,
            autofocus: PlatformInfo.isNativeWebDesktop,
            suffix: LaButton.icon(
              icon: const Icon(Icons.arrow_back, size: 16),
              onPressed: tagsScreenNotifier.onCloseAddProjects,
            ),
          ),
        ),
      ],
    );
  }
}

class DialogTopBar extends StatelessWidget {
  const DialogTopBar({
    required this.title,
    this.isBottomBorderVisible = true,
    this.onClose,
    super.key,
  });
  final bool isBottomBorderVisible;
  final String title;
  final VoidCallback? onClose;
  @override
  Widget build(final BuildContext context) {
    final laUi = context.laUi;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 8, left: 16, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(title, style: laUi.emphasis)),
              LaButton.icon(icon: const LaClose(), onPressed: onClose),
            ],
          ),
        ),
        if (isBottomBorderVisible) const LaHairline(),
      ],
    );
  }
}
