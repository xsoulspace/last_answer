part of 'state.dart';

@freezed
abstract class ProjectsNotifierState with _$ProjectsNotifierState {
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
      );
  List<IdeaProjectQuestionModel> get ideaQuestions => ideaQuestionsData;
  ProjectTagModelId get selectedTagId => value.requestProjectsDto.tagId;
  final _fileService = FileService();
  late final _editingProjectUpdatesController =
      StreamController<ProjectModel>();

  StreamSubscription<ProjectModel>? _updatesSubscription;

  Future<void> onLocalUserLoad() async {
    _updatesSubscription ??= _editingProjectUpdatesController.stream.listen(
      updateProject,
    );

    projectsPagedController.loadFirstPage();
  }

  void onReset() => projectsPagedController.refresh();

  void updateDto(
    final RequestProjectsDto Function(RequestProjectsDto dto) updater,
  ) {
    final updatedDto = updater(value.requestProjectsDto);
    if (updatedDto == value.requestProjectsDto) return;
    value = value.copyWith(requestProjectsDto: updatedDto);
    projectsPagedController
      ..refresh()
      ..loadFirstPage();
  }

  void updateEditingProject(
    final ProjectModel project, {
    final bool shouldMarkAsUpdated = true,
  }) => _editingProjectUpdatesController.add(
    project.copyWith(
      updatedAt: shouldMarkAsUpdated ? DateTime.now() : project.updatedAt,
    ),
  );

  void deleteProject(final ProjectModel project) {
    projectsPagedController.pager.removeElement(
      element: project,
      test: (final e) => e.id == project.id,
    );
    unawaited(dto.projectsRepository.remove(id: project.id));
  }

  Future<void> updateProject(final ProjectModel project) async {
    final oldProject = await dto.projectsRepository.getById(id: project.id);
    final shouldMoveToFirst = oldProject?.updatedAt != project.updatedAt;
    projectsPagedController.pager.replaceElement(
      element: project,
      equals: (final e, final e2) => e.id == e2.id,
      shouldAddOnNotFound: true,
      shouldMoveToFirst: shouldMoveToFirst,
    );
    unawaited(dto.projectsRepository.put(project: project));
  }

  Future<void> updateProjects(
    final Iterable<ProjectModel> projects, {
    final bool shouldUpdatePager = true,
  }) async {
    final oldProjects = await dto.projectsRepository.getByIds(
      ids: projects.map((final e) => e.id),
    );
    final oldProjectsMap = oldProjects.toMap(
      toKey: (final v) => v.id,
      toValue: (final v) => v,
    );
    if (shouldUpdatePager) {
      for (final project in projects) {
        final oldProject = oldProjectsMap[project.id];
        final shouldMoveToFirst = oldProject?.updatedAt != project.updatedAt;
        projectsPagedController.pager.replaceElement(
          element: project,
          equals: (final e, final e2) => e.id == e2.id,
          shouldAddOnNotFound: true,
          shouldMoveToFirst: shouldMoveToFirst,
        );
      }
    }

    await dto.projectsRepository.putAll(projects: projects.toList());
  }

  @override
  Future<void> dispose() async {
    await _updatesSubscription?.cancel();
    await _editingProjectUpdatesController.close();
    projectsPagedController.dispose();
    super.dispose();
  }
}

