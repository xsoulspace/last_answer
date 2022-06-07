import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:lastanswer/abstract/hive_boxes_ids.dart';
import 'package:lastanswer/abstract/idea_project/idea_project.dart';
import 'package:lastanswer/abstract/idea_project/idea_project_question.dart';
import 'package:lastanswer/library/extensions/extensions.dart';
import 'package:lastanswer/pack_core/pack_core.dart';
import 'package:lastanswer/state/state.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:provider/provider.dart';

part 'idea_project_answer.g.dart';

/// This is an answer for [IdeaProject]
@HiveType(typeId: HiveBoxesIds.ideaProjectAnswer)
class IdeaProjectAnswer extends RemoteHiveObjectWithId<IdeaProjectAnswerModel>
    with EquatableMixin
    implements Sharable {
  IdeaProjectAnswer({
    required this.id,
    required this.text,
    required this.question,
    required this.createdAt,
    this.projectId = '',
    this.isToDelete = false,
    final DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? dateTimeNowUtc();
  static Future<IdeaProjectAnswer> fromModel({
    required final IdeaProjectAnswerModel model,
    required final BuildContext context,
  }) async {
    final questions = context.read<IdeaProjectQuestionsNotifier>();
    final question = questions.state[model.questionId]!;
    final ideas = context.read<IdeaProjectsNotifier>();
    final idea = ideas.state[model.projectId];

    return create(
      idea: idea!,
      context: context,
      question: question,
      text: model.text,
      createdAt: model.createdAt,
      id: model.id,
      updatedAt: model.updatedAt,
    );
  }

  // ignore: long-parameter-list
  static Future<IdeaProjectAnswer> create({
    required final BuildContext context,
    required final String text,
    required final IdeaProjectQuestion question,
    required final IdeaProject idea,
    final String? id,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) async {
    final answer = IdeaProjectAnswer(
      text: text,
      question: question,
      id: id ?? createId(),
      createdAt: createdAt ?? dateTimeNowUtc(),
      projectId: idea.id,
      updatedAt: updatedAt,
    );
    final box = await Hive.openBox<IdeaProjectAnswer>(
      HiveBoxesIds.ideaProjectAnswerKey,
    );
    await box.put(answer.id, answer);

    context
        .read<IdeaProjectAnswersNotifier>()
        .put(key: answer.id, value: answer);

    return answer;
  }

  @HiveField(0)
  String text;

  @HiveField(1)
  IdeaProjectQuestion question;

  @override
  @HiveField(2)
  final IdeaProjectAnswerId id;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  @override
  @HiveField(5)
  bool isToDelete;

  @HiveField(6)
  // TODO(arenukvern): after v4 migration replace late with final
  ProjectId projectId;

  String get title => text.length <= 50 ? text : text.substring(0, 49);
  @override
  String toShareString(final BuildContext context) =>
      '${question.toShareString(context)} \n $text';

  @override
  List get props => [id];

  @override
  bool? get stringify => true;

  @override
  IdeaProjectAnswerModel toModel({required final UserModel user}) {
    return IdeaProjectAnswerModel(
      createdAt: createdAt,
      id: id,
      projectId: projectId,
      questionId: question.id,
      text: text,
      updatedAt: updatedAt,
      ownerId: user.id,
    );
  }

  @override
  Future<void> deleteWithRelatives({
    required final BuildContext context,
  }) async {
    context.read<IdeaProjectAnswersNotifier>().remove(key: id);
    await delete();
  }
}

/// A mock for [IdeaProjectAnswer].
/// To create use `final mockIdeaProjectAnswer = MockIdeaProjectAnswer();`
// ignore: avoid_implementing_value_types
// class MockIdeaProjectAnswer extends Mock implements IdeaProjectAnswer {}
