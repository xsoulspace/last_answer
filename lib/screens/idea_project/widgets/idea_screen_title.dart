part of idea_project;

class _IdeaScreenTitle extends HookWidget {
  const _IdeaScreenTitle({
    required final this.controller,
    required final this.onChanged,
    required final this.idea,
    final Key? key,
  }) : super(key: key);
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final IdeaProject idea;

  @override
  Widget build(final BuildContext context) {
    return HeroId(
      id: idea.id,
      type: HeroIdTypes.projectTitle,
      child: FocusBubbleContainer(
        constraints: const BoxConstraints(maxWidth: 250),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardAppearance: Theme.of(context).brightness,
          style: Theme.of(context).textTheme.bodyText2,
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
}
