part of abstract;

@immutable
@Freezed(
  fromJson: true,
  toJson: true,
  equal: true,
  addImplicitFinal: true,
  copyWith: true,
  unionValueCase: FreezedUnionCase.pascal,
)
class BasicProjectModel with _$BasicProjectModel {
  @JsonSerializable(
    explicitToJson: true,
  )
  const factory BasicProjectModel.noteProjectModel({
    required final ProjectFolderId id,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
    @JsonKey(name: 'is_completed') required final bool isCompleted,
    @JsonKey(name: 'project_type') required final ProjectType projectType,
    @JsonKey(name: 'user_id') required final UserModelId userId,
    @JsonKey(name: 'folder_id') required final ProjectFolderId folderId,
    @JsonKey(name: 'characters_limit') required final int? charactersLimit,
    required final String note,
  }) = _NoteProjectModel;

  @JsonSerializable(
    explicitToJson: true,
  )
  const factory BasicProjectModel.ideaProjectModel({
    required final ProjectFolderId id,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
    @JsonKey(name: 'project_type') required final ProjectType projectType,
    @JsonKey(name: 'user_id') required final UserModelId userId,
    @JsonKey(name: 'folder_id') required final ProjectFolderId folderId,
    @JsonKey(name: 'new_answer_text') required final String newAnswerText,
    @JsonKey(name: 'new_question_id')
        required final IdeaProjectQuestionId newQuestionId,
    required final String title,
  }) = _IdeaProjectModel;
  factory BasicProjectModel.fromJson(final Map<String, dynamic> json) =>
      _$BasicProjectModelFromJson(json);
}
