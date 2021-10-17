part of abstract;

@Deprecated('use IdeaProjectQuestion')
@JsonSerializable()
class Question extends Equatable {
  @Deprecated('use IdeaProjectQuestion')
  const Question({required final this.title, required final this.id});
  @Deprecated('use IdeaProjectQuestion')
  factory Question.fromJson(final Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionToJson(this);
  final LocalizedText title;
  final String id;

  @override
  List<Object?> get props => [id];

  @override
  bool get stringify => true;
}
