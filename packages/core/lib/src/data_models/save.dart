part of 'data_models.dart';

enum DbSaveVersion { v1 }

@freezed
class DbSaveModel with _$DbSaveModel {
  const factory DbSaveModel({
    @Default(DbSaveVersion.v1) final DbSaveVersion version,
    @Default([]) final List<ProjectModel> projects,
    @Default([]) final List<ProjectTagModel> tags,
  }) = _DbSaveModel;
  factory DbSaveModel.fromJson(final Map<String, dynamic> json) =>
      _$DbSaveModelFromJson(json);
  const DbSaveModel._();
  static const empty = DbSaveModel();
  bool get isEmpty => projects.isEmpty && tags.isEmpty;
}