extension ProjectsNotifierX on ProjectsNotifier {
  void _setFileLoading(final bool isLoading) =>
      setValue(value.copyWith(isAllProjectsFileLoading: isLoading));
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
      final l10n = context.l10n;
      final sharer = ProjectSharer.of(context);
      final dbSave = await sharer.getFromClipboard(context);
      if (dbSave.isEmpty) return;
      final shouldContinue = await showLaConfirm(
        context,
        title: l10n.confirmProjectsOwerwrite,
        message: l10n.beCarefulItsInreversableAction,
        confirmLabel: l10n.confirm,
        cancelLabel: l10n.cancel,
      );
      if (!shouldContinue) return;
      await appNotifier.restoreFromDbSave(dbSave: dbSave, context: context);
    } finally {
      _setFileLoading(false);
    }
  }

  Future<DbSaveModel> _getDbSave() async {
    final allProjects = await dto.projectsRepository.getAll();
    final allTags = await dto.tagsRepository.getAll();
    return DbSaveModel(projects: allProjects, tags: allTags.values.toList());
  }

  Future<void> saveToFile(
    final BuildContext context, {
    required final bool useTimestampForBackupFilename,
    final Future<List<BackupAssetFile>> Function(DbSaveModel dbSave)?
    collectAssets,
  }) async {
    _setFileLoading(true);

    try {
      final l10n = context.l10n;
      final dbSave = await _getDbSave();
      final jsonName = useTimestampForBackupFilename
          ? FileServiceI.filenameWithTimestamp
          : FileServiceI.filename;
      // The asset-carrying backup is a ZIP (dbSave.json + assets/ —
      // native-image-assets Wave D1); a collectAssets sink that finds
      // no files keeps the legacy JSON path byte-identical.
      final files = await collectAssets?.call(dbSave) ?? const [];
      final zipBytes = BackupZip.encode(
        dbSaveJson: dbSave.toJson(),
        files: files,
      );
      final bool wasSaved;
      if (zipBytes == null) {
        wasSaved = await _fileService.saveFile(
          data: dbSave.toJson(),
          filename: jsonName,
        );
      } else {
        wasSaved = await _fileService.saveFileBytes(
          bytes: zipBytes,
          filename: jsonName.replaceFirst('.json', '.zip'),
        );
      }
      if (!wasSaved) return;
      LaToast.info(context, l10n.fileSaved);
    } finally {
      _setFileLoading(false);
    }
  }

  Future<void> loadFromFile(
    final BuildContext context, {
    final Future<int> Function(List<BackupAssetFile> files)? restoreAssets,
  }) async {
    _setFileLoading(true);
    final appNotifier = context.read<AppNotifier>();
    try {
      final l10n = context.l10n;
      bool shouldContinue = await showLaConfirm(
        context,
        title: l10n.areYouSure,
        message: l10n.byLoadingFileWarning,
        confirmLabel: l10n.load,
        cancelLabel: l10n.cancel,
      );
      if (!shouldContinue) return;
      final backupBytes = await _fileService.openFileBytes();
      if (backupBytes == null || backupBytes.isEmpty) return;
      final isZip = backupBytes.length >= 4 &&
          backupBytes[0] == 0x50 &&
          backupBytes[1] == 0x4b &&
          backupBytes[2] == 0x03 &&
          backupBytes[3] == 0x04;

      shouldContinue = await showLaConfirm(
        context,
        title: l10n.confirmProjectsOwerwrite,
        message: l10n.beCarefulItsInreversableAction,
        confirmLabel: l10n.confirm,
        cancelLabel: l10n.cancel,
      );
      if (!shouldContinue) return;
      // The zip magic (`PK\x03\x04`) separates the asset-carrying
      // backup from the legacy JSON one — both stay loadable forever.
      // Zip asset files restore through the app-side sink; a JSON
      // backup (or an absent sink) restores rows only, and rows whose
      // files are missing keep the honest placeholder.
      List<BackupAssetFile> assetFiles = const [];
      final DbSaveModel dbSave;
      if (isZip) {
        final bundle = BackupZip.decode(backupBytes);
        dbSave = DbSaveModel.fromJson(bundle.dbSaveJson);
        assetFiles = bundle.files;
      } else {
        dbSave = DbSaveModel.fromJson(
          const JsonDecoder().convert(
                const Utf8Decoder().convert(backupBytes.toList()),
              )
              as Map<String, dynamic>,
        );
      }
      if (dbSave.isEmpty) return;
      await appNotifier.restoreFromDbSave(dbSave: dbSave, context: context);
      if (restoreAssets != null && assetFiles.isNotEmpty) {
        await restoreAssets(assetFiles);
      }
    } finally {
      _setFileLoading(false);
    }
  }
}
