part of pack_settings;

ServerIdeaQuestionSyncService createServerIdeaQuestionSyncService(
  final BuildContext context,
) =>
    ServerIdeaQuestionSyncService(
      api: context.read<IdeaProjectQuestionApi>(),
    );

class ServerIdeaQuestionSyncService extends ServerSyncServiceImpl<
    IdeaProjectQuestion, IdeaProjectQuestionModel> {
  ServerIdeaQuestionSyncService({required final super.api});
}
