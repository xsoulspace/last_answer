import 'package:flutter/widgets.dart';

import '../../theme/theme.dart';
import 'action_button.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({
    final Key? key,
    this.onTap,
  }) : super(key: key);

  final VoidCallback? onTap;

  @override
  Widget build(final BuildContext context) {
    final theme = AppTheme.of(context);
    return AppActionButton(
      icon: theme.icons.characters.arrowBack,
      onTap: onTap ?? () => Navigator.pop(context),
    );
  }
}
