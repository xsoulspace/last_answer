part of pack_core;

typedef ProjectFolderId = String;

@immutable
@Freezed(
  fromJson: true,
  toJson: true,
  equal: true,
  addImplicitFinal: true,
  copyWith: true,
)
class ProjectFolderModel with _$ProjectFolderModel {
  @JsonSerializable(
    explicitToJson: true,
  )
  const factory ProjectFolderModel({
    required final ProjectFolderId id,
    required final String title,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
    @JsonKey(name: 'owner_id') required final UserModelId ownerId,
  }) = _ProjectFolderModel;
  const ProjectFolderModel._();
  factory ProjectFolderModel.fromJson(final Map<String, dynamic> json) =>
      _$ProjectFolderModelFromJson(json);
  static Map<String, dynamic> modelToJson(final ProjectFolderModel model) =>
      model.toJson();
}
