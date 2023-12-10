part of 'state.dart';

class UserNotifierDto {
  UserNotifierDto(final BuildContext context) : userRepository = context.read();

  final UserRepository userRepository;
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
  @override
  void dispose() {
    uiLocaleNotifier.dispose();
    return super.dispose();
  }

  bool get isLoaded => value.isLoaded;
  bool get isLoading => value.isLoading;
  bool get isAuthorized => false;
  UserModel get user => value.value;
  UserSettingsModel get settings => user.settings;
  ValueListenable<Locale> get locale => uiLocaleNotifier;
  bool get hasCompletedOnboarding => user.hasCompletedOnboarding;
  Future<void> onLoad(final UserInitializer initializer) async {
    value = LoadableContainer.loaded(await dto.userRepository.getUser());
    unawaited(initializer.onUserLoad());
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
    unawaited(dto.userRepository.putUser(user: user));
  }
}
