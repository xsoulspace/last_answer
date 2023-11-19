import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core.dart';
import 'logic/locale_logic.dart';

class UserNotifierDto {
  UserNotifierDto(final BuildContext context) : userRepository = context.read();
  final UserRepository userRepository;
}

class UserNotifier extends ValueNotifier<LoadableContainer<UserModel>> {
  UserNotifier({
    required this.dto,
  }) : super(const LoadableContainer(value: UserModel.empty));
  factory UserNotifier.provide(final BuildContext context) => UserNotifier(
        dto: UserNotifierDto(context),
      );
  final UserNotifierDto dto;
  final _uiLocale = ValueNotifier(Locales.en);
  @override
  void dispose() {
    _uiLocale.dispose();
    return super.dispose();
  }

  bool get isLoaded => value.isLoaded;
  bool get isLoading => value.isLoading;
  UserModel get user => value.value;
  UserSettingsModel get settings => user.settings;
  ValueListenable<Locale> get locale => _uiLocale;

  Future<void> onLoad() async {
    value = LoadableContainer.loaded(await dto.userRepository.getUser());
  }

  void updateCharactersLimitForNewNotes(final int newLimit) => _updateSettings(
        (final settings) =>
            settings.copyWith(charactersLimitForNewNotes: newLimit),
      );
  void updateThemeMode(final ThemeMode themeMode) => _updateSettings(
        (final settings) => settings.copyWith(themeMode: themeMode),
      );

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
      uiLocale: _uiLocale.value,
    );
    if (result == null) return;
    _uiLocale.value = result.uiLocale;
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
  void _updateUser(final UserModel Function(UserModel) updateUser) =>
      setValue(value.copyWith(value: updateUser(value.value)));
}
