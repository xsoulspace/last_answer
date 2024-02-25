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
      : projectsRepository = context.read(),
        tagsRepository = context.read();
  final ProjectsRepository projectsRepository;
  final TagsRepository tagsRepository;
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

  Future<void> onLocalUserLoad() async =>
      projectsPagedController.loadFirstPage();

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

  final _fileService = FileService();
}

extension ProjectsNotifierX on ProjectsNotifier {
  void _setFileLoading(final bool isLoading) => setValue(
        value.copyWith(isAllProjectsFileLoading: isLoading),
      );
  Future<void> copyDbSaveToClipboard(final BuildContext context) async {
    _setFileLoading(true);
    try {
      final sharer = ProjectSharer.of(context);
      final dbSave = await _getDbSave();
      await sharer.shareSave(dbSave);
    } finally {
      _setFileLoading(false);
    }
  }

  Future<void> getDbSaveFromClipboard(final BuildContext context) async {
    _setFileLoading(true);
    try {
      final appNotifier = context.read<AppNotifier>();
      final modals = Modals.of(context);
      final l10n = context.l10n;
      final sharer = ProjectSharer.of(context);
      final dbSave = await sharer.getFromClipboard(context);
      if (dbSave.isEmpty) return;
      final shouldContinue = await modals.showWarningDialog(
        title: l10n.confirmProjectsOwerwrite,
        noActionText: l10n.cancel,
        yesActionText: l10n.confirm,
        description: l10n.beCarefulItsInreversableAction,
      );
      if (!shouldContinue) return;
      await appNotifier.restoreFromDbSave(dbSave: dbSave, context: context);
    } finally {
      _setFileLoading(false);
    }
  }

  Future<DbSaveModel> _getDbSave() async {
    final allProjects = await dto.projectsRepository.getAll();
    final allTags = dto.tagsRepository.getAll();
    return DbSaveModel(
      projects: allProjects,
      tags: allTags.values.toList(),
    );
  }

  Future<void> saveToFile(
    final BuildContext context, {
    required final bool useTimestampForBackupFilename,
  }) async {
    _setFileLoading(true);

    try {
      final toasts = Toasts.of(context);
      final l10n = context.l10n;
      final dbSave = await _getDbSave();
      final filename = useTimestampForBackupFilename
          ? FileServiceI.filenameWithTimestamp
          : FileServiceI.filename;
      final wasSaved = await _fileService.saveFile(
        data: dbSave.toJson(),
        filename: filename,
      );
      if (!wasSaved) return;
      await toasts.showBottomToast(message: l10n.fileSaved);
    } finally {
      _setFileLoading(false);
    }
  }

  Future<void> loadFromFile(final BuildContext context) async {
    _setFileLoading(true);
    final appNotifier = context.read<AppNotifier>();
    final modals = Modals.of(context);
    try {
      final l10n = context.l10n;
      bool shouldContinue = await modals.showWarningDialog(
        title: l10n.areYouSure,
        noActionText: l10n.cancel,
        yesActionText: l10n.load,
        description: l10n.byLoadingFileWarning,
      );
      if (!shouldContinue) return;
      final dbJson = await _fileService.openFile();
      if (dbJson.isEmpty) return;

      shouldContinue = await modals.showWarningDialog(
        title: l10n.confirmProjectsOwerwrite,
        noActionText: l10n.cancel,
        yesActionText: l10n.confirm,
        description: l10n.beCarefulItsInreversableAction,
      );
      if (!shouldContinue) return;
      final dbSave = DbSaveModel.fromJson(dbJson);
      if (dbSave.isEmpty) return;
      await appNotifier.restoreFromDbSave(dbSave: dbSave, context: context);
    } finally {
      _setFileLoading(false);
    }
  }
}
