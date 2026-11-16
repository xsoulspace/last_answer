import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:lastanswer/_library/widgets/widgets.dart';
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
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [UiCircularProgress()],
            ).animate().fadeIn(),
          HoverableButton(
            isLoading: isFileLoading,
            onPressed: () => projectsNotifier.saveToFile(
              context,
              useTimestampForBackupFilename: useTimestampForBackupFilename,
              // Wave D1 — the asset files ride the backup zip; the
              // sink is the only holder of the documents root. Web has
              // no local file plane: a JSON-only backup there.
              collectAssets: kIsWeb
                  ? null
                  : (final dbSave) async => (await NoteAssetStore.instance())
                      .collectForBackup(dbSave.projects),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.file_download),
                Flexible(child: Text(l10n.saveToFile)),
              ],
            ),
          ),
          HoverableButton(
            isLoading: isFileLoading,
            onPressed: () => projectsNotifier.loadFromFile(
              context,
              restoreAssets: kIsWeb
                  ? null
                  : (final files) async =>
                        (await NoteAssetStore.instance()).restoreFiles(files),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.file_upload),
                Flexible(child: Text(l10n.restoreFromFile)),
              ],
            ),
          ),
          SwitchListTile.adaptive(
            onChanged: userNotifier.updateUseTimestampForBackupFilename,
            value: useTimestampForBackupFilename,
            title: Text(l10n.applyTimestamp),
          ),
          const Divider(),
          HoverableButton(
            isLoading: isFileLoading,
            onPressed: () async =>
                projectsNotifier.copyDbSaveToClipboard(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.copy_all_rounded),
                Flexible(child: Text(l10n.copyAllProjectsToClipboard)),
              ],
            ),
          ),
          HoverableButton(
            isLoading: isFileLoading,
            onPressed: () async =>
                projectsNotifier.getDbSaveFromClipboard(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.content_paste_go_rounded),
                Flexible(child: Text(l10n.getAllProjectsFromClipboard)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
