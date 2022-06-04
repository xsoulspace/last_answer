part of pack_settings;

IdeaQuestionUpdater createIdeaQuestionUpdater(
  final BuildContext context,
) =>
    IdeaQuestionUpdater.of(
      clientSyncService: context.read<ClientIdeaQuestionSyncService>(),
      foldersNotifier: context.read(),
      serverSyncService: context.read<ServerIdeaQuestionSyncService>(),
    );

class IdeaQuestionUpdater extends InstanceUpdater<IdeaProjectQuestion,
    IdeaProjectQuestionModel, IdeaProjectQuestionsNotifier> {
  IdeaQuestionUpdater.of({
    required final super.clientSyncService,
    required final super.serverSyncService,
    required this.foldersNotifier,
  });

  final ProjectFoldersNotifier foldersNotifier;

  @override
  Future<InstanceUpdaterDto<IdeaProjectQuestion, IdeaProjectQuestionModel>>
      compareContent({
    required final InstanceUpdaterDto<IdeaProjectQuestion,
            IdeaProjectQuestionModel>
        dto,
  }) async {
    return compareDiffContent(
      diff: dto,
      onCheck: (final updatableDiff) {
        final original = updatableDiff.original;
        IdeaProjectQuestionModel other = updatableDiff.other;
        bool otherWasUpdated = updatableDiff.otherWasUpdated;
        final bool originalWasUpdated = updatableDiff.originalWasUpdated;

        /// check title
        if (original.title != other.localizedTitle) {
          switch (defaultPolicy) {
            case InstanceUpdatePolicy.useClientVersion:
              other =
                  other.copyWith(title: jsonEncode(original.title.toJson()));
              otherWasUpdated = true;
              break;
            default:
              // TODO(arenukvern): description
              throw UnimplementedError();
          }
        }

        return UpdatableInstanceDiff(
          original: original,
          other: other,
          originalWasUpdated: originalWasUpdated,
          otherWasUpdated: otherWasUpdated,
        );
      },
    );
  }
}
