part of pack_settings;

class IdeaAnswerUpdater
    extends InstanceUpdater<IdeaProjectAnswer, IdeaProjectAnswerModel> {
  IdeaAnswerUpdater.of({
    required final super.list,
    required final super.clientSyncService,
    required final super.serverSyncService,
    required this.questionsNotifier,
  });

  final IdeaProjectQuestionsNotifier questionsNotifier;

  @override
  Future<InstanceUpdaterDto<IdeaProjectAnswer, IdeaProjectAnswerModel>>
      compareContent({
    required final InstanceUpdaterDto<IdeaProjectAnswer, IdeaProjectAnswerModel>
        diff,
  }) async {
    final otherUpdates = <IdeaProjectAnswerModel>[];
    final originalUpdates = <IdeaProjectAnswer>[];
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
    required final InstanceUpdaterDto<IdeaProjectAnswer, IdeaProjectAnswerModel>
        diff,
  }) {
    // TODO: implement saveChanges
    throw UnimplementedError();
  }
}
