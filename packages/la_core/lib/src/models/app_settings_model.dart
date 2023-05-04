// ignore_for_file: invalid_annotation_target

part of 'models.dart';

@immutable
@Freezed()
class AppSettingsModel with _$AppSettingsModel {
  @JsonSerializable(
    explicitToJson: true,
  )
  const factory AppSettingsModel({
    @JsonKey(
      fromJson: localeFromString,
      toJson: localeToString,
    )
        final Locale? locale,
  }) = _AppSettingsModel;

  const AppSettingsModel._();

  factory AppSettingsModel.fromJson(final Map<String, dynamic> json) =>
      _$AppSettingsModelFromJson(json);
  static const empty = AppSettingsModel();
}
