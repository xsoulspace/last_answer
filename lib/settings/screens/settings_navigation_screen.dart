import 'package:lastanswer/_library/widgets/buttons/cupertino_close_button.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/features_widgets/settings_navigation.dart';

class SettingsNavigationScreen extends StatelessWidget {
  const SettingsNavigationScreen({
    required this.onBack,
    super.key,
  });
  final VoidCallback onBack;

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
      body: const SettingsNavigation(),
    );
  }
}
