part of pack_settings;

NoteUpdater createNoteUpdater(
  final BuildContext context,
) =>
    NoteUpdater.of(
      clientSyncService: context.read<ClientNoteSyncService>(),
      foldersNotifier: context.read(),
      serverSyncService: context.read<ServerProjectsSyncService>(),
    );

class NoteUpdater extends BasicProjectInstanceUpdater<NoteProject,
    NoteProjectModel, NoteProjectsNotifier> {
  NoteUpdater.of({
    required final super.clientSyncService,
    required final this.serverSyncService,
    required final super.foldersNotifier,
  });
  final ServerProjectsSyncService serverSyncService;

  Future<void> updateByUnion(final Iterable<BasicProjectModel> unions) async {
    final other = unions.whereType<NoteProjectModel>();
    await getAndUpdateByOther(other);
  }

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
        final policy = getPolicyForDiff(updatableDiff);

        /// check note
        if (original.note != other.note) {
          switch (policy) {
            case InstanceUpdatePolicy.useClientVersion:
              other = other.copyWith(note: original.note);
              otherWasUpdated = true;
              break;
            case InstanceUpdatePolicy.useServerVersion:
              original.note = other.note;
              originalWasUpdated = true;
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
            case InstanceUpdatePolicy.useServerVersion:
              original.charactersLimit = other.charactersLimit;
              originalWasUpdated = true;
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
    await Future.wait([
      super.saveChanges(dto: dto),
      serverSyncService.applyUpdaterDto(dto: dto),
    ]);
  }
}
