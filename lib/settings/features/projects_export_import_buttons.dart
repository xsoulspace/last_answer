import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';

class ProjectsExportImportButtons extends StatelessWidget {
  const ProjectsExportImportButtons({
    super.key,
  });

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
            onPressed: () async => projectsNotifier.saveToFile(
              context,
              useTimestampForBackupFilename: useTimestampForBackupFilename,
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
            onPressed: () async => projectsNotifier.loadFromFile(context),
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
                projectsNotifier.copyAllProjectsToClipboard(context),
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
                projectsNotifier.getAllProjectsFromClipboard(context),
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
