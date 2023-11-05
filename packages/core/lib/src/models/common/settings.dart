part of 'common.dart';

@freezed
class AppSettingsModel with _$AppSettingsModel {
  const factory AppSettingsModel() = _AppSettingsModel;
  factory AppSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsModelFromJson(json);
}
