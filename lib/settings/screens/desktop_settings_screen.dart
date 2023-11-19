import 'dart:math' as math;

import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/router.dart';
import 'package:lastanswer/settings/features_widgets/general_settings.dart';
import 'package:lastanswer/settings/features_widgets/my_account.dart';
import 'package:lastanswer/settings/features_widgets/settings_navigation.dart';

class DesktopSettingsScreen extends StatelessWidget {
  const DesktopSettingsScreen({
    required this.onBack,
    super.key,
  });
  final VoidCallback onBack;

  @override
  Widget build(final BuildContext context) {
    final screenLayout = ScreenLayout.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: Stack(
        children: [
          Positioned(
            top: 70,
            left: 50,
            child: CupertinoCloseButton(onPressed: onBack),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: ScreenLayout.maxSmallWidth,
                maxWidth: ScreenLayout.maxMediumWidth,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SettingsNavigation(),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 350),
                    child: SizedBox(
                      width: screenLayout.large ? 85 : 15,
                    ),
                  ),
                  const DesktopSettingsNavigator(),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 100),
                    child: SizedBox(
                      width: screenLayout.large ? 180 : 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DesktopSettingsNavigator extends HookWidget {
  const DesktopSettingsNavigator({super.key});

  @override
  Widget build(final BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenLayout = ScreenLayout.of(context);
    final previousChild = useState<Widget>(const SizedBox());
    Widget child;
    final routeState = context.router.location();
    switch (routeState) {
      case AppPaths.profile:
        child = previousChild.value = const MyAccount();
      case AppPaths.settings:
      case AppPaths.generalSettings:
        child = previousChild.value = const GeneralSettingsView(
          padding: EdgeInsets.only(left: 18, right: 48, top: 64, bottom: 64),
        );
      default:
        child = previousChild.value;
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: defaultPopupBorderRadius,
        ),
        child: SizedBox(
          width: math.min(
            screenLayout.large ? 500 : 450,
            screenWidth / 1.7,
          ),
          child: child,
        ),
      ),
    );
  }
}
