import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/home/tags/tags.dart';

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
    final tagsScreenNotifier = context.watch<TagsScreenNotifier>();
    final textTheme = context.textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: CustomScrollView(
            shrinkWrap: true,
            slivers: [
              const DialogTopBar(title: 'Folders').sliver(),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Use 🗂️Folders for Notes and Ideas to quickly organize them. ',
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
                    onTap: () => tagsScreenNotifier.onEditTag(tag: tag),
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
                child: const Text('Cancel'),
              ),
            ),
            Expanded(
              child: FilledButton.tonal(
                onPressed: tagsScreenNotifier.onCreateTagManagement,
                child: const Text('Create folder'),
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
    super.key,
  });
  final ProjectTagModel tag;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => CupertinoListTile(
        onTap: onTap,
        title: Text(tag.title),
      );
}

class _ManageTagView extends StatelessWidget {
  const _ManageTagView();
  @override
  Widget build(final BuildContext context) {
    final tagScreenNotifier = context.watch<TagsScreenNotifier>();
    final projects = tagScreenNotifier.value.projects;
    final tagId = tagScreenNotifier.value.selectedTag.value.id;
    final textTheme = context.textTheme;

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              DialogTopBar(
                title: '${tagId.isEmpty ? 'Create' : 'Edit'} Folder',
                onClose: tagScreenNotifier.onCloseTagManagement,
                isBottomBorderVisible: false,
              ).sliver(),
              const SliverGap(4),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: UiTextField(
                  decoration: InputDecoration(
                    labelText: 'Folder name',
                  ),
                ),
              ).sliver(),
              const SliverGap(18),
              const Divider(thickness: 8).sliver(),
              const SliverGap(16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Projects',
                  style: textTheme.titleMedium,
                ),
              ).sliver(),
              const SliverGap(16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: FilledButton.icon(
                  onPressed: tagScreenNotifier.onOpenAddProjects,
                  icon: const Icon(Icons.add),
                  label: const Text('Add projects'),
                ),
              ).sliver(),
              const SliverGap(16),
              if (projects.isLoading)
                const UiCircularProgress().sliver()
              else
                SliverList.builder(
                  itemCount: projects.value.length,
                  itemBuilder: (final context, final index) {
                    final project = projects.value[index];
                    return ClosableProjectListTile(
                      project: project,
                      key: ValueKey(project.id),
                      onDelete: (final project) =>
                          tagScreenNotifier.onSelectedProjectChanged(
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
                onPressed: tagScreenNotifier.onCloseTagManagement,
                child: const Text('Cancel'),
              ),
            ),
            Expanded(
              child: FilledButton.tonal(
                onPressed: tagScreenNotifier.onSaveTag,
                child: Text(tagId.isEmpty ? 'Create' : 'Save'),
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
  final void Function(bool isSelected, ProjectModel project) onTap;
  @override
  Widget build(final BuildContext context) => ListTile(
        title: Text(project.title),
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
        title: Text(project.title, maxLines: 2),
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
    final projectsNotifier = context.watch<ProjectsNotifier>();
    final tagsScreenNotifier = context.watch<TagsScreenNotifier>();

    final projects = tagsScreenNotifier.value.projects;
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                floating: true,
                title: const Text('Add projects'),
                actions: [
                  CloseButton(onPressed: tagsScreenNotifier.onCloseAddProjects),
                ],
              ),
              PagedSliverList<int, ProjectModel>(
                pagingController:
                    projectsNotifier.projectsPagedController.pager,
                builderDelegate: PagedChildBuilderDelegate(
                  itemBuilder: (final context, final item, final index) =>
                      SelectableProjectListTile(
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
          leading: BackButton(
            onPressed: tagsScreenNotifier.onCloseAddProjects,
          ),
          elevation: const MaterialStatePropertyAll(8),
          hintText: 'Search projects',
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
