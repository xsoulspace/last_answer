part of abstract;

/// Use [IdeaProjectQuestion.fromTitle] to create class
/// This class immutable so in case of adding new properties make sure that it
/// will not broke immutabilty
@immutable
@JsonSerializable()
class IdeaProjectQuestion extends Equatable {
  const IdeaProjectQuestion._({
    required final this.id,
    required final this.title,
  });

  /// Use this function to create new [IdeaProjectQuestion]
  factory IdeaProjectQuestion.fromTitle(final LocaleTitle title) =>
      IdeaProjectQuestion._(id: createId(), title: title);

  final String id;
  final LocaleTitle title;

  factory IdeaProjectQuestion.fromJson(final Map<String, dynamic> json) =>
      _$IdeaProjectQuestionFromJson(json);
  Map<String, dynamic> toJson() => _$IdeaProjectQuestionToJson(this);

  @override
  List<Object?> get props => [id, title];

  @override
  bool get stringify => true;
}
