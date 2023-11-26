import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';

class ProjectsDirectionSwitch extends StatelessWidget {
  const ProjectsDirectionSwitch({
    super.key,
  });

  @override
  Widget build(final BuildContext context) {
    final userNotifier = context.watch<UserNotifier>();
    final settings = userNotifier.settings;
    void setReverse({required final bool isReversed}) =>
        userNotifier.updateIsProjectsReversed(isReversed: isReversed);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          HoverableButton(
            onPressed: () => setReverse(isReversed: true),
            child: Icon(
              Icons.vertical_align_bottom_rounded,
              color: settings.isProjectsListReversed
                  ? context.colorScheme.primary
                  : context.colorScheme.onSecondary,
            ),
          ),
          HoverableButton(
            onPressed: () => setReverse(isReversed: false),
            child: Icon(
              Icons.vertical_align_top_rounded,
              color: settings.isProjectsListReversed
                  ? context.colorScheme.onSecondary
                  : context.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
