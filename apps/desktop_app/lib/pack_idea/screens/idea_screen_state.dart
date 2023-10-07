import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/pack_settings/pack_settings.dart';
import 'package:lastanswer/state/state.dart';
import 'package:life_hooks/life_hooks.dart';
import 'package:rxdart/rxdart.dart';

// ignore: long-parameter-list
IdeaScreenState useIdeaScreenState({
  required final StreamController<bool> ideaUpdatesStream,
  required final IdeaProject idea,
  required final ValueNotifier<bool> questionsOpened,
  required final ValueNotifier<List<IdeaProjectAnswer>> answersNotifier,
  required final CurrentFolderNotifier folderNotifier,
  required final IdeaProjectsNotifier ideasNotifier,
  required final ServerIdeaAnswerSyncService ideaAnswerSyncService,
  required final ServerProjectsSyncService ideaSyncService,
}) =>
    use(
      ContextfulLifeHook(
        debugLabel: 'useIdeaScreenState',
        state: IdeaScreenState(
          folderNotifier: folderNotifier,
          ideasNotifier: ideasNotifier,
          idea: idea,
          ideaUpdatesStream: ideaUpdatesStream,
          questionsOpened: questionsOpened,
          answersNotifier: answersNotifier,
          ideaSyncService: ideaSyncService,
          ideaAnswerSyncService: ideaAnswerSyncService,
        ),
      ),
    );

class IdeaScreenState extends ContextfulLifeState {
  IdeaScreenState({
    required this.ideaUpdatesStream,
    required this.idea,
    required this.questionsOpened,
    required this.answersNotifier,
    required this.folderNotifier,
    required this.ideasNotifier,
    required this.ideaAnswerSyncService,
    required this.ideaSyncService,
  });
  final IdeaProject idea;
  final ValueNotifier<bool> questionsOpened;
  final ValueNotifier<List<IdeaProjectAnswer>> answersNotifier;
  final ServerIdeaAnswerSyncService ideaAnswerSyncService;
  final ServerProjectsSyncService ideaSyncService;

  final StreamController<bool> ideaUpdatesStream;

  final CurrentFolderNotifier folderNotifier;
  final IdeaProjectsNotifier ideasNotifier;
  @override
  void initState() {
    ideaUpdatesStream.stream
        .sampleTime(
          const Duration(milliseconds: 700),
        )
        .forEach(onIdeaUpdate);
    super.initState();
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> onIdeaUpdate(final bool updateFolder) async {
    ideasNotifier.put(
      key: idea.id,
      value: idea..updatedAt = dateTimeNowUtc(),
    );

    if (updateFolder) {
      idea.folder?.sortProjectsByDate(project: idea);
      folderNotifier.notify();
    }
    await idea.save();
    await ideaSyncService.upsert([idea]);
  }

  void closeQuestions() {
    if (questionsOpened.value) questionsOpened.value = false;
  }

  void openQuestions() {
    if (!questionsOpened.value) questionsOpened.value = true;
  }

  Future<void> onIdeaTitleChange(final String newText) async {
    if (newText == idea.title) return;
    idea.title = newText;
    // final updateFolder = checkToUpdateFolder(title: newText);
    ideaUpdatesStream.add(true);
  }

  bool checkToUpdateFolder({
    final String? title,
    final bool? answersUpdated,
  }) {
    final toPop = idea.folder?.projectsList.first != idea;
    if (title != null || answersUpdated == true) {
      if (toPop) return true;
    }

    return false;
  }

  Future<void> onReadyToDeleteAnswer(final IdeaProjectAnswer answer) async {
    await idea.removeAnswer(answer: answer, context: getContext());
    answersNotifier.value = [...answersNotifier.value]..remove(answer);
    final updateFolder = checkToUpdateFolder(answersUpdated: true);
    ideaUpdatesStream.add(updateFolder);
    await ideaAnswerSyncService.delete([answer]);
  }

  Future<void> onAnswersChange() async {
    final updateFolder = checkToUpdateFolder(answersUpdated: true);
    ideaUpdatesStream.add(updateFolder);
  }

  Future<void> onAnswerCreated(final IdeaProjectAnswer answer) async {
    answersNotifier.value = [answer, ...answersNotifier.value];
    await ideaAnswerSyncService.upsert([answer]);
    final updateFolder = checkToUpdateFolder(answersUpdated: true);
    ideaUpdatesStream.add(updateFolder);
  }
}
