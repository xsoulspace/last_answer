part of pack_settings;

class FolderUpdater extends InstanceUpdater<ProjectFolder, ProjectFolderModel> {
  FolderUpdater.of({
    required final super.list,
    required this.foldersNotifier,
  });

  final ProjectFoldersNotifier foldersNotifier;

  @override
  Future<ModelUpdaterDiff<ProjectFolder, ProjectFolderModel>> compareContent({
    required final ModelUpdaterDiff<ProjectFolder, ProjectFolderModel> diff,
  }) async {
    final updatedDiffs =
        <ProjectFolderId, InstanceDiff<ProjectFolder, ProjectFolderModel>>{};
    for (final noteDiff in diff.instancesToCheck.values) {
      final original = noteDiff.original;
      ProjectFolderModel other = noteDiff.other;
      bool otherWasUpdated = false;
      bool originalWasUpdated = false;

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
        updatedDiffs[other.id] = InstanceDiff(original: original, other: other);
      }
    }

    return diff.copyWith(
      instancesToUpdate: updatedDiffs,
    );
  }

  @override
  Future<void> saveChanges({
    required final ModelUpdaterDiff<ProjectFolder, ProjectFolderModel> diff,
  }) {
    // TODO: implement saveChanges
    throw UnimplementedError();
  }
}
