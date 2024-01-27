part of 'state.dart';

enum RemoteUserNotifierStatus {
  unauthenticated,
  authenticated,
}

class UserNotifierDto {
  UserNotifierDto(final BuildContext context)
      : userRepository = context.read(),
        purchasesNotifier = context.read();

  final UserRepository userRepository;
  final PurchasesNotifier purchasesNotifier;
}

final uiLocaleNotifier = ValueNotifier(Locales.en);

class UserNotifier extends ValueNotifier<LoadableContainer<UserModel>> {
  UserNotifier({
    required this.dto,
  }) : super(const LoadableContainer(value: UserModel.empty));
  factory UserNotifier.provide(final BuildContext context) => UserNotifier(
        dto: UserNotifierDto(context),
      );
  final UserNotifierDto dto;
  late final _remoteUserNotifier = ValueNotifier(
    const LoadableContainer(value: RemoteUserModel.empty),
  )..addListener(notifyListeners);
  LoadableContainer<RemoteUserModel> get remoteValue =>
      _remoteUserNotifier.value;

  @override
  void dispose() {
    uiLocaleNotifier.dispose();
    _remoteUserNotifier
      ..removeListener(notifyListeners)
      ..dispose();
    return super.dispose();
  }

  bool get isAuthorized =>
      _remoteUserNotifier.value.isLoaded &&
      _remoteUserNotifier.value.value.isNotEmpty;
  Future<void> loadRemoteUser({final bool isAfterLogin = false}) async {
    if (isAfterLogin) await dto.userRepository.completeRemoteLogin();
    final user = await dto.userRepository.getRemoteUser();
    _remoteUserNotifier.setValue(LoadableContainer.loaded(user));
  }

  void logout() {
    resetRemoteUser();
    unawaited(dto.userRepository.logout());
  }

  void resetRemoteUser() => _remoteUserNotifier
      .setValue(const LoadableContainer(value: RemoteUserModel.empty));

  bool get isLoaded => value.isLoaded;
  bool get isLoading => value.isLoading;
  UserModel get user => value.value;
  UserSettingsModel get settings => user.settings;
  ValueListenable<Locale> get locale => uiLocaleNotifier;
  bool get hasCompletedOnboarding => user.hasCompletedOnboarding;
  Future<void> onLoad({
    required final UserInitializer local,
    required final RemoteUserInitializer remote,
  }) async {
    value = LoadableContainer.loaded(await dto.userRepository.getLocalUser());

    unawaited(local.onUserLoad());
    unawaited(remote.onUserLoad());
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
