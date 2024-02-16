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
    final saveToButton = HoverableButton(
      isLoading: isFileLoading,
      onPressed: projectsNotifier.saveToFile,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.file_download),
          Flexible(child: Text('Save to file')),
        ],
      ),
    );
    final loadFromButton = HoverableButton(
      isLoading: isFileLoading,
      onPressed: () async => projectsNotifier.loadFromFile(context),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.file_upload),
          Flexible(child: Text('Load from file')),
        ],
      ),
    );
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
          saveToButton,
          loadFromButton,
        ],
      ),
    );
  }
}
