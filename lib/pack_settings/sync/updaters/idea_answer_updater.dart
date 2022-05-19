part of pack_settings;

class IdeaAnswerUpdater
    extends InstanceUpdater<IdeaProjectAnswer, IdeaProjectAnswerModel> {
  IdeaAnswerUpdater.of({
    required final super.list,
    required this.questionsNotifier,
  });

  final IdeaProjectQuestionsNotifier questionsNotifier;

  @override
  Future<ModelUpdaterDiff<IdeaProjectAnswer, IdeaProjectAnswerModel>>
      compareContent({
    required final ModelUpdaterDiff<IdeaProjectAnswer, IdeaProjectAnswerModel>
        diff,
  }) async {
    final updatedDiffs =
        <ProjectId, InstanceDiff<IdeaProjectAnswer, IdeaProjectAnswerModel>>{};
    for (final noteDiff in diff.instancesToCheck.values) {
      final original = noteDiff.original;
      IdeaProjectAnswerModel other = noteDiff.other;
      bool otherWasUpdated = false;
      const bool originalWasUpdated = false;

      /// check text
      if (original.text != other.text) {
        switch (policy) {
          case InstanceUpdatePolicy.useClientVersion:
            other = other.copyWith(text: original.text);
            otherWasUpdated = true;
            break;
          default:
            // TODO(arenukvern): description
            throw UnimplementedError();
        }
      }

      /// check question
      if (original.question.id != other.questionId) {
        switch (policy) {
          case InstanceUpdatePolicy.useClientVersion:
            other = other.copyWith(questionId: original.question.id);
            otherWasUpdated = true;
            break;
          default:
            // TODO(arenukvern): description
            throw UnimplementedError();
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
    required final ModelUpdaterDiff<IdeaProjectAnswer, IdeaProjectAnswerModel>
        diff,
  }) {
    // TODO: implement saveChanges
    throw UnimplementedError();
  }
}
