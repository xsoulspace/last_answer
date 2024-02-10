part of 'state.dart';

enum RemoteUserNotifierStatus {
  unauthenticated,
  authenticated,
}

class UserNotifierDto {
  UserNotifierDto(final BuildContext context)
      : userRepository = context.read(),
        purchasesNotifier = context.read(),
        remoteUserNotifier = context.read(),
        appFeaturesNotifier = context.read();
  final UserRepository userRepository;
  final PurchasesNotifier purchasesNotifier;
  final RemoteUserNotifier remoteUserNotifier;
  final AppFeaturesNotifier appFeaturesNotifier;
}

final uiLocaleNotifier = ValueNotifier(Locales.en);

@stateDistributor
class RemoteUserNotifier
    extends ValueNotifier<LoadableContainer<RemoteUserModel>> {
  // ignore: avoid_unused_constructor_parameters
  RemoteUserNotifier(final BuildContext context)
      : super(const LoadableContainer(value: RemoteUserModel.empty));
  bool get isAuthorized => value.isLoaded && value.value.isNotEmpty;
}

class UserNotifier extends ValueNotifier<LoadableContainer<UserModel>> {
  UserNotifier(final BuildContext context)
      : dto = UserNotifierDto(context),
        super(const LoadableContainer(value: UserModel.empty));
  final UserNotifierDto dto;

  @override
  void dispose() {
    uiLocaleNotifier.dispose();
    return super.dispose();
  }

  Future<void> loadRemoteUser({final bool isAfterLogin = false}) async {
    if (isAfterLogin) await dto.userRepository.completeRemoteLogin();
    final user = await dto.userRepository.getRemoteUser();
    dto.remoteUserNotifier.setValue(LoadableContainer.loaded(user));
  }

  void logout() {
    resetRemoteUser();
    unawaited(dto.userRepository.logout());
  }

  void resetRemoteUser() => dto.remoteUserNotifier
      .setValue(const LoadableContainer(value: RemoteUserModel.empty));

  bool get isLoaded => value.isLoaded;
  bool get isLoading => value.isLoading;
  UserModel get user => value.value;
  UserSettingsModel get settings => user.settings;
  ValueListenable<Locale> get locale => uiLocaleNotifier;
  bool get hasCompletedOnboarding => user.hasCompletedOnboarding;
  Future<void> onLoad({
    required final LocalUserInitializer local,
    required final RemoteUserInitializer remote,
  }) async {
    value = LoadableContainer.loaded(await dto.userRepository.getLocalUser());
    unawaited(local.onUserLoad());
    if (dto.appFeaturesNotifier.value.isRemoteServicesEnabled) {
      await loadRemoteUser();
    }
  }

  Future<void> deleteRemoteUser() async {
    await dto.userRepository.deleteRemoteUser();
    resetRemoteUser();
  }

  void completeOnboarding() => _updateUser(
        (final user) =>
            user.copyWith(hasCompletedOnboarding: hasCompletedOnboarding),
      );
  void updateCharactersLimitForNewNotes(final int newLimit) => _updateSettings(
        (final settings) =>
            settings.copyWith(charactersLimitForNewNotes: newLimit),
      );
  void updateThemeMode(final ThemeMode? themeMode) {
    if (themeMode == null) return;
    _updateSettings(
      (final settings) => settings.copyWith(themeMode: themeMode),
    );
  }

  void updateIsProjectsReversed({required final bool isReversed}) =>
      _updateSettings(
        (final settings) => settings.copyWith(
          isProjectsListReversed: isReversed,
        ),
      );

  Future<void> updateLocale(final Locale? locale) async {
    final result = await LocaleLogic().updateLocale(
      newLocale: locale,
      oldLocale: settings.locale,
      uiLocale: uiLocaleNotifier.value,
    );
    if (result == null) return;
    uiLocaleNotifier.value = result.uiLocale;
    notifyListeners();
    _updateSettings(
      (final settings) => settings.copyWith(locale: result.updatedLocale),
    );
  }

  void _updateSettings(
    final UserSettingsModel Function(UserSettingsModel) updateSettings,
  ) =>
      _updateUser(
        (final user) => user.copyWith(settings: updateSettings(settings)),
      );
  void updateLocalDbVersion(final LocalDbVersion dbVersion) => _updateUser(
        (final user) => user.copyWith(localDbVersion: dbVersion),
      );
  void _updateUser(final UserModel Function(UserModel) updateUser) {
    setValue(value.copyWith(value: updateUser(value.value)));
    unawaited(dto.userRepository.putLocalUser(user: user));
  }
}
