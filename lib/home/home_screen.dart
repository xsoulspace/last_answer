import 'dart:math' as math;

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/home/project_view.dart';
import 'package:lastanswer/pack_app/pack_app.dart';
import 'package:lastanswer/pack_app/widgets/widgets.dart';

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
                    padding: const EdgeInsets.only(left: 24),
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
  Widget build(final BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          VerticalProjectsBar(
            onIdeaTap: () {},
            onNoteTap: () {
              context.read<OpenedProjectNotifier>().createNoteProject(context);
            },
          ),
        ],
      );
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
        Flexible(
          child: PagedListView<int, ProjectModel>(
            pagingController: projectsController.pager,
            reverse: isReversed,
            builderDelegate: PagedChildBuilderDelegate(
              itemBuilder: (final context, final item, final index) =>
                  ProjectTile(
                onRemove: (final _) async {
                  await showRemoveTitleDialog(
                    context: context,
                    title: item.title,
                  );
                },
                project: item,
                onTap: (final item) {
                  projectNotifier.loadProject(project: item, context: context);
                },
                selected: openedProjectId == item.id,
              ),
            ),
          ),
        ),
      ],
    );
    final appBar = HomeAppBar(
      onInfoTap: () async => context.go(ScreenPaths.appInfo),
      onSettingsTap: () async => context.go(ScreenPaths.settings),
    );
    final screenLayout = ScreenLayout.of(context);
    if (PlatformInfo.isNativeWebMobile || screenLayout.small) {
      return Column(
        children: [
          appBar,
          Expanded(
            child: Row(
              children: [
                Expanded(child: child),
                const _VerticalBar(),
              ],
            ),
          ),
        ],
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
