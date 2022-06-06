part of pack_settings;

class ClientIdeaAnswerSyncService extends HiveClientSyncServiceImpl<
    IdeaProjectAnswer, IdeaProjectAnswerModel, IdeaProjectAnswersNotifier> {
  ClientIdeaAnswerSyncService({required final super.context});
  factory ClientIdeaAnswerSyncService.of(final BuildContext context) =>
      ClientIdeaAnswerSyncService(context: context);
  @override
  Future<void> onCreateFromOther(
    final Iterable<IdeaProjectAnswerModel> elements,
  ) async {}
}
