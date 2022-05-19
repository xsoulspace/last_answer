part of pack_settings;

class IdeaUpdater extends InstanceUpdater<IdeaProject, IdeaProjectModel> {
  IdeaUpdater.of({
    required final super.list,
    required this.foldersNotifier,
    required this.questionsNotifier,
  });

  final ProjectFoldersNotifier foldersNotifier;
  final IdeaProjectQuestionsNotifier questionsNotifier;

  @override
  Future<ModelUpdaterDiff<IdeaProject, IdeaProjectModel>> compareContent({
    required final ModelUpdaterDiff<IdeaProject, IdeaProjectModel> diff,
  }) async {
    final updatedDiffs =
        <ProjectId, InstanceDiff<IdeaProject, IdeaProjectModel>>{};
    for (final noteDiff in diff.instancesToCheck.values) {
      final original = noteDiff.original;
      IdeaProjectModel other = noteDiff.other;
      bool otherWasUpdated = false;
      bool originalWasUpdated = false;

      /// check folder - how to unify for all projects?
      if (original.folder?.id != other.folderId) {
        InstanceUpdatePolicy effectivePolicy =
            InstanceUpdatePolicy.useClientVersion;
        if (original.folder == null) {
          effectivePolicy = InstanceUpdatePolicy.useServerVersion;
        }
        switch (effectivePolicy) {
          case InstanceUpdatePolicy.useClientVersion:
            other = other.copyWith(
              folderId: original.folder!.id,
            );
            otherWasUpdated = true;
            break;
          case InstanceUpdatePolicy.useServerVersion:
            final folder = foldersNotifier.state[other.folderId];
            folder?.addProject(original);
            originalWasUpdated = true;
            break;
        }
      }

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
        updatedDiffs[other.id] = InstanceDiff(original: original, other: other);
      }
    }

    return diff.copyWith(
      instancesToUpdate: updatedDiffs,
    );
  }

  @override
  Future<void> saveChanges({
    required final ModelUpdaterDiff<IdeaProject, IdeaProjectModel> diff,
  }) {
    // TODO: implement saveChanges
    throw UnimplementedError();
  }
}
