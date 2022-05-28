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
    return compareDiffContent(
      diff: diff,
      onCheck: (final updatableDiff) {
        final original = updatableDiff.original;
        IdeaProjectAnswerModel other = updatableDiff.other;
        bool otherWasUpdated = updatableDiff.otherWasUpdated;
        bool originalWasUpdated = updatableDiff.originalWasUpdated;

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
    required final InstanceUpdaterDto<IdeaProjectAnswer, IdeaProjectAnswerModel>
        diff,
  }) {
    // TODO: implement saveChanges
    throw UnimplementedError();
  }
}
