import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:lastanswer/library/widgets/widgets.dart';

class ProjectTitleField extends HookWidget {
  const ProjectTitleField({
    required final this.controller,
    required final this.onChanged,
    required final this.heroId,
    final this.onFocus,
    final Key? key,
  }) : super(key: key);
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String heroId;
  final VoidCallback? onFocus;
  @override
  Widget build(final BuildContext context) {
    return HeroId(
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
