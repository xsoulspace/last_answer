part of abstract;

@immutable
@Freezed(
  fromJson: true,
  toJson: true,
  equal: true,
  addImplicitFinal: true,
  copyWith: true,
)
class IdeaProjectQuestionModel with _$IdeaProjectQuestionModel {
  @JsonSerializable(
    explicitToJson: true,
  )
  const factory IdeaProjectQuestionModel({
    required final IdeaProjectQuestionId id,
    required final String title,
  }) = _IdeaProjectQuestionModel;
  const IdeaProjectQuestionModel._();
  factory IdeaProjectQuestionModel.fromJson(final Map<String, dynamic> json) =>
      _$IdeaProjectQuestionModelFromJson(json);
  static Map<String, dynamic> modelToJson(
    final IdeaProjectQuestionModel model,
  ) =>
      model.toJson();
}
