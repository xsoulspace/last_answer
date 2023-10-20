part of pack_app;

class ProjectTitleField extends HookWidget {
  const ProjectTitleField({
    required this.controller,
    required this.onChanged,
    required this.heroId,
    this.onFocus,
    super.key,
  });
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String heroId;
  final VoidCallback? onFocus;
  @override
  Widget build(final BuildContext context) => HeroId(
        id: heroId,
        type: HeroIdTypes.projectTitle,
        child: FocusBubbleContainer(
          constraints: const BoxConstraints(maxWidth: 250),
          onFocus: onFocus,
          fillDefaultWithCanvas: true,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardAppearance: Theme.of(context).brightness,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
            decoration: const InputDecoration()
                .applyDefaults(Theme.of(context).inputDecorationTheme)
                .copyWith(
                  contentPadding: const EdgeInsets.all(6),
                  fillColor: Colors.transparent,
                  filled: true,
                  isDense: true,
                  focusColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: defaultBorderRadius,
                  ),
                ),
          ),
        ),
      );
}
