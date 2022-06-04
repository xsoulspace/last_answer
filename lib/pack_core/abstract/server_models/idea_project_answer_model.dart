// ignore_for_file: invalid_annotation_target

part of pack_core;

typedef IdeaProjectAnswerId = String;
typedef IdeaProjectQuestionId = String;
typedef ProjectId = String;

@immutable
@Freezed(
  fromJson: true,
  toJson: true,
  equal: true,
  addImplicitFinal: true,
  copyWith: true,
)
class IdeaProjectAnswerModel with _$IdeaProjectAnswerModel implements HasId {
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
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _IdeaProjectAnswerModel;
  factory IdeaProjectAnswerModel.fromJson(final Map<String, dynamic> json) =>
      _$IdeaProjectAnswerModelFromJson(json);
  const IdeaProjectAnswerModel._();

  static Map<String, dynamic> modelToJson(final IdeaProjectAnswerModel model) =>
      model.toJson();
}
