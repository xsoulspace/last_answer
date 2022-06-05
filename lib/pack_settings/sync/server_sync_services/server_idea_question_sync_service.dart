part of pack_settings;

ServerIdeaQuestionSyncService createServerIdeaQuestionSyncService(
  final BuildContext context,
) =>
    ServerIdeaQuestionSyncService(
      api: context.read<IdeaProjectQuestionApi>(),
      usersNotifier: context.read(),
    );

class ServerIdeaQuestionSyncService extends ServerSyncServiceImpl<
    IdeaProjectQuestion, IdeaProjectQuestionModel> {
  ServerIdeaQuestionSyncService({
    required final super.api,
    required final super.usersNotifier,
  });
  @override
  Future<void> onCreateFromOther(
    final Iterable<IdeaProjectQuestion> elements,
  ) async {
    final models = elements
        .map((final e) => e.toModel(user: usersNotifier.currentUser.value));
    await onUpdate(models);
  }
}
