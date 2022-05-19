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
    final updatedDiffs =
        <ProjectId, InstanceDiff<NoteProject, NoteProjectModel>>{};
    for (final noteDiff in diff.instancesToCheck.values) {
      final original = noteDiff.original;
      NoteProjectModel other = noteDiff.other;
      bool otherWasUpdated = false;
      bool originalWasUpdated = false;

      /// check folder
      if (original.folder?.id != other.folderId) {
        if (original.folder != null) {
          switch (policy) {
            case InstanceUpdatePolicy.useClientVersion:
              other = other.copyWith(
                folderId: original.folder!.id,
              );
              otherWasUpdated = true;
              break;
            default:
              // TODO(arenukvern): description
              throw UnimplementedError();
          }
        } else {
          final folder = foldersNotifier.state[other.folderId];
          folder?.addProject(original);
          originalWasUpdated = true;
        }
      }

      /// check note
      if (original.note != other.note) {
        switch (policy) {
          case InstanceUpdatePolicy.useClientVersion:
            other = other.copyWith(note: original.note);
            otherWasUpdated = true;
            break;
          default:
            // TODO(arenukvern): description
            throw UnimplementedError();
        }
      }

      /// check [NoteProjectModel.charactersLimit]
      if (original.charactersLimit != other.charactersLimit) {
        switch (policy) {
          case InstanceUpdatePolicy.useClientVersion:
            other = other.copyWith(charactersLimit: original.charactersLimit);
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
    required final ModelUpdaterDiff<IdeaProjectQuestion,
            IdeaProjectQuestionModel>
        diff,
  }) {
    // TODO: implement saveChanges
    throw UnimplementedError();
  }
}
