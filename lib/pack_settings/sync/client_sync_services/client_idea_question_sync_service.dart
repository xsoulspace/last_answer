part of pack_settings;

class ClientIdeaQuestionSyncService extends HiveClientSyncServiceImpl<
    IdeaProjectQuestion,
    IdeaProjectQuestionModel,
    IdeaProjectQuestionsNotifier> {
  ClientIdeaQuestionSyncService({required final super.context});
}
