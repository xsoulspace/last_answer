part of pack_settings;

class IdeaQuestionUpdater
    extends InstanceUpdater<IdeaProjectQuestion, IdeaProjectQuestionModel> {
  IdeaQuestionUpdater.of({
    required final super.list,
    required this.foldersNotifier,
  });

  final ProjectFoldersNotifier foldersNotifier;

  @override
  Future<ModelUpdaterDiff<IdeaProjectQuestion, IdeaProjectQuestionModel>>
      compareContent({
    required final ModelUpdaterDiff<IdeaProjectQuestion,
            IdeaProjectQuestionModel>
        diff,
  }) async {
    final updatedDiffs = <ProjectId,
        InstanceDiff<IdeaProjectQuestion, IdeaProjectQuestionModel>>{};
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
        updatedDiffs[other.id] = InstanceDiff(original: original, other: other);
      }
    }

    return diff.copyWith(
      instancesToUpdate: updatedDiffs,
    );
  }

  @override
  Future<void> saveChanges({
    required final ModelUpdaterDiff<IdeaProjectQuestion,
            IdeaProjectQuestionModel>
        diff,
  }) {
    // TODO: implement saveChanges
    throw UnimplementedError();
  }
}
