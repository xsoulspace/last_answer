part of idea_project;

class _IdeaScreenTitle extends StatefulWidget {
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
  State<_IdeaScreenTitle> createState() => _IdeaScreenTitleState();
}

class _IdeaScreenTitleState extends State<_IdeaScreenTitle> {
  final _focusNode = FocusNode();
  @override
  void initState() {
    _focusNode.addListener(onFocusChange);
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.removeListener(onFocusChange);
    super.dispose();
  }

  Color fillColor = Colors.transparent;
  void onFocusChange() {
    if (_focusNode.hasFocus) {
      fillColor = Theme.of(context).cardColor;
    } else {
      fillColor = Colors.transparent;
    }
    setState(() {});
  }

  @override
  Widget build(final BuildContext context) {
    return HeroId(
      id: widget.idea.id,
      type: HeroIdTypes.projectTitle,
      child: AnimatedContainer(
        decoration: BoxDecoration(
          borderRadius: defaultBorderRadius,
          color: fillColor,
        ),
        duration: const Duration(milliseconds: 350),
        constraints: const BoxConstraints(maxWidth: 252),
        child: TextField(
          focusNode: _focusNode,
          controller: widget.controller,
          onChanged: widget.onChanged,
          keyboardAppearance: Theme.of(context).brightness,
          style: Theme.of(context).textTheme.bodyText2,
          decoration: const InputDecoration()
              .applyDefaults(Theme.of(context).inputDecorationTheme)
              .copyWith(
                contentPadding: const EdgeInsets.all(6),
                fillColor: Colors.transparent,
                filled: true,
                isDense: true,
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
