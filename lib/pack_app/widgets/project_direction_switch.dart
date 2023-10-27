part of pack_app;

class ProjectsDirectionSwitch extends StatelessWidget {
  const ProjectsDirectionSwitch({
    required this.settings,
    super.key,
  });

  final GeneralSettingsController settings;

  // ignore: use_setters_to_change_properties
  void setReverse({required final bool reverse}) {
    settings.projectsListReversed = reverse;
  }

  @override
  Widget build(final BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            CupertinoIconButton(
              onPressed: settings.projectsListReversed
                  ? null
                  : () {
                      setReverse(reverse: true);
                    },
              icon: Icons.vertical_align_bottom_rounded,
              color: settings.projectsListReversed ? AppColors.primary : null,
            ),
            const SizedBox(width: 8),
            CupertinoIconButton(
              onPressed: settings.projectsListReversed
                  ? () {
                      setReverse(reverse: false);
                    }
                  : null,
              color: settings.projectsListReversed ? null : AppColors.primary,
              icon: Icons.vertical_align_top_rounded,
            ),
          ],
        ),
      );
}
