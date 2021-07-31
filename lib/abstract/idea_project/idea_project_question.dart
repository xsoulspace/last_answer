part of abstract;

/// Use [IdeaProjectQuestion.fromTitle] to create class
/// This class immutable so in case of adding new properties make sure that it
/// will not broke immutabilty
@immutable
@JsonSerializable()
class IdeaProjectQuestion extends Equatable {
  /// Do not use default constructor to create new [IdeaProjectQuestion]
  /// Do use [IdeaProjectQuestion.fromTitle]
  const IdeaProjectQuestion({
    required final this.id,
    required final this.title,
  });
  const IdeaProjectQuestion._({
    required final this.id,
    required final this.title,
  });
  factory IdeaProjectQuestion.fromJson(final Map<String, dynamic> json) =>
      _$IdeaProjectQuestionFromJson(json);

  /// Use this function to create new [IdeaProjectQuestion]
  factory IdeaProjectQuestion.fromTitle(final LocalizedText title) =>
      IdeaProjectQuestion._(id: createId(), title: title);

  final String id;
  final LocalizedText title;

  Map<String, dynamic> toJson() => _$IdeaProjectQuestionToJson(this);

  @override
  List<Object?> get props => [id, title];

  @override
  bool get stringify => true;
}
