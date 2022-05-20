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
    final otherUpdates = <IdeaProjectQuestionModel>[];
    final originalUpdates = <IdeaProjectQuestion>[];
    for (final noteDiff in diff.instancesToCheck.values) {
      final original = noteDiff.original;
      IdeaProjectQuestionModel other = noteDiff.other;
      bool otherWasUpdated = false;
      const bool originalWasUpdated = false;

      /// check title
      if (original.title != other.localizedTitle) {
        switch (policy) {
          case InstanceUpdatePolicy.useClientVersion:
            other = other.copyWith(title: jsonEncode(original.title.toJson()));
            otherWasUpdated = true;
            break;
          default:
            // TODO(arenukvern): description
            throw UnimplementedError();
        }
      }

      if (otherWasUpdated || originalWasUpdated) {
        if (originalWasUpdated) await original.save();

        otherUpdates.add(other);
        originalUpdates.add(original);
      }
    }

    return diff.copyWith(
      otherUpdates: diff.otherUpdates.copyWith(
        toUpdate: otherUpdates,
      ),
      originalUpdates: diff.originalUpdates.copyWith(
        toUpdate: originalUpdates,
      ),
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
