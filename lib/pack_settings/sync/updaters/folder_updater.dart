part of pack_settings;

FolderUpdater createFolderUpdater(
  final BuildContext context,
) =>
    FolderUpdater.of(
      clientSyncService: context.read<ClientFolderSyncService>(),
      foldersNotifier: context.read(),
      serverSyncService: context.read<ServerFolderSyncService>(),
    );

class FolderUpdater extends InstanceUpdater<ProjectFolder, ProjectFolderModel,
    ProjectFoldersNotifier> {
  FolderUpdater.of({
    required final super.clientSyncService,
    required final this.serverSyncService,
    required this.foldersNotifier,
  });
  final ServerFolderSyncService serverSyncService;
  final ProjectFoldersNotifier foldersNotifier;

  @override
  Future<InstanceUpdaterDto<ProjectFolder, ProjectFolderModel>> compareContent({
    required final InstanceUpdaterDto<ProjectFolder, ProjectFolderModel> dto,
  }) async {
    return compareDiffContent(
      diff: dto,
      onCheck: (final updatableDiff) {
        final original = updatableDiff.original;
        ProjectFolderModel other = updatableDiff.other;
        bool otherWasUpdated = updatableDiff.otherWasUpdated;
        bool originalWasUpdated = updatableDiff.originalWasUpdated;
        final policy = getPolicyForDiff(updatableDiff);

        /// check title
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
  InstanceUpdatePolicy getPolicyForDiff(
    final UpdatableInstanceDiff<ProjectFolder, ProjectFolderModel> diff,
  ) {
    final useOriginalPolicy =
        diff.original.updatedAt.isAfter(diff.other.updatedAt);
    if (useOriginalPolicy) return InstanceUpdatePolicy.useClientVersion;

    return InstanceUpdatePolicy.useServerVersion;
  }

  @override
  Future<void> saveChanges({
    required final InstanceUpdaterDto<ProjectFolder, ProjectFolderModel> dto,
  }) async {
    await Future.wait([
      super.saveChanges(dto: dto),
      serverSyncService.applyUpdaterDto(dto: dto),
    ]);
  }
}
