part of 'state.dart';

enum AppStatus {
  offline,
  online,
  loading;
}

@freezed
class AppFeaturesModel with _$AppFeaturesModel {
  const factory AppFeaturesModel({
    @Default(false) final bool isRemoteServicesEnabled,
  }) = _AppFeaturesModel;
}

@stateDistributor
class AppFeaturesNotifier extends ValueNotifier<AppFeaturesModel> {
  // ignore: avoid_unused_constructor_parameters
  AppFeaturesNotifier(final BuildContext context)
      : super(const AppFeaturesModel());
}

@freezed
class AppNotifierState with _$AppNotifierState {
  const factory AppNotifierState({
    @Default(AppStatus.loading) final AppStatus status,
  }) = _AppNotifierState;
}

class AppNotifierDto {
  AppNotifierDto(final BuildContext context)
      : projectsNotifier = context.read(),
        tagsNotifier = context.read(),
        projectsRepository = context.read(),
        tagsRepository = context.read();
  final ProjectsNotifier projectsNotifier;
  final ProjectsRepository projectsRepository;
  final TagsNotifier tagsNotifier;
  final TagsRepository tagsRepository;
}

class AppNotifier extends ValueNotifier<AppNotifierState> {
  AppNotifier(final BuildContext context)
      : dto = AppNotifierDto(context),
        super(const AppNotifierState());

  final AppNotifierDto dto;

  // TODO(arenukvern): add logic for connection change,
  void updateAppStatus(final AppStatus status) =>
      setValue(value.copyWith(status: status));

  Future<void> restoreFromDbSave({
    required final DbSaveModel dbSave,
    required final BuildContext context,
  }) async {
    final toasts = Toasts.of(context);
    final l10n = context.l10n;

    await dto.projectsRepository.putAll(projects: dbSave.projects);
    dto.tagsRepository.putAll(
      dbSave.tags.toMap(
        toKey: (final item) => item.id,
        toValue: (final item) => item,
      ),
    );
    dto.projectsNotifier.onReset();

    await Future.wait([
      dto.projectsNotifier.onLocalUserLoad(),
      dto.tagsNotifier.onLocalUserLoad(),
    ]);

    await toasts.showBottomToast(
      message: l10n.projectsFromFileRestored,
    );
  }
}
