part of pack_settings;

IdeaUpdater createIdeaUpdater(
  final BuildContext context,
) =>
    IdeaUpdater.of(
      clientSyncService: context.read<ClientIdeaSyncService>(),
      foldersNotifier: context.read(),
      serverSyncService: context.read<ServerIdeaSyncService>(),
      questionsNotifier: context.read(),
    );

class IdeaUpdater extends BasicProjectInstanceUpdater<IdeaProject,
    IdeaProjectModel, IdeaProjectsNotifier> {
  IdeaUpdater.of({
    required final super.clientSyncService,
    required final super.serverSyncService,
    required final super.foldersNotifier,
    required this.questionsNotifier,
  });
  final IdeaProjectQuestionsNotifier questionsNotifier;

  @override
  // ignore: long-method
  Future<InstanceUpdaterDto<IdeaProject, IdeaProjectModel>> compareContent({
    required final InstanceUpdaterDto<IdeaProject, IdeaProjectModel> dto,
  }) async {
    return compareDiffContent(
      diff: dto,
      onCheck: (final updatableDiff) {
        final original = updatableDiff.original;
        IdeaProjectModel other = updatableDiff.other;
        bool otherWasUpdated = updatableDiff.otherWasUpdated;
        bool originalWasUpdated = updatableDiff.originalWasUpdated;
        final policy = getPolicyForDiff(updatableDiff);

        /// check newAnswerText
        if (original.title != other.title) {
          switch (policy) {
            case InstanceUpdatePolicy.useClientVersion:
              other = other.copyWith(title: original.title);
              otherWasUpdated = true;
              break;
            case InstanceUpdatePolicy.useServerVersion:
              original.title = other.title;
              originalWasUpdated = true;
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
