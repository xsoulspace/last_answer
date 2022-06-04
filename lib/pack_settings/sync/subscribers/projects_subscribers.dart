part of pack_settings;

class IdeaSubscriber extends InstanceSubscriber<IdeaProject, IdeaProjectModel,
    IdeaProjectsNotifier> {
  IdeaSubscriber({
    required final super.updater,
    required final super.api,
  });
}

class IdeaAnswerSubscriber extends InstanceSubscriber<IdeaProjectAnswer,
    IdeaProjectAnswerModel, IdeaProjectAnswersNotifier> {
  IdeaAnswerSubscriber({
    required final super.updater,
    required final super.api,
  });
}

class IdeaQuestionSubscriber extends InstanceSubscriber<IdeaProjectQuestion,
    IdeaProjectQuestionModel, IdeaProjectQuestionsNotifier> {
  IdeaQuestionSubscriber({
    required final super.updater,
    required final super.api,
  });
}

class NoteSubscriber extends InstanceSubscriber<NoteProject, NoteProjectModel,
    NoteProjectsNotifier> {
  NoteSubscriber({
    required final super.updater,
    required final super.api,
  });
}
