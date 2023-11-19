import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lastanswer/common_imports.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    final projectsNotifier = context.read<ProjectsNotifier>();
    final projectsController = projectsNotifier.projectsPagedController;
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Flexible(
                child: PagedListView<int, ProjectModel>.separated(
                  pagingController: projectsController.pager,
                  builderDelegate: PagedChildBuilderDelegate(
                    itemBuilder: (final context, final item, final index) =>
                        ListTile(
                      title: Text(item.title),
                    ),
                  ),
                  separatorBuilder: (final context, final index) =>
                      const SizedBox(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
