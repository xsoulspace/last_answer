import 'package:lastanswer/common_imports.dart';
import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';

/// Restore the addressed item through the existing local repository. A URL
/// must never render a differently addressed item.
class ProjectRoute extends StatefulWidget {
  const ProjectRoute({
    required this.projectId,
    required this.projectType,
    required this.builder,
    super.key,
  });

  final String projectId;
  final ProjectTypes projectType;
  final Widget Function(BuildContext context, ProjectModel project) builder;

  @override
  State<ProjectRoute> createState() => _ProjectRouteState();
}

class _ProjectRouteState extends State<ProjectRoute> {
  late Future<bool> _restored;
  int _generation = 0;
  GoRouter? _router;
  ProjectModel? _project;

  String get _path => switch (widget.projectType) {
    ProjectTypes.note => '/home/n/${widget.projectId}',
    ProjectTypes.idea => '/home/i/${widget.projectId}',
    ProjectTypes.doc => '/home/d/${widget.projectId}',
    ProjectTypes.systemChangelog => ScreenPaths.changelog,
  };

  bool get _active =>
      _router
          ?.routerDelegate
          .currentConfiguration
          .lastOrNull
          ?.matchedLocation ==
      _path;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = GoRouter.of(context);
    if (identical(_router, router)) return;
    _router?.routerDelegate.removeListener(_routeChanged);
    _router = router;
    router.routerDelegate.addListener(_routeChanged);
    _restored = _restore();
  }

  void _routeChanged() {
    if (_active) {
      final selected = context.read<OpenedProjectNotifier>().value.value;
      if (_project?.id.value == widget.projectId &&
          selected.id.value == widget.projectId &&
          selected.type == widget.projectType) {
        return;
      }
      setState(() {
        _restored = _restore();
      });
    } else {
      // Older pages can remain mounted in the navigator stack.
      _generation++;
    }
  }

  @override
  void didUpdateWidget(ProjectRoute oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectId != widget.projectId ||
        oldWidget.projectType != widget.projectType) {
      _project = null;
      _restored = _restore();
    }
  }

  Future<bool> _restore() async {
    final generation = ++_generation;
    if (!_active) return false;
    final id = widget.projectId;
    final type = widget.projectType;
    final opened = context.read<OpenedProjectNotifier>();
    if (!opened.value.isLoading && opened.value.value.id.value == id) {
      if (opened.value.value.type != type) return false;
      _project = opened.value.value;
      return true;
    }
    try {
      final project = await context.read<ProjectsRepository>().getById(
        id: ProjectModelId(id),
      );
      if (!mounted ||
          !_active ||
          generation != _generation ||
          project?.type != type ||
          project?.id.value != id) {
        return false;
      }
      _project = project;
      opened.value = LoadableContainer.loaded(project!);
      return true;
    } on Object {
      return false;
    }
  }

  @override
  void dispose() {
    _generation++;
    _router?.routerDelegate.removeListener(_routeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = context.watch<OpenedProjectNotifier>().value;
    if (!selected.isLoading &&
        selected.value.id.value == widget.projectId &&
        selected.value.type == widget.projectType) {
      _project = selected.value;
    }
    return FutureBuilder<bool>(
      future: _restored,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done &&
            _project == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != true) {
          return Center(
            child: Text(switch (Localizations.localeOf(context).languageCode) {
              'it' => 'Impossibile aprire questo elemento.',
              'ru' => 'Не удалось открыть этот элемент.',
              _ => 'This item could not be opened.',
            }, key: const Key('project_route.unavailable')),
          );
        }
        return widget.builder(context, _project!);
      },
    );
  }
}
