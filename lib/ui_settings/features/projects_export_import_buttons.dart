import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/note/note_asset_store.dart';

class ProjectsExportImportButtons extends StatelessWidget {
  const ProjectsExportImportButtons({super.key});

  @override
  Widget build(final BuildContext context) {
    final projectsNotifier = context.watch<ProjectsNotifier>();
    final userNotifier = context.watch<UserNotifier>();
    final useTimestampForBackupFilename =
        userNotifier.settings.useTimestampForBackupFilename;
    final isFileLoading = projectsNotifier.value.isAllProjectsFileLoading;
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (isFileLoading)
            const Row(mainAxisSize: MainAxisSize.min, children: [LaSpinner()]),
          LaButton(
            variant: LaButtonVariant.ghost,
            icon: const Icon(Icons.file_download, size: 16),
            label: l10n.saveToFile,
            onPressed: isFileLoading
                ? null
                : () => projectsNotifier.saveToFile(
                    context,
                    useTimestampForBackupFilename:
                        useTimestampForBackupFilename,
                    // Wave D1 — the asset files ride the backup zip; the
                    // sink is the only holder of the documents root. Web has
                    // no local file plane: a JSON-only backup there.
                    collectAssets: kIsWeb
                        ? null
                        : (final dbSave) async =>
                              (await NoteAssetStore.instance())
                                  .collectForBackup(dbSave.projects),
                  ),
          ),
          LaButton(
            variant: LaButtonVariant.ghost,
            icon: const Icon(Icons.file_upload, size: 16),
            label: l10n.restoreFromFile,
            onPressed: isFileLoading
                ? null
                : () => projectsNotifier.loadFromFile(
                    context,
                    restoreAssets: kIsWeb
                        ? null
                        : (final files) async =>
                              (await NoteAssetStore.instance()).restoreFiles(
                                files,
                              ),
                  ),
          ),
          LaRow(
            titleText: l10n.applyTimestamp,
            onTap: () => userNotifier.updateUseTimestampForBackupFilename(
              !useTimestampForBackupFilename,
            ),
            trailing: LaSwitch(
              value: useTimestampForBackupFilename,
              onChanged: userNotifier.updateUseTimestampForBackupFilename,
            ),
          ),
          const LaHairline(),
          LaButton(
            variant: LaButtonVariant.ghost,
            icon: const Icon(Icons.copy_all_rounded, size: 16),
            label: l10n.copyAllProjectsToClipboard,
            onPressed: isFileLoading
                ? null
                : () => projectsNotifier.copyDbSaveToClipboard(context),
          ),
          LaButton(
            variant: LaButtonVariant.ghost,
            icon: const Icon(Icons.content_paste_go_rounded, size: 16),
            label: l10n.getAllProjectsFromClipboard,
            onPressed: isFileLoading
                ? null
                : () => projectsNotifier.getDbSaveFromClipboard(context),
          ),
        ],
      ),
    );
  }
}
