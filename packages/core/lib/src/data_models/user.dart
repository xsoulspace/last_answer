// ignore_for_file: invalid_annotation_target

part of 'data_models.dart';

enum LocalDbVersion {
  v3_16,
  v3_17;

  static const newestVersion = v3_17;
}

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    @Default(UserSettingsModel.initial) final UserSettingsModel settings,
    @Default(LocalDbVersion.v3_16) final LocalDbVersion localDbVersion,
    @Default(false) final bool hasCompletedOnboarding,
  }) = _UserModel;
  factory UserModel.fromJson(final Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  static const empty = UserModel();
}

@freezed
class UserSettingsModel with _$UserSettingsModel {
  const factory UserSettingsModel({
    @JsonKey(fromJson: _themeModeFromJson, toJson: _themeModeToJson)
    @Default(ThemeMode.system)
    final ThemeMode themeMode,
    @Default(true) final bool isProjectsListReversed,
    @Default(0) final int charactersLimitForNewNotes,
    @JsonKey(fromJson: _localeFromJson, toJson: _localeToJson)
    final Locale? locale,
  }) = _UserSettingsModel;
  factory UserSettingsModel.fromJson(final Map<String, dynamic> json) =>
      _$UserSettingsModelFromJson(json);
  static const initial = UserSettingsModel();
}

ThemeMode _themeModeFromJson(final int? index) {
  final i = int.tryParse('$index');
  if (i == null) return ThemeMode.system;
  if (i > ThemeMode.values.length || i < 0) return ThemeMode.system;

  return ThemeMode.values[i];
}

int _themeModeToJson(final ThemeMode theme) => theme.index;

Locale _localeFromJson(final String languageCode) {
  try {
    if (languageCode.isEmpty) return Locales.en;

    return Locale.fromSubtags(languageCode: languageCode);
    // ignore: avoid_catches_without_on_clauses
  } catch (e) {
    return Locales.en;
  }
}

String _localeToJson(final Locale? locale) => locale?.languageCode ?? '';
