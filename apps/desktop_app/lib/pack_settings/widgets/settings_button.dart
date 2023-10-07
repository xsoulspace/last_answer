import 'package:flutter/material.dart';
import 'package:lastanswer/library/theme/theme.dart';
import 'package:lastanswer/pack_app/navigation/navigation_routes.dart';
import 'package:lastanswer/pack_app/pack_app.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({
    required this.onSelected,
    required this.routeName,
    required this.text,
    this.checkSelected,
    this.fallbackRouteName,
    this.avatar,
    final Key? key,
  }) : super(key: key);
  static final shape =
      RoundedRectangleBorder(borderRadius: defaultBorderRadius);
  final AppRouteName? fallbackRouteName;
  final String text;
  final BoolValueChanged<AppRouteName>? checkSelected;
  final ValueChanged<AppRouteName> onSelected;
  final String routeName;
  final Widget? avatar;
  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    bool selected = checkSelected?.call(routeName) ?? false;
    if (!selected && fallbackRouteName != null) {
      selected = checkSelected?.call(fallbackRouteName!) ?? false;
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
