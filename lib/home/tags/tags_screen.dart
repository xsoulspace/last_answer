import 'package:flutter/cupertino.dart';
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
    final screenType = context.select<TagsScreenState, TagsScreenType>(
      (final c) => c.screenType,
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
    return CustomScrollView(
      slivers: [
        SliverList.builder(
          itemCount: tags.length,
          itemBuilder: (final context, final index) {
            final tag = tags[index];
            return EditableTagListTile(
              tag: tag,
              key: ValueKey(tag.id),
              onTap: () => tagsScreenNotifier.onEditTag(
                tag: tag,
              ),
            );
          },
        ),
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
    return CustomScrollView(
      slivers: [
        Text(tagId.isEmpty ? 'Create' : 'Edit' ' Folder').sliver(),
        const UiTextField(
          decoration: InputDecoration(
            labelText: 'Folder name',
          ),
        ).sliver(),
        const SliverGap(16),
        const Divider().sliver(),
        const SliverGap(16),
        const Text('Included projects').sliver(),
        const SliverGap(16),
        TextButton(
          onPressed: tagScreenNotifier.onOpenAddProjects,
          child: const Text('Add projects'),
        ),
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
                onTap: tagScreenNotifier.removeProject,
              );
            },
          ),
        const SliverGap(16),
        const Divider().sliver(),
        Row(
          children: [
            TextButton(
              onPressed: tagScreenNotifier.onCloseTagManagement,
              child: const Text('Cancel'),
            ),
            FilledButton.tonal(
              onPressed: tagScreenNotifier.onSaveTag,
              child: Text(tagId.isEmpty ? 'Create' : 'Save'),
            ),
          ],
        ).sliver(),
      ],
    );
  }
}

class ClosableProjectListTile extends StatelessWidget {
  const ClosableProjectListTile({
    required this.project,
    required this.onTap,
    super.key,
  });
  final ProjectModel project;
  final ValueChanged<ProjectModel> onTap;
  @override
  Widget build(final BuildContext context) => ListTile(
        title: Text(project.title),
        trailing: const Icon(Icons.close),
        onTap: () => onTap(project),
      );
}

class _AddProjectsView extends StatelessWidget {
  const _AddProjectsView({super.key});

  @override
  Widget build(final BuildContext context) {
    final projects = context.watch<TagsScreenNotifier>();
    return const Placeholder();
  }
}
