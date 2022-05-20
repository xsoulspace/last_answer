part of pack_settings;

class NoteUpdater extends InstanceUpdater<NoteProject, NoteProjectModel> {
  NoteUpdater.of({
    required final super.list,
    required final super.clientSyncService,
    required final super.serverSyncService,
    required this.foldersNotifier,
  });

  final ProjectFoldersNotifier foldersNotifier;

  @override
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

      /// check folder - how to unify for all projects?
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
