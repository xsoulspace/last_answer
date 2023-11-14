import 'dart:async';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/pack_settings/states/general_settings_service.dart';
import 'package:lastanswer/utils/utils.dart';

part 'general_settings_controller.freezed.dart';

@freezed
class GeneralSettingsControllerState with _$GeneralSettingsControllerState {
  const factory GeneralSettingsControllerState({
    @Default(ThemeMode.system) final ThemeMode themeMode,
    @Default(false) final bool isProjectsListReversed,
    @Default(0) final int charactersLimitForNewNotes,
    final Locale? locale,
    // TODO(arenukvern): move to independent notifier,
    final AppStateLoadingStatuses? loadingStatus,
  }) = _GeneralSettingsControllerState;
}

class GeneralSettingsController
    extends ValueNotifier<GeneralSettingsControllerState> implements Loadable {
  GeneralSettingsController({required this.settingsService})
      : super(
          const GeneralSettingsControllerState(),
        );

  final SettingsService settingsService;
  Locale? get locale => value.locale;
  ThemeMode get themeMode => value.themeMode;
  bool get projectsListReversed => value.isProjectsListReversed;
  int get charactersLimitForNewNotes => value.charactersLimitForNewNotes;

  void updateThemeMode(final ThemeMode? newThemeMode) {
    final theme = newThemeMode ?? ThemeMode.system;
    if (newThemeMode == value.themeMode) return;

    setValue(value.copyWith(themeMode: theme));
    unawaited(settingsService.setThemeMode(theme));
  }

  Future<void> updateLocale(final Locale? locale) async {
    if (locale == null) return;

    if (locale == value.locale) return;
    setValue(value.copyWith(locale: locale));
    await S.load(locale);
    await settingsService.setLocale(locale);
  }

  /// Load the user's settings from the SettingsService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  @override
  Future<void> onLoad() async {
    final themeMode = await settingsService.themeMode();
    final locale = await settingsService.locale();
    final isProjectsListReversed = await settingsService.projectsReversed();
    final charactersLimitForNewNotes =
        await settingsService.charactersLimitForNewNotes();
    setValue(
      value.copyWith(
        locale: locale,
        themeMode: themeMode,
        isProjectsListReversed: isProjectsListReversed,
        charactersLimitForNewNotes: charactersLimitForNewNotes,
      ),
    );
  }

  AppStateLoadingStatuses? get loadingStatus => value.loadingStatus;
  set loadingStatus(final AppStateLoadingStatuses? loadingStatus) =>
      setValue(value.copyWith(loadingStatus: loadingStatus));

  set projectsListReversed(final bool projectsReversed) {
    setValue(value.copyWith(isProjectsListReversed: projectsReversed));
    unawaited(settingsService.setProjectsReversed(reversed: projectsReversed));
  }

  set charactersLimitForNewNotes(final int limit) {
    setValue(value.copyWith(charactersLimitForNewNotes: limit));
    unawaited(settingsService.setCharactersLimitForNewNotes(limit: limit));
  }
}
