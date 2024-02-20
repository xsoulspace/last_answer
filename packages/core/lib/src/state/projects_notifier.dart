part of 'state.dart';

@freezed
class ProjectsNotifierState with _$ProjectsNotifierState {
  const factory ProjectsNotifierState({
    @Default(RequestProjectsDto.empty)
    final RequestProjectsDto requestProjectsDto,
    @Default(false) final bool isAllProjectsFileLoading,
  }) = _ProjectsNotifierState;
}

class ProjectsNotifierDto {
  ProjectsNotifierDto(final BuildContext context)
      : projectsRepository = context.read();
  final ProjectsRepository projectsRepository;
}

class ProjectsNotifier extends ValueNotifier<ProjectsNotifierState> {
  ProjectsNotifier(final BuildContext context)
      : dto = ProjectsNotifierDto(context),
        super(const ProjectsNotifierState());

  final ProjectsNotifierDto dto;
  late final ProjectsPagedController projectsPagedController =
      ProjectsPagedController(
    requestBuilder: ProjectsPagedDataRequestsBuilder.getAll(
      projectsRepository: dto.projectsRepository,
      getDto: () => value.requestProjectsDto,
    ),
  )..onLoad();
  List<IdeaProjectQuestionModel> get ideaQuestions => ideaQuestionsData;

  Future<void> onLocalUserLoad() async {
    projectsPagedController.loadFirstPage();
  }

  final _fileService = FileService();
  void _setFileLoading(final bool isLoading) => setValue(
        value.copyWith(isAllProjectsFileLoading: isLoading),
      );
  Future<void> saveToFile(
    final BuildContext context, {
    required final bool useTimestampForBackupFilename,
  }) async {
    _setFileLoading(true);

    try {
      final toasts = Toasts.of(context);

      final allProjects = await dto.projectsRepository.getAll();
      final allProjectsJson = allProjects.map((final e) => e.toJson()).toList();
      final filename = useTimestampForBackupFilename
          ? FileServiceI.filenameWithTimestamp
          : FileServiceI.filename;
      final wasSaved = await _fileService.saveFile(
        data: allProjectsJson,
        filename: filename,
      );
      if (!wasSaved) return;
      await toasts.showBottomToast(message: 'File saved!');
    } finally {
      _setFileLoading(false);
    }
  }

  Future<void> loadFromFile(final BuildContext context) async {
    _setFileLoading(true);
    final toasts = Toasts.of(context);
    final modals = Modals.of(context);
    try {
      final l10n = context.l10n;
      bool shouldContinue = await modals.showWarningDialog(
        title: l10n.areYouSure,
        noActionText: 'Cancel',
        yesActionText: 'Load',
        description:
            'By loading this file you will overwrite all current projects in the app. \nBe careful, it is not reversable action!',
      );
      if (!shouldContinue) return;
      final jsonList = await _fileService.openFile();
      if (jsonList.isEmpty) return;

      shouldContinue = await modals.showWarningDialog(
        title: 'Confirm projects owerwrite',
        noActionText: 'Cancel',
        yesActionText: 'Confirm',
        description: 'Be careful, as it is not reversable action!',
      );
      if (!shouldContinue) return;
      final allProjects = jsonList.map(ProjectModel.fromJson).toList();

      await dto.projectsRepository.putAll(projects: allProjects);
      onReset();
      await onLocalUserLoad();
      await toasts.showBottomToast(
        message: 'Projects from file restored.',
      );
    } finally {
      _setFileLoading(false);
    }
  }

  void onReset() => projectsPagedController.refresh();

  void updateProject(final ProjectModel project) {
    _projectsUpdatesController.add(project.copyWith(updatedAt: DateTime.now()));
  }

  void deleteProject(final ProjectModel project) {
    projectsPagedController.pager.removeElement(
      element: project,
      test: (final e) => e.id == project.id,
    );
    unawaited(dto.projectsRepository.remove(id: project.id));
  }

  late final _projectsUpdatesController = StreamController<ProjectModel>()
    ..stream.sampleTime(1.seconds).listen(_updateProject);
  void _updateProject(final ProjectModel project) {
    projectsPagedController.pager.replaceElement(
      element: project,
      equals: (final e, final e2) => e.id == e2.id,
      shouldAddOnNotFound: true,
      shouldMoveToFirst: true,
    );
    unawaited(dto.projectsRepository.put(project: project));
  }

  @override
  void dispose() {
    unawaited(_projectsUpdatesController.close());
    projectsPagedController.dispose();
    super.dispose();
  }
}
