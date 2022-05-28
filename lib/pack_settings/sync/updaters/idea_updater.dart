part of pack_settings;

class IdeaUpdater
    extends BasicProjectInstanceUpdater<IdeaProject, IdeaProjectModel> {
  IdeaUpdater.of({
    required final super.list,
    required final super.clientSyncService,
    required final super.serverSyncService,
    required final super.foldersNotifier,
    required this.questionsNotifier,
  });
  final IdeaProjectQuestionsNotifier questionsNotifier;

  @override
  // ignore: long-method
  Future<InstanceUpdaterDto<IdeaProject, IdeaProjectModel>> compareContent({
    required final InstanceUpdaterDto<IdeaProject, IdeaProjectModel> diff,
  }) async {
    final otherUpdates = <IdeaProjectModel>[];
    final originalUpdates = <IdeaProject>[];
    for (final noteDiff in diff.instancesToCheck.values) {
      final original = noteDiff.original;
      IdeaProjectModel other = noteDiff.other;
      bool otherWasUpdated = false;
      bool originalWasUpdated = false;

      final folderDiffResult = updateFolder(original: original, other: other);
      other = folderDiffResult.other;
      otherWasUpdated = folderDiffResult.otherWasUpdated;
      originalWasUpdated = folderDiffResult.originalWasUpdated;

      /// check newAnswerText
      if (original.title != other.title) {
        switch (policy) {
          case InstanceUpdatePolicy.useClientVersion:
            other = other.copyWith(title: original.title);
            otherWasUpdated = true;
            break;
          default:
            // TODO(arenukvern): description
            throw UnimplementedError();
        }
      }

      /// check newAnswerText
      if (original.newAnswerText != other.newAnswerText) {
        switch (policy) {
          case InstanceUpdatePolicy.useClientVersion:
            other = other.copyWith(newAnswerText: original.newAnswerText);
            otherWasUpdated = true;
            break;
          default:
            // TODO(arenukvern): description
            throw UnimplementedError();
        }
      }

      /// check newQuestionId
      if (original.newQuestion?.id != other.newQuestionId) {
        InstanceUpdatePolicy effectivePolicy =
            InstanceUpdatePolicy.useClientVersion;
        if (original.newQuestion == null) {
          effectivePolicy = InstanceUpdatePolicy.useServerVersion;
        }
        switch (effectivePolicy) {
          case InstanceUpdatePolicy.useClientVersion:
            other = other.copyWith(newAnswerText: original.newAnswerText);
            otherWasUpdated = true;
            break;
          case InstanceUpdatePolicy.useServerVersion:
            final question = questionsNotifier.state[other.newQuestionId];
            original.newQuestion = question;
            originalWasUpdated = true;
            break;
        }
      }

      if (otherWasUpdated || originalWasUpdated) {
        other = other.copyWith(updatedAt: DateTime.now());
        original.updatedAt = other.updatedAt;
        await original.save();

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
    required final InstanceUpdaterDto<IdeaProject, IdeaProjectModel> diff,
  }) {
    // TODO: implement saveChanges
    throw UnimplementedError();
  }
}
