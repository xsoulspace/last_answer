import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/home/project_view.dart';
import 'package:lastanswer/pack_app/screens/home/vertical_projects_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    final screenLayout = ScreenLayout.of(context);
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
        const _ProjectsListView(),
        if (screenLayout.notSmall)
          Expanded(
            child: Row(
              children: [
                verticalColumn,
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
          )
        else
          verticalColumn,
      ],
    );
  }
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
    final width = MediaQuery.sizeOf(context).width * 0.3;
    return Container(
      constraints: BoxConstraints(
        maxWidth: PlatformInfo.isNativeWebMobile ? double.infinity : 270,
      ),
      width: width,
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
    );
  }
}
