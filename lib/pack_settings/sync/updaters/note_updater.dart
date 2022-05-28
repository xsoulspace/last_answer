part of pack_settings;

class NoteUpdater
    extends BasicProjectInstanceUpdater<NoteProject, NoteProjectModel> {
  NoteUpdater.of({
    required final super.list,
    required final super.clientSyncService,
    required final super.serverSyncService,
    required final super.foldersNotifier,
  });

  @override
  // ignore: long-method
  Future<InstanceUpdaterDto<NoteProject, NoteProjectModel>> compareContent({
    required final InstanceUpdaterDto<NoteProject, NoteProjectModel> diff,
  }) async {
    final otherUpdates = <NoteProjectModel>[];
    final originalUpdates = <NoteProject>[];

    for (final noteDiff in diff.instancesToCheck.values) {
      final original = noteDiff.original;
      NoteProjectModel other = noteDiff.other;
      bool otherWasUpdated = false;
      bool originalWasUpdated = false;

      final folderDiffResult = updateFolder(original: original, other: other);
      other = folderDiffResult.other;
      otherWasUpdated = folderDiffResult.otherWasUpdated;
      originalWasUpdated = folderDiffResult.originalWasUpdated;

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
    required final InstanceUpdaterDto<NoteProject, NoteProjectModel> diff,
  }) {
    // TODO: implement saveChanges
    throw UnimplementedError();
  }
}
