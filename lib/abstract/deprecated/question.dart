part of abstract;

@Deprecated('use IdeaProjectQuestion')
@JsonSerializable()
class Question extends Equatable {
  final LocaleTitle title;
  final String id;
  const Question({required this.title, required this.id});

  factory Question.fromJson(final Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionToJson(this);

  @override
  List<Object?> get props => [id];

  @override
  bool get stringify => true;
}
