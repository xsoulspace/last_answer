part of pack_settings;

class NoteUpdater
    extends BasicProjectInstanceUpdater<NoteProject, NoteProjectModel> {
  NoteUpdater.of({
    required final super.list,
    required final super.clientSyncService,
    required final super.serverSyncService,
    required final super.foldersNotifier,
  });

  // ignore: long-method
  @override
  Future<InstanceUpdaterDto<NoteProject, NoteProjectModel>> compareContent({
    required final InstanceUpdaterDto<NoteProject, NoteProjectModel> dto,
  }) async {
    return compareDiffContent(
      diff: dto,
      onCheck: (final updatableDiff) {
        final original = updatableDiff.original;
        NoteProjectModel other = updatableDiff.other;
        bool otherWasUpdated = updatableDiff.otherWasUpdated;
        bool originalWasUpdated = updatableDiff.originalWasUpdated;

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
    required final InstanceUpdaterDto<NoteProject, NoteProjectModel> dto,
  }) async {
    super.serverSyncService.applyUpdaterDto(dto: dto);
  }
}
