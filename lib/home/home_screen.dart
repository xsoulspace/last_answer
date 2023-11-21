import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/home/project_view.dart';
import 'package:lastanswer/pack_app/screens/home/vertical_projects_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.navigator,
    super.key,
  });
  final Widget navigator;
  @override
  Widget build(final BuildContext context) {
    final screenLayout = ScreenLayout.of(context);
    if (screenLayout.small) {
      return navigator;
    }
    return Row(
      children: [
        const _ProjectsListView(),
        Expanded(
          child: Row(
            children: [
              const _VerticalBar(),
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
  Widget build(final BuildContext context) => const Row(
        children: [
          _ProjectsListView(),
          _VerticalBar(),
        ],
      );
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
    final child = Column(
      children: [
        Flexible(
          child: PagedListView<int, ProjectModel>.separated(
            pagingController: projectsController.pager,
            reverse: isReversed,
            builderDelegate: PagedChildBuilderDelegate(
              itemBuilder: (final context, final item, final index) => ListTile(
                leading: switch (item.type) {
                  ProjectTypes.idea => const IconIdeaButton(),
                  ProjectTypes.note => IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.book),
                    ),
                },
                title: Text(item.title),
                onTap: () {
                  projectNotifier.loadProject(project: item, context: context);
                },
                selected: openedProjectId == item.id,
              ),
            ),
            separatorBuilder: (final context, final index) => const Row(
              children: [
                Gap(64),
                Expanded(
                  child: Divider(height: 0),
                ),
              ],
            ),
          ),
        ),
      ],
    );
    final screenLayout = ScreenLayout.of(context);

    if (PlatformInfo.isNativeWebMobile || screenLayout.small) {
      return Expanded(child: child);
    } else {
      final width = MediaQuery.sizeOf(context).width * 0.3;
      return Container(
        constraints: const BoxConstraints(
          maxWidth: 270,
        ),
        width: width,
        child: child,
      );
    }
  }
}
