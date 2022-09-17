part of 'projects_list.dart';

_ProjectsListViewState _useProjectsListState() => use(
      ContextfulLifeHook(
        debugLabel: 'ProjectsListViewState',
        state: _ProjectsListViewState(),
      ),
    );

class _ProjectsListViewState extends ContextfulLifeState {
  _ProjectsListViewState();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void onProjectTap(final BasicProject<BasicProjectModel> project) => context
      .read<AppRouterController>()
      .onProjectTap(project: project, context: context);
  bool checkIsProjectActive(final BasicProject<BasicProjectModel> project) =>
      context.read<AppRouterController>().checkIsProjectActive(
            project: project,
            read: context.read,
          );
  void onGoHome() => context.read<AppRouterController>().toHome();
}
