part of pack_settings;

class SettingsButton extends StatelessWidget {
  const SettingsButton({
    required this.onSelected,
    required this.checkSelected,
    required this.routeName,
    this.fallbackRouteName,
    required this.text,
    this.avatar,
    final Key? key,
  }) : super(key: key);
  static final shape =
      RoundedRectangleBorder(borderRadius: defaultBorderRadius);
  final AppRouteName? fallbackRouteName;
  final String text;
  final BoolValueChanged<AppRouteName> checkSelected;
  final ValueChanged<AppRouteName> onSelected;
  final String routeName;
  final Widget? avatar;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    bool selected = checkSelected(routeName);
    if (!selected && fallbackRouteName != null) {
      selected = checkSelected(fallbackRouteName!);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ChoiceChip(
        avatar: avatar,
        label: SizedBox(
          width: 180,
          child: Text(text),
        ),
        pressElevation: 0,
        padding: const EdgeInsets.all(14),
        labelStyle: theme.textTheme.headline4,
        shape: shape,
        backgroundColor: Colors.transparent,
        selectedColor: AppColors.primary2.withOpacity(0.2),
        selected: selected,
        onSelected: (final _) => onSelected(routeName),
      ),
    );
  }
}
