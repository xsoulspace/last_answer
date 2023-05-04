// ignore_for_file: invalid_annotation_target

part of 'server_models.dart';

@immutable
@Freezed(
  fromJson: true,
  toJson: true,
  equal: true,
  addImplicitFinal: true,
  copyWith: true,
  unionValueCase: FreezedUnionCase.pascal,
  unionKey: 'runtime_type',
)
class BasicProjectModel with _$BasicProjectModel implements HasId {
  @JsonSerializable(
    explicitToJson: true,
  )
  const factory BasicProjectModel.noteProjectModel({
    required final ProjectFolderId id,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
    @JsonKey(name: 'is_completed') required final bool isCompleted,
    @JsonKey(name: 'project_type') required final ProjectType projectType,
    @JsonKey(name: 'owner_id') required final UserModelId ownerId,
    @JsonKey(name: 'folder_id') required final ProjectFolderId folderId,
    @JsonKey(name: 'characters_limit') required final int? charactersLimit,
    required final String note,
  }) = NoteProjectModel;

  @JsonSerializable(
    explicitToJson: true,
  )
  const factory BasicProjectModel.ideaProjectModel({
    required final ProjectFolderId id,
    required final String title,
    @JsonKey(name: 'created_at')
        required final DateTime createdAt,
    @JsonKey(name: 'updated_at')
        required final DateTime updatedAt,
    @JsonKey(name: 'is_completed')
        required final bool isCompleted,
    @JsonKey(name: 'project_type')
        required final ProjectType projectType,
    @JsonKey(name: 'owner_id')
        required final UserModelId ownerId,
    @JsonKey(name: 'folder_id')
        required final ProjectFolderId folderId,
    @JsonKey(name: 'new_answer_text')
        required final String newAnswerText,
    @JsonKey(
      name: 'new_question_id',
      fromJson: fromIntToString,
      toJson: fromStringToInt,
    )
        required final IdeaProjectQuestionId newQuestionId,
  }) = IdeaProjectModel;
  factory BasicProjectModel.fromJson(final Map<String, dynamic> json) =>
      _$BasicProjectModelFromJson(json);
  static Map<String, dynamic> modelToJson(final BasicProjectModel model) =>
      model.toJson();
}
