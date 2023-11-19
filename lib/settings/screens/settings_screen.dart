import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/screens/desktop_settings_screen.dart';
import 'package:lastanswer/settings/screens/small_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.onBack,
    super.key,
  });
  final VoidCallback onBack;

  @override
  Widget build(final BuildContext context) {
    final screenLayout = ScreenLayout.of(context);

    final child = screenLayout.small
        ? SmallSettingsScreen(
            onBack: onBack,
          )
        : DesktopSettingsScreen(
            onBack: onBack,
          );

    return child;
  }
}
