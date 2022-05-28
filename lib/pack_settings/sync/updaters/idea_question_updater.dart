part of pack_settings;

class IdeaQuestionUpdater
    extends InstanceUpdater<IdeaProjectQuestion, IdeaProjectQuestionModel> {
  IdeaQuestionUpdater.of({
    required final super.list,
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
        diff,
  }) async {
    return compareDiffContent(
      diff: diff,
      onCheck: (final updatableDiff) {
        final original = updatableDiff.original;
        IdeaProjectQuestionModel other = updatableDiff.other;
        bool otherWasUpdated = updatableDiff.otherWasUpdated;
        bool originalWasUpdated = updatableDiff.originalWasUpdated;

        /// check title
        if (original.title != other.localizedTitle) {
          switch (policy) {
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

  @override
  Future<void> saveChanges({
    required final InstanceUpdaterDto<IdeaProjectQuestion,
            IdeaProjectQuestionModel>
        diff,
  }) {
    // TODO: implement saveChanges
    throw UnimplementedError();
  }
}
