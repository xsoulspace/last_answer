part of pack_settings;

ServerIdeaAnswerSyncService createServerIdeaAnswerSyncService(
  final BuildContext context,
) =>
    ServerIdeaAnswerSyncService(
      api: context.read<IdeaProjectAnswersApi>(),
      usersNotifier: context.read(),
    );

class ServerIdeaAnswerSyncService
    extends ServerSyncServiceImpl<IdeaProjectAnswer, IdeaProjectAnswerModel> {
  ServerIdeaAnswerSyncService({
    required final super.api,
    required final super.usersNotifier,
  });
}
