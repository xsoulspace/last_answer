part of pack_settings;


class ClientIdeaQuestionSyncService extends HiveClientSyncServiceImpl<
    IdeaProjectQuestion,
    IdeaProjectQuestionModel,
    IdeaProjectQuestionsNotifier> {
  ClientIdeaQuestionSyncService({required final super.context});
    factory ClientIdeaQuestionSyncService.of(final BuildContext context) =>
      ClientIdeaQuestionSyncService(context: context);

}
