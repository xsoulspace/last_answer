import 'package:lastanswer/common_imports.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({
    required this.onSelected,
    required this.routeName,
    required this.text,
    this.checkSelected,
    this.fallbackRouteName,
    this.avatar,
    super.key,
  });
  final String? fallbackRouteName;
  final String text;
  final BoolValueChanged<String>? checkSelected;
  final ValueChanged<String> onSelected;
  final String routeName;
  final Widget? avatar;
  @override
  Widget build(final BuildContext context) {
    bool selected = checkSelected?.call(routeName) ?? false;
    if (!selected && fallbackRouteName != null) {
      selected = checkSelected?.call(fallbackRouteName!) ?? false;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: LaPressable(
        onTap: () => onSelected(routeName),
        selected: selected,
        selectedFill: context.laUi.accent.withValues(alpha: 0.2),
        radius: defaultBorderRadius,
        padding: const EdgeInsets.all(14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (avatar != null) ...[avatar!, const SizedBox(width: 8)],
            SizedBox(width: 180, child: Text(text, style: context.laUi.body)),
          ],
        ),
      ),
    );
  }
}
