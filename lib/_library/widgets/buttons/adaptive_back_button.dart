import 'package:lastanswer/_library/widgets/buttons/cupertino_icon_button.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:life_hooks/life_hooks.dart';

class AdaptiveBackButton extends HookWidget {
  const AdaptiveBackButton({
    required this.onPressed,
    super.key,
  });
  final VoidCallback onPressed;
  @override
  Widget build(final BuildContext context) {
    final hovered = useIsBool();
    if (PlatformInfo.isNativeWebDesktop) {
      final theme = Theme.of(context);

      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (final _) => hovered.value = true,
        onExit: (final _) => hovered.value = false,
        child: CupertinoIconButton(
          onPressed: onPressed,
          size: 18,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          backgroundColor: hovered.value ? theme.hoverColor : null,
          icon: Icons.arrow_back_ios_new_rounded,
        ),
      );
    }

    return BackButton(onPressed: onPressed);
  }
}
