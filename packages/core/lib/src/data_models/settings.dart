part of 'data_models.dart';

@freezed
class AppSettingsModel with _$AppSettingsModel {
  const factory AppSettingsModel() = _AppSettingsModel;
  factory AppSettingsModel.fromJson(final Map<String, dynamic> json) =>
      _$AppSettingsModelFromJson(json);
}
