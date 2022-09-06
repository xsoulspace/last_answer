import 'package:flutter/material.dart';
import 'package:lastanswer/generated/l10n.dart';
import 'package:lastanswer/library/widgets/widgets.dart';
import 'package:lastanswer/pack_app/navigation/navigation_routes.dart';
import 'package:lastanswer/pack_settings/features_widgets/settings_navigation.dart';

class SettingsNavigationScreen extends StatelessWidget {
  const SettingsNavigationScreen({
    required this.onBack,
    required this.onSelectRoute,
    final Key? key,
  }) : super(key: key);
  final VoidCallback onBack;
  final ValueChanged<AppRouteName> onSelectRoute;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.canvasColor,
      appBar: AppBar(
        centerTitle: true,
        leading: CupertinoCloseButton(onPressed: onBack),
        title: Text(S.current.settings),
      ),
      body: SettingsNavigation(
        onSelectRoute: onSelectRoute,
      ),
    );
  }
}
