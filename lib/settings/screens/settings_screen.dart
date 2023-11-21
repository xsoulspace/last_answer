import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/screens/desktop_settings_screen.dart';
import 'package:lastanswer/settings/screens/small_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
  });

  @override
  Widget build(final BuildContext context) {
    final screenLayout = ScreenLayout.of(context);
    void onHome() => context.go(ScreenPaths.home);
    final child = screenLayout.small
        ? SmallSettingsScreen(onHome: onHome)
        : DesktopSettingsScreen(onHome: onHome);

    return child;
  }
}
