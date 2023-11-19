import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/library/widgets/buttons/cupertino_close_button.dart';
import 'package:lastanswer/pack_settings/features_widgets/settings_navigation.dart';

class SettingsNavigationScreen extends StatelessWidget {
  const SettingsNavigationScreen({
    required this.onBack,
    required this.onSelectRoute,
    super.key,
  });
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
        title: Text(context.l10n.settings),
      ),
      body: SettingsNavigation(
        onSelectRoute: onSelectRoute,
      ),
    );
  }
}
