part of pack_settings;

ProjectsSubscriber createProjectsSubscriber(final BuildContext context) =>
    ProjectsSubscriber(
      api: context.read<ProjectsApi>(),
      ideaUpdater: context.read<IdeaUpdater>(),
      noteUpdater: context.read<NoteUpdater>(),
    );

class ProjectsSubscriber extends InstanceSubscriberI<BasicProjectModel> {
  ProjectsSubscriber({
    required final this.ideaUpdater,
    required final this.noteUpdater,
    required final super.api,
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

IdeaAnswerSubscriber createIdeaAnswerSubscriber(final BuildContext context) =>
    IdeaAnswerSubscriber(
      api: context.read<IdeaProjectAnswersApi>(),
      updater: context.read<IdeaAnswerUpdater>(),
    );

class IdeaAnswerSubscriber extends SingleInstanceSubscriber<IdeaProjectAnswer,
    IdeaProjectAnswerModel, IdeaProjectAnswersNotifier> {
  IdeaAnswerSubscriber({
    required final super.updater,
    required final super.api,
  });
}

IdeaQuestionSubscriber createIdeaQuestionSubscriber(
  final BuildContext context,
) =>
    IdeaQuestionSubscriber(
      api: context.read<IdeaProjectQuestionApi>(),
      updater: context.read<IdeaQuestionUpdater>(),
    );

class IdeaQuestionSubscriber extends SingleInstanceSubscriber<
    IdeaProjectQuestion,
    IdeaProjectQuestionModel,
    IdeaProjectQuestionsNotifier> {
  IdeaQuestionSubscriber({
    required final super.updater,
    required final super.api,
  });
}
