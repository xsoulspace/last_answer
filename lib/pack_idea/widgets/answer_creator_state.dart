import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:la_core/la_core.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/pack_settings/pack_settings.dart';
import 'package:life_hooks/life_hooks.dart';

// ignore: long-parameter-list
AnswerCreatorState useAnswerCreatorState({
  required final IdeaProject idea,
  required final IdeaProjectQuestion defaultQuestion,
  required final ValueChanged<IdeaProjectAnswer> onCreated,
  required final VoidCallback onShareTap,
  required final VoidCallback onFocus,
  required final ValueNotifier<bool> questionsOpened,
  required final VoidCallback onChanged,
  required final ServerProjectsSyncService ideaSyncService,
}) =>
    use(
      ContextfulLifeHook(
        debugLabel: 'useAnswerCreatorState',
        state: AnswerCreatorState(
          idea: idea,
          defaultQuestion: defaultQuestion,
          onChanged: onChanged,
          onCreated: onCreated,
          onFocus: onFocus,
          onShareTap: onShareTap,
          questionsOpened: questionsOpened,
          ideaSyncService: ideaSyncService,
        ),
      ),
    );

class AnswerCreatorState extends ContextfulLifeState {
  AnswerCreatorState({
    required this.defaultQuestion,
    required this.onCreated,
    required this.onShareTap,
    required this.onFocus,
    required this.questionsOpened,
    required this.onChanged,
    required this.idea,
    required this.ideaSyncService,
  });

  final IdeaProject idea;
  final IdeaProjectQuestion defaultQuestion;
  final ValueChanged<IdeaProjectAnswer> onCreated;
  final VoidCallback onShareTap;
  final VoidCallback onFocus;
  final ValueNotifier<bool> questionsOpened;
  final VoidCallback onChanged;
  final ServerProjectsSyncService ideaSyncService;

  final answerFocusNode = FocusNode();
  late final selectedQuestion =
      ValueNotifier<IdeaProjectQuestion?>(idea.newQuestion ?? defaultQuestion);
  late final answerController = TextEditingController(text: idea.newAnswerText);
  late final answer = ValueNotifier<String>(answerController.text);

  @override
  void initState() {
    selectedQuestion.addListener(onSelectedQuestionChanged);
    answerController.addListener(onAnswerControllerChanged);
    super.initState();
  }

  @override
  void dispose() {
    answerFocusNode.dispose();
    answer.dispose();
    selectedQuestion
      ..removeListener(onSelectedQuestionChanged)
      ..dispose();
    answerController
      ..removeListener(onAnswerControllerChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> onAnswerControllerChanged() async {
    if (idea.newAnswerText == answerController.text) return;
    idea.newAnswerText = answerController.text;
    answer.value = answerController.text;
    onChanged();
    await idea.save();
    await ideaSyncService.upsert([idea]);
  }

  Future<void> onSelectedQuestionChanged() async {
    if (selectedQuestion.value == idea.newQuestion) return;
    idea
      ..newQuestion = selectedQuestion.value
      ..updatedAt = dateTimeNowUtc();
    await idea.save();
    await ideaSyncService.upsert([idea]);
  }

  Future<void> onCreate() async {
    final text = answerController.text;
    answerController.clear();
    final question = selectedQuestion.value;
    if (question == null || text.isEmpty) return;
    final answer = await IdeaProjectAnswer.create(
      text: text,
      question: question,
      idea: idea,
      context: getContext(),
    );

    onCreated(answer);
  }
}
