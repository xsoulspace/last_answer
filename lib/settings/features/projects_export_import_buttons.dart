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
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.file_download),
                Flexible(child: Text('Save to file')),
              ],
            ),
          ),
          HoverableButton(
            isLoading: isFileLoading,
            onPressed: () async => projectsNotifier.loadFromFile(context),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.file_upload),
                Flexible(child: Text('Restore from file')),
              ],
            ),
          ),
          SwitchListTile.adaptive(
            onChanged: userNotifier.updateUseTimestampForBackupFilename,
            value: useTimestampForBackupFilename,
            title: const Text('Apply timestamp'),
          ),
        ],
      ),
    );
  }
}
