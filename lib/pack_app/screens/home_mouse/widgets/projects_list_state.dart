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

  void onProjectTap(final BasicProject<BasicProjectModel> project) =>
      getContext()
          .read<AppRouterController>()
          .onProjectTap(project: project, context: getContext());
  bool checkIsProjectActive(final BasicProject<BasicProjectModel> project) =>
      getContext().read<AppRouterController>().checkIsProjectActive(
            project: project,
            read: getContext().read,
          );
  void onGoHome() => getContext().read<AppRouterController>().toHome();
}
