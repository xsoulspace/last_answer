import 'dart:math' as math;

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/home/project_view.dart';
import 'package:lastanswer/home/tags/tags.dart';
import 'package:lastanswer/home/widgets/widgets.dart';
import 'package:lastanswer/idea/create_idea_screen.dart';
import 'package:lastanswer/other/other.dart';
import 'package:lastanswer/settings/settings.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.navigator,
    super.key,
  });
  final Widget navigator;
  @override
  Widget build(final BuildContext context) {
    final screenLayout = ScreenLayout.of(context);
    if (screenLayout.small) return navigator;

    return Row(
      children: [
        const _ProjectsListView(),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Builder(
                  builder: (final context) => AnimatedContainer(
                    duration: 250.milliseconds,
                    constraints: const BoxConstraints(
                      minWidth: 300,
                      maxWidth: 700,
                    ),
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        vertical: BorderSide(
                          color: context.theme.colorScheme.onSecondary,
                        ),
                      ),
                    ),
                    child: const ProjectView(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VerticalBar extends StatelessWidget {
  const _VerticalBar();

  @override
  Widget build(final BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Expanded(child: TagsVerticalBar()),
            VerticalProjectsBar(
              onIdeaTap: () async {
                await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (final context) => const CreateIdeaProjectScreen(),
                    fullscreenDialog: true,
                  ),
                );
              },
              onNoteTap: () {
                context
                    .read<OpenedProjectNotifier>()
                    .createNoteProject(context);
              },
            ),
          ],
        ),
      );
}

class TagsVerticalBar extends StatelessWidget {
  const TagsVerticalBar({super.key});

  @override
  Widget build(final BuildContext context) {
    final projectsNotifier = context.read<ProjectsNotifier>();
    final selectedTagId = context.select<ProjectsNotifier, ProjectTagModelId>(
      (final c) => c.selectedTagId,
    );
    final tagsNotifier = context.watch<TagsNotifier>();
    final tags = tagsNotifier.values;
    void chooseTag([final ProjectTagModel? tag]) => projectsNotifier.updateDto(
          (final dto) => dto.copyWith(
            tagId: tag?.id ?? ProjectTagModelId.empty,
          ),
        );
    final l10n = context.l10n;

    return Column(
      children: [
        const Gap(8),
        IconButton.outlined(
          onPressed: () async => showAdaptiveDialog(
            context: context,
            barrierDismissible: true,
            builder: (final context) => Dialog(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 600,
                  maxWidth: 400,
                  minWidth: 200,
                  minHeight: 150,
                ),
                child: const TagsScreen(),
              ),
            ),
          ),
          icon: const Icon(Icons.edit_square),
          tooltip: l10n.clickToEditFolders,
        ),
        const Gap(8),
        Expanded(
          child: ListView.builder(
            itemCount: tags.length + 1,
            shrinkWrap: true,
            itemBuilder: (final context, final index) {
              final isFirst = index == 0;
              final correctedIndex = index - 1;
              if (isFirst) {
                return _TagListTile(
                  selectedTagId: selectedTagId,
                  onTap: chooseTag,
                  tag: ProjectTagModel.empty,
                );
              }
              final tag = tags[correctedIndex];
              return _TagListTile(
                key: ValueKey(tag.id),
                tag: tag,
                selectedTagId: selectedTagId,
                onTap: () => chooseTag(tag),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TagListTile extends StatelessWidget {
  const _TagListTile({
    required this.tag,
    required this.onTap,
    required this.selectedTagId,
    super.key,
  });
  final ProjectTagModel tag;
  final VoidCallback onTap;
  final ProjectTagModelId selectedTagId;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 0,
      dense: true,
      titleTextStyle: context.textTheme.labelSmall,
      title:
          Text(tag.isEmpty ? l10n.all : tag.title, textAlign: TextAlign.center),
      // ignore: avoid_bool_literals_in_conditional_expressions
      selected:
          tag.isEmpty && selectedTagId.isEmpty ? true : tag.id == selectedTagId,
      onTap: onTap,
    );
  }
}

class ProjectsListScreen extends StatelessWidget {
  const ProjectsListScreen({super.key});

  @override
  Widget build(final BuildContext context) => const _ProjectsListView();
}

class _ProjectsListView extends StatelessWidget {
  const _ProjectsListView();

  @override
  Widget build(final BuildContext context) {
    final projectsNotifier = context.read<ProjectsNotifier>();
    final projectNotifier = context.read<OpenedProjectNotifier>();

    final projectsController = projectsNotifier.projectsPagedController;
    final isReversed = context.select<UserNotifier, bool>(
      (final c) => c.settings.isProjectsListReversed,
    );
    final openedProjectId =
        context.select<OpenedProjectNotifier, ProjectModelId>(
      (final c) => c.value.value.id,
    );
    final Widget child = Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              projectsController
                ..refresh()
                ..loadFirstPage();
            },
            child: PagedListView<int, ProjectModel>(
              pagingController: projectsController.pager,
              reverse: isReversed,
              builderDelegate: PagedChildBuilderDelegate(
                animateTransitions: true,
                transitionDuration: 100.ms,
                firstPageProgressIndicatorBuilder: (final context) =>
                    const UiCircularProgress().animate(delay: 1500.ms).fadeIn(),
                noItemsFoundIndicatorBuilder: (final context) =>
                    Text(context.l10n.noProjectsYet).animate().fadeIn(),
                newPageProgressIndicatorBuilder: (final context) =>
                    const UiCircularProgress().animate(delay: 1500.ms).fadeIn(),
                itemBuilder: (final context, final item, final index) =>
                    ProjectTile(
                  onRemove: (final _) async {
                    final shouldProceed = await showRemoveTitleDialog(
                      context: context,
                      title: item.getTitle(context),
                    );
                    if (shouldProceed) {
                      projectsNotifier.deleteProject(item);
                    }
                  },
                  project: item,
                  onTap: (final item) {
                    projectNotifier.loadProject(
                      project: item,
                      context: context,
                    );
                  },
                  selected: openedProjectId == item.id,
                ),
              ),
            ),
          ),
        ),
      ],
    );
    final appBar = HomeAppBar(
      onInfoTap: () async => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (final context) => const AppInfoScreen(),
          fullscreenDialog: true,
        ),
      ),
      onSettingsTap: () async => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (final context) => const SettingsScreen(),
          fullscreenDialog: true,
        ),
      ),
    );
    final screenLayout = ScreenLayout.of(context);
    if (PlatformInfo.isNativeWebMobile || screenLayout.small) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => closeKeyboard(context: context),
        child: Column(
          children: [
            appBar,
            Expanded(
              child: Row(
                children: [
                  const _VerticalBar(),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      final double width =
          math.max(200, MediaQuery.sizeOf(context).width * 0.3);
      return AnimatedContainer(
        duration: 250.milliseconds,
        constraints: const BoxConstraints(
          maxWidth: 270,
        ),
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            appBar,
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: child),
                  const _VerticalBar(),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
