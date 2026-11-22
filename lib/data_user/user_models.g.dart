// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  settings: json['settings'] == null
      ? UserSettingsModel.initial
      : UserSettingsModel.fromJson(json['settings'] as Map<String, dynamic>),
  localDbVersion:
      $enumDecodeNullable(_$LocalDbVersionEnumMap, json['localDbVersion']) ??
      LocalDbVersion.newestVersion,
  hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'settings': instance.settings,
      'localDbVersion': _$LocalDbVersionEnumMap[instance.localDbVersion]!,
      'hasCompletedOnboarding': instance.hasCompletedOnboarding,
    };

const _$LocalDbVersionEnumMap = {
  LocalDbVersion.v3_16: 'v3_16',
  LocalDbVersion.v3_17: 'v3_17',
  LocalDbVersion.v4: 'v4',
};

_UserSettingsModel _$UserSettingsModelFromJson(Map<String, dynamic> json) =>
    _UserSettingsModel(
      themeMode: json['themeMode'] == null
          ? ThemeMode.system
          : _themeModeFromJson((json['themeMode'] as num?)?.toInt()),
      isProjectsListReversed: json['isProjectsListReversed'] as bool? ?? true,
      charactersLimitForNewNotes:
          (json['charactersLimitForNewNotes'] as num?)?.toInt() ?? 0,
      locale: _localeFromJson(json['locale'] as String),
      useTimestampForBackupFilename:
          json['useTimestampForBackupFilename'] as bool? ?? true,
      isSocialNetworksRestricted:
          json['isSocialNetworksRestricted'] as bool? ?? true,
    );

Map<String, dynamic> _$UserSettingsModelToJson(_UserSettingsModel instance) =>
    <String, dynamic>{
      'themeMode': _themeModeToJson(instance.themeMode),
      'isProjectsListReversed': instance.isProjectsListReversed,
      'charactersLimitForNewNotes': instance.charactersLimitForNewNotes,
      'locale': _localeToJson(instance.locale),
      'useTimestampForBackupFilename': instance.useTimestampForBackupFilename,
      'isSocialNetworksRestricted': instance.isSocialNetworksRestricted,
    };
