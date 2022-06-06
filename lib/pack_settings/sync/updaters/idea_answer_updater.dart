part of pack_settings;

IdeaAnswerUpdater createIdeaAnswerUpdater(
  final BuildContext context,
) =>
    IdeaAnswerUpdater.of(
      clientSyncService: context.read<ClientIdeaAnswerSyncService>(),
      questionsNotifier: context.read(),
      serverSyncService: context.read<ServerIdeaAnswerSyncService>(),
    );

class IdeaAnswerUpdater extends InstanceUpdater<IdeaProjectAnswer,
    IdeaProjectAnswerModel, IdeaProjectAnswersNotifier> {
  IdeaAnswerUpdater.of({
    required final super.clientSyncService,
    required final this.serverSyncService,
    required this.questionsNotifier,
  });
  final ServerIdeaAnswerSyncService serverSyncService;
  final IdeaProjectQuestionsNotifier questionsNotifier;
  @override
  InstanceUpdatePolicy getPolicyForDiff(
    final UpdatableInstanceDiff<IdeaProjectAnswer, IdeaProjectAnswerModel> diff,
  ) {
    if (diff.original.updatedAt == diff.other.updatedAt) {
      return InstanceUpdatePolicy.noUpdateRequired;
    }
    final useOriginalPolicy =
        diff.original.updatedAt.isAfter(diff.other.updatedAt);
    if (useOriginalPolicy) return InstanceUpdatePolicy.useClientVersion;

    return InstanceUpdatePolicy.useServerVersion;
  }

  @override
  Future<InstanceUpdaterDto<IdeaProjectAnswer, IdeaProjectAnswerModel>>
      compareContent({
    required final InstanceUpdaterDto<IdeaProjectAnswer, IdeaProjectAnswerModel>
        dto,
  }) async {
    return compareDiffContent(
      diff: dto,
      onCheck: (final updatableDiff) {
        final original = updatableDiff.original;
        IdeaProjectAnswerModel other = updatableDiff.other;
        bool otherWasUpdated = updatableDiff.otherWasUpdated;
        bool originalWasUpdated = updatableDiff.originalWasUpdated;
        final policy = getPolicyForDiff(updatableDiff);
        if (policy == InstanceUpdatePolicy.noUpdateRequired) {
          return updatableDiff;
        }

        /// check text
        if (original.text != other.text) {
          switch (policy) {
            case InstanceUpdatePolicy.useClientVersion:
              other = other.copyWith(text: original.text);
              otherWasUpdated = true;
              break;
            case InstanceUpdatePolicy.useServerVersion:
              original.text = other.text;
              originalWasUpdated = true;
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
        dto,
  }) async {
    await Future.wait([
      super.saveChanges(dto: dto),
      serverSyncService.applyUpdaterDto(dto: dto),
    ]);
  }
}
