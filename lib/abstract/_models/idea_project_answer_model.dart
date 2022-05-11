part of abstract;

@immutable
@Freezed(
  fromJson: true,
  toJson: true,
  equal: true,
  addImplicitFinal: true,
  copyWith: true,
)
class IdeaProjectAnswerModel with _$IdeaProjectAnswerModel {
  @JsonSerializable(
    explicitToJson: true,
  )
  const factory IdeaProjectAnswerModel({
    required final IdeaProjectAnswerId id,
    required final String text,
    @JsonKey(name: 'question_id')
        required final IdeaProjectQuestionId questionId,
    @JsonKey(name: 'project_id') required final ProjectId projectId,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _IdeaProjectAnswerModel;
  factory IdeaProjectAnswerModel.fromJson(final Map<String, dynamic> json) =>
      _$IdeaProjectAnswerModelFromJson(json);
  const IdeaProjectAnswerModel._();

  static Map<String, dynamic> modelToJson(final IdeaProjectAnswerModel model) =>
      model.toJson();
}
