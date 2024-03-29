part of '../hive_models.dart';

typedef IdeaProjectQuestionId = String;

/// Use [IdeaProjectQuestion.fromTitle] to create class
/// This class immutable so in case of adding new properties make sure that it
/// will not broke immutabilty
@JsonSerializable()
@HiveType(typeId: HiveBoxesIds.ideaProjectQuestion)
class IdeaProjectQuestion extends HiveObject
    with EquatableMixin
    implements Sharable, HasId {
  /// Do not use default constructor to create new [IdeaProjectQuestion]
  /// Do use [IdeaProjectQuestion.fromTitle]
  IdeaProjectQuestion({
    required this.id,
    required this.title,
  });
  factory IdeaProjectQuestion.fromJson(final Map<String, dynamic> json) =>
      _$IdeaProjectQuestionFromJson(json);

  /// Use this function to create new [IdeaProjectQuestion]
  factory IdeaProjectQuestion.fromTitle(final LocalizedText title) =>
      IdeaProjectQuestion(id: createId(), title: title);
  @override
  @HiveField(0)
  final String id;
  @HiveField(1)
  final LocalizedText title;

  Map<String, dynamic> toJson() => _$IdeaProjectQuestionToJson(this);

  @override
  List<Object?> get props => [id];

  @override
  bool get stringify => true;

  @override
  String toShareString(final BuildContext context) => '';

  IdeaProjectQuestionModel toModel() => IdeaProjectQuestionModel(
        id: IdeaProjectQuestionModelId.fromJson(id),
        title: title.toModel(),
      );

  @override
  String toSharableTitle(final BuildContext context) => '';
}

/// A mock for [IdeaProjectQuestion].
/// To create use `final mockIdeaProjectQuestion = MockIdeaProjectQuestion();`
// ignore: avoid_implementing_value_types
class MockIdeaProjectQuestion extends Mock implements IdeaProjectQuestion {}
