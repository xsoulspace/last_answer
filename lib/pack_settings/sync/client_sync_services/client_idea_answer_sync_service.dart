part of pack_settings;

class ClientIdeaAnswerSyncService extends HiveClientSyncServiceImpl<
    IdeaProjectAnswer, IdeaProjectAnswerModel> {
  ClientIdeaAnswerSyncService({required final super.context});
  @override
  Future<void> onCreateFromOther(
    final Iterable<IdeaProjectAnswerModel> elements,
  ) async {}
}
