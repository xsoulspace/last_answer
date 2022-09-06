import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/abstract/abstract.dart';
import 'package:lastanswer/api/api.dart';
import 'package:lastanswer/pack_core/abstract/server_models/server_models.dart';
import 'package:lastanswer/pack_settings/sync/_abstract/instance_subscriber.dart';
import 'package:lastanswer/pack_settings/sync/updaters/idea_answer_updater.dart';
import 'package:lastanswer/pack_settings/sync/updaters/idea_question_updater.dart';
import 'package:lastanswer/pack_settings/sync/updaters/idea_updater.dart';
import 'package:lastanswer/pack_settings/sync/updaters/note_updater.dart';
import 'package:lastanswer/state/state.dart';
import 'package:provider/provider.dart';

ServerProjectsSubscriber createProjectsSubscriberNotifier(
  final BuildContext context,
) =>
    ServerProjectsSubscriber(
      api: context.read<ProjectsApi>(),
      ideaUpdater: context.read<IdeaUpdater>(),
      noteUpdater: context.read<NoteUpdater>(),
    );

class ServerProjectsSubscriber extends InstanceSubscriberI<BasicProjectModel> {
  ServerProjectsSubscriber({
    required this.ideaUpdater,
    required this.noteUpdater,
    required super.api,
  });
  final IdeaUpdater ideaUpdater;
  final NoteUpdater noteUpdater;

  @override
  Future<void> _onDelete(final BasicProjectModel value) async =>
      _useSimpleUpdate(value);

  @override
  Future<void> _onNew(final BasicProjectModel value) async =>
      _useSimpleUpdate(value);

  @override
  Future<void> _onUpdate(final BasicProjectModel value) async =>
      _useSimpleUpdate(value);

  void _useSimpleUpdate(final BasicProjectModel value) {
    value.maybeMap(
      orElse: () => null,
      ideaProjectModel: (final idea) {
        ideaUpdater.getAndUpdateByOther([idea]);
      },
      noteProjectModel: (final note) {
        noteUpdater.getAndUpdateByOther([note]);
      },
    );
  }
}

ServerIdeaAnswerSubscriber createIdeaAnswerSubscriberNotifier(
  final BuildContext context,
) =>
    ServerIdeaAnswerSubscriber(
      api: context.read<IdeaProjectAnswersApi>(),
      updater: context.read<IdeaAnswerUpdater>(),
    );

class ServerIdeaAnswerSubscriber extends SingleInstanceSubscriber<
    IdeaProjectAnswer, IdeaProjectAnswerModel, IdeaProjectAnswersNotifier> {
  ServerIdeaAnswerSubscriber({
    required super.updater,
    required super.api,
  });
}

ServerIdeaQuestionSubscriber createIdeaQuestionSubscriberNotifier(
  final BuildContext context,
) =>
    ServerIdeaQuestionSubscriber(
      api: context.read<IdeaProjectQuestionApi>(),
      updater: context.read<IdeaQuestionUpdater>(),
    );

class ServerIdeaQuestionSubscriber extends SingleInstanceSubscriber<
    IdeaProjectQuestion,
    IdeaProjectQuestionModel,
    IdeaProjectQuestionsNotifier> {
  ServerIdeaQuestionSubscriber({
    required super.updater,
    required super.api,
  });
}
