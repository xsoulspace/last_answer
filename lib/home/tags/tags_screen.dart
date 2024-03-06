import 'package:flutter/cupertino.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/home/tags/tags.dart';
import 'package:lastanswer/home/tags/tags_screen_state.dart';

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
    return switch (screenType) {
      TagsScreenType.allTags => const _TagsListView(),
      TagsScreenType.editingTag => const _ManageTagView(),
      TagsScreenType.addProjects => const _AddProjectsView(),
    };
  }
}

class _TagsListView extends StatelessWidget {
  const _TagsListView({super.key});

  @override
  Widget build(final BuildContext context) {
    final tags = context.watch<TagsNotifier>().values;
    final isPurchased =
        context.select<PurchasesNotifier, bool>((final c) => c.isActive);
    final foldersLimit = isPurchased ? 20 : 10;
    final isLimitReached = tags.length >= foldersLimit;
    final tagsScreenNotifier = context.watch<TagsScreenNotifier>();
    final textTheme = context.textTheme;
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: CustomScrollView(
            shrinkWrap: true,
            slivers: [
              DialogTopBar(title: l10n.folders).sliver(),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: RichText(
                    text: TextSpan(
                      style: textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: l10n.useFoldersForNotes,
                        ),
                        TextSpan(
                          style: textTheme.bodySmall,
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
                    onDelete: () async => tagsScreenNotifier.onDeleteTag(
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
        const Divider(),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
            ),
            Expanded(
              child: FilledButton.tonal(
                onPressed: isLimitReached
                    ? null
                    : tagsScreenNotifier.onCreateTagManagement,
                child: Text(
                  isLimitReached ? l10n.limitReached : l10n.createFolder,
                ),
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
  Widget build(final BuildContext context) => ListTile(
        onTap: onTap,
        title: Text(tag.title),
        trailing: IconButton(
          onPressed: onDelete,
          iconSize: 14,
          icon: const Icon(CupertinoIcons.trash),
        ),
      );
}

class _ManageTagView extends StatelessWidget {
  const _ManageTagView();
  @override
  Widget build(final BuildContext context) {
    final stateNotifier = context.watch<TagsScreenNotifier>();
    final state = stateNotifier.value;
    final selectedTag = state.selectedTag;
    final projectsContainer = state.projects;
    final projects = projectsContainer.value;
    final tagId = selectedTag.value.id;
    final textTheme = context.textTheme;
    final formHelper = stateNotifier.folderFieldFormHelper;
    final isSaving = selectedTag.isLoading;
    final l10n = context.l10n;

    return Form(
      key: formHelper.formKey,
      child: Column(
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
                  child: UiTextField(
                    decoration: InputDecoration(
                      labelText: l10n.folderName,
                    ),
                    maxLength: 12,
                    value: selectedTag.value.title,
                    onChanged: stateNotifier.onFolderTitleChanged,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                ).sliver(),
                const SliverGap(18),
                const Divider(thickness: 8).sliver(),
                const SliverGap(16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.projects,
                    style: textTheme.titleMedium,
                  ),
                ).sliver(),
                const SliverGap(16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: FilledButton.icon(
                    onPressed: stateNotifier.onOpenAddProjects,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addProjects),
                  ),
                ).sliver(),
                const SliverGap(16),
                if (projectsContainer.isLoading)
                  const UiCircularProgress().sliver()
                else
                  SliverList.builder(
                    itemCount: projects.length,
                    itemBuilder: (final context, final index) {
                      final project = projects[index];
                      return ClosableProjectListTile(
                        project: project,
                        key: ValueKey(project.id),
                        onDelete: (final project) =>
                            stateNotifier.onSelectedProjectChanged(
                          false,
                          project,
                        ),
                      );
                    },
                  ),
                const SliverGap(16),
              ],
            ),
          ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: stateNotifier.onCloseTagManagement,
                  child: Text(l10n.cancel),
                ),
              ),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: isSaving ? () {} : stateNotifier.onSaveTag,
                  child: isSaving
                      ? const UiCircularProgress()
                      : Text(tagId.isEmpty ? l10n.create : l10n.save),
                ),
              ),
            ],
          ),
          const Gap(8),
        ],
      ),
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
  Widget build(final BuildContext context) => ListTile(
        title: Text(project.getTitle(context)),
        selected: selected,
        trailing: Icon(
          Icons.check,
          color: selected
              ? context.colorScheme.tertiary
              : context.colorScheme.tertiaryContainer,
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
  Widget build(final BuildContext context) => ListTile(
        title: Text(project.getTitle(context), maxLines: 2),
        trailing: IconButton(
          iconSize: 16,
          onPressed: () => onDelete(project),
          icon: const Icon(CupertinoIcons.trash),
        ),
      );
}

class _AddProjectsView extends StatelessWidget {
  const _AddProjectsView({super.key});

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
              SliverAppBar(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                automaticallyImplyLeading: false,
                floating: true,
                title: Text(l10n.addProjects),
                actions: [
                  CloseButton(onPressed: tagsScreenNotifier.onCloseAddProjects),
                ],
              ),
              PagedSliverList<int, ProjectModel>(
                pagingController:
                    tagsScreenNotifier.addProjectsPagedController.pager,
                builderDelegate: PagedChildBuilderDelegate(
                  animateTransitions: true,
                  transitionDuration: 100.ms,
                  firstPageProgressIndicatorBuilder: (final context) =>
                      const UiCircularProgress()
                          .animate(delay: 1500.ms)
                          .fadeIn(),
                  noItemsFoundIndicatorBuilder: (final context) =>
                      Text(context.l10n.noProjectsYet).animate().fadeIn(),
                  newPageProgressIndicatorBuilder: (final context) =>
                      const UiCircularProgress()
                          .animate(delay: 1500.ms)
                          .fadeIn(),
                  itemBuilder: (final context, final item, final index) =>
                      SelectableProjectListTile(
                    key: ValueKey(item.id),
                    selected: projects.value
                            .firstWhereOrNull((final e) => e.id == item.id) !=
                        null,
                    project: item,
                    onTap: tagsScreenNotifier.onSelectedProjectChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
        SearchBar(
          trailing: [
            BackButton(
              onPressed: tagsScreenNotifier.onCloseAddProjects,
            ),
          ],
          elevation: const MaterialStatePropertyAll(8),
          hintText: l10n.searchProjects,
          onChanged: tagsScreenNotifier.onSearchAddProjects,
          padding: const MaterialStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16),
          ),
          autoFocus: true,
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
    final textTheme = context.textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.only(
            top: 8,
            left: 16,
            right: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(title, style: textTheme.titleLarge)),
              CloseButton(onPressed: onClose),
            ],
          ),
        ),
        if (isBottomBorderVisible) const Divider(),
      ],
    );
  }
}
