import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:la_core/la_core.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/pack_settings/pack_settings.dart';
import 'package:lastanswer/state/state.dart';
import 'package:lastanswer/utils/utils.dart';
import 'package:life_hooks/life_hooks.dart';
import 'package:rxdart/rxdart.dart';

// ignore: long-parameter-list
IdeaAnswerScreenState useIdeaAnswerScreenState({
  required final TextEditingController textController,
  required final StreamController<bool> updatesStream,
  required final ValueNotifier<IdeaProjectAnswer> answerNotifier,
  required final IdeaProject idea,
  required final ValueChanged<IdeaProject> onScreenBack,
  required final IdeaProjectsNotifier ideasNotifier,
  required final ServerIdeaAnswerSyncService ideaAnswerSyncService,
  required final ServerProjectsSyncService ideaSyncService,
}) =>
    use(
      ContextfulLifeHook(
        debugLabel: 'useIdeaAnswerScreenState',
        state: IdeaAnswerScreenState(
          ideasNotifier: ideasNotifier,
          textController: textController,
          updatesStream: updatesStream,
          answerNotifier: answerNotifier,
          idea: idea,
          onScreenBack: onScreenBack,
          ideaAnswerSyncService: ideaAnswerSyncService,
          ideaSyncService: ideaSyncService,
        ),
      ),
    );

class IdeaAnswerScreenState extends ContextfulLifeState {
  IdeaAnswerScreenState({
    required this.textController,
    required this.ideasNotifier,
    required this.updatesStream,
    required this.answerNotifier,
    required this.idea,
    required this.onScreenBack,
    required this.ideaAnswerSyncService,
    required this.ideaSyncService,
  });
  final TextEditingController textController;
  final StreamController<bool> updatesStream;
  final ValueNotifier<IdeaProjectAnswer> answerNotifier;
  final IdeaProject idea;
  final ValueChanged<IdeaProject> onScreenBack;
  final ServerIdeaAnswerSyncService ideaAnswerSyncService;
  final ServerProjectsSyncService ideaSyncService;

  final IdeaProjectsNotifier ideasNotifier;
  @override
  void initState() {
    textController.addListener(onTextChanged);

    updatesStream.stream
        .sampleTime(
          const Duration(milliseconds: 700),
        )
        .forEach(onAnswerUpdate);
    super.initState();
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> onAnswerUpdate(final bool update) async {
    idea.folder?.sortProjectsByDate(project: idea);
    await answerNotifier.value.save();
    ideasNotifier.notify();
    await idea.save();
    await ideaAnswerSyncService.upsert([answerNotifier.value]);
    await ideaSyncService.upsert([idea]);
  }

  @override
  void dispose() {
    super.dispose();
    textController.removeListener(onTextChanged);
  }

  void onTextChanged() {
    if (answerNotifier.value.text == textController.text) return;
    answerNotifier.value.text = textController.text;
    idea.updatedAt = dateTimeNowUtc();
    updatesStream.add(true);
  }

  void onBack() {
    closeKeyboard(context: context);
    onScreenBack(idea);
  }
}
