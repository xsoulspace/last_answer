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
    final projectsController = projectsNotifier.projectsPagedController;
    final screenLayout = ScreenLayout.of(context);
    final isReversed = context.select<UserNotifier, bool>(
      (final c) => c.settings.isProjectsListReversed,
    );
    final openedProjectId =
        context.select<OpenedProjectNotifier, ProjectModelId>(
      (final c) => c.value.value.id,
    );
    return Row(
      children: [
        Column(
          mainAxisAlignment: PlatformInfo.isNativeWebMobile
              ? MainAxisAlignment.end
              : MainAxisAlignment.center,
          children: [
            VerticalProjectsBar(
              onIdeaTap: () {},
              onNoteTap: () {},
            ),
          ],
        ),
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
                        title: Text(item.title),
                        onTap: () {},
                        selected: openedProjectId == item.id,
                      ),
                    ),
                    separatorBuilder: (final context, final index) =>
                        const Divider(height: 0),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (screenLayout.notSmall) const Expanded(child: ProjectView()),
      ],
    );
  }
}
