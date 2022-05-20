part of pack_settings;

class FolderUpdater extends InstanceUpdater<ProjectFolder, ProjectFolderModel> {
  FolderUpdater.of({
    required final super.list,
    required final super.clientSyncService,
    required final super.serverSyncService,
    required this.foldersNotifier,
  });

  final ProjectFoldersNotifier foldersNotifier;

  @override
  Future<InstanceUpdaterDto<ProjectFolder, ProjectFolderModel>> compareContent({
    required final InstanceUpdaterDto<ProjectFolder, ProjectFolderModel> diff,
  }) async {
    final otherUpdates = <ProjectFolderModel>[];
    final originalUpdates = <ProjectFolder>[];
    for (final noteDiff in diff.instancesToCheck.values) {
      final original = noteDiff.original;
      ProjectFolderModel other = noteDiff.other;
      bool otherWasUpdated = false;
      const bool originalWasUpdated = false;

      /// check title
      if (original.title != other.title) {
        switch (policy) {
          case InstanceUpdatePolicy.useClientVersion:
            other = other.copyWith(title: original.title);
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
}
