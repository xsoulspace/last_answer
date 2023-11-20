import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/home/project_view.dart';
import 'package:lastanswer/pack_app/screens/home/vertical_projects_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    final projectsNotifier = context.read<ProjectsNotifier>();
    final projectNotifier = context.read<OpenedProjectNotifier>();

    final projectsController = projectsNotifier.projectsPagedController;
    final screenLayout = ScreenLayout.of(context);
    final isReversed = context.select<UserNotifier, bool>(
      (final c) => c.settings.isProjectsListReversed,
    );
    final openedProjectId =
        context.select<OpenedProjectNotifier, ProjectModelId>(
      (final c) => c.value.value.id,
    );
    final verticalColumn = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        VerticalProjectsBar(
          onIdeaTap: () {},
          onNoteTap: () {},
        ),
      ],
    );
    return Row(
      children: [
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: ScreenLayout.maxSmallWidth - 100,
            ),
            child: Column(
              children: [
                Flexible(
                  child: PagedListView<int, ProjectModel>.separated(
                    pagingController: projectsController.pager,
                    reverse: isReversed,
                    builderDelegate: PagedChildBuilderDelegate(
                      itemBuilder: (final context, final item, final index) =>
                          ListTile(
                        leading: switch (item.type) {
                          ProjectTypes.idea => const IconIdeaButton(),
                          ProjectTypes.note => IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.book),
                            ),
                        },
                        title: Text(item.title),
                        onTap: () {
                          projectNotifier.loadProject(item);
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
            ),
          ),
        ),
        if (screenLayout.notSmall)
          Flexible(
            child: Row(
              children: [
                verticalColumn,
                Expanded(
                  child: Builder(
                    builder: (final context) => Container(
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
          )
        else
          verticalColumn,
      ],
    );
  }
}
