import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';

class ProjectsExportImportButtons extends StatelessWidget {
  const ProjectsExportImportButtons({
    super.key,
  });

  @override
  Widget build(final BuildContext context) {
    final projectsNotifier = context.watch<ProjectsNotifier>();
    final isFileLoading = projectsNotifier.value.isAllProjectsFileLoading;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          if (isFileLoading) const UiCircularProgress(),
          HoverableButton(
            onPressed: isFileLoading ? () {} : projectsNotifier.saveToFile,
            child: const Row(
              children: [
                Icon(Icons.file_download),
                Text('Save to file'),
              ],
            ),
          ),
          HoverableButton(
            onPressed: isFileLoading ? () {} : projectsNotifier.loadFromFile,
            child: const Row(
              children: [
                Icon(Icons.file_upload),
                Text('Load from file'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
