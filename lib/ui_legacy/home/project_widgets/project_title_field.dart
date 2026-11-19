import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/ui_legacy/legacy_kit/legacy_kit.dart';

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
  Widget build(final BuildContext context) {
    // The legacy FocusBubbleContainer focus callback rides a node listener;
    // the focus paint itself is the kit field's own.
    final focusNode = useFocusNode();
    useEffect(
      () {
        final onFocus = this.onFocus;
        if (onFocus == null) return null;
        void listener() {
          if (focusNode.hasFocus) onFocus();
        }

        focusNode.addListener(listener);
        return () => focusNode.removeListener(listener);
      },
      const [],
    );

    return HeroId(
      id: heroId,
      type: HeroIdTypes.projectTitle,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 250),
        child: LaField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          style: context.laUi.body,
          textAlign: TextAlign.center,
          showFocusHairline: false,
          padding: const EdgeInsets.all(6),
        ),
      ),
    );
  }
}
